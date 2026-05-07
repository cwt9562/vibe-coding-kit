param(
    [string]$Event = "Stop",
    [string]$Title = "",
    [string]$Message = ""
)

# Force UTF-8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# =========================
# Toast Settings
# =========================
$toastTitle = "ClaudeCode"

# =========================
# Read stdin (safe for PS 5.1, never blocks)
# =========================
$data = $null
$hasStdin = $false

try {
    $prop = [System.Console].GetProperty("IsInputRedirected", [System.Reflection.BindingFlags]::Public -bor [System.Reflection.BindingFlags]::Static)
    if ($null -ne $prop) {
        $hasStdin = [bool]$prop.GetValue($null)
    }
} catch { }

if ($hasStdin) {
    $inputLines = @()
    while ($null -ne ($line = [Console]::In.ReadLine())) {
        $inputLines += $line
    }
    $rawJson = $inputLines -join "`n"

    if ($rawJson.Trim() -ne "") {
        try {
            $data = $rawJson | ConvertFrom-Json
        } catch { }
    }
}

# =========================
# Helper: extract text from transcript JSON line
# =========================
function Get-TextFromLine {
    param([string]$line)
    try {
        $entry = $line | ConvertFrom-Json
        if ($entry.message) {
            $content = $entry.message.content
            if ($content -is [string]) { return $content }
            elseif ($content -is [array]) {
                $textBlock = $content | Where-Object { $_.type -eq "text" } | Select-Object -First 1
                if ($textBlock) { return $textBlock.text }
            }
        }
    } catch {}
    return ""
}

# =========================
# Build title & body
# =========================
$title = ""
$body  = ""

if ($Title -ne "") { $title = $Title }
if ($Message -ne "") { $body = $Message }

if ($title -eq "" -and $body -eq "") {

    if ($Event -eq "Stop") {

        $projectName = ""
        if ($data -and $data.cwd) {
            $projectName = Split-Path $data.cwd -Leaf
        }
        $title = if ($projectName -ne "") { "$toastTitle - $projectName" } else { $toastTitle }

        if ($data -and $data.transcript_path -and $data.transcript_path -ne "" -and (Test-Path $data.transcript_path)) {
            try {
                $lines = Get-Content $data.transcript_path -Encoding UTF8
                if ($lines.Count -ge 2) {
                    $first = Get-TextFromLine $lines[0]
                    $last = Get-TextFromLine $lines[$lines.Count - 1]
                    if ($first -ne "" -and $last -ne "") {
                        $body = "$first`n......`n$last"
                    }
                }
                elseif ($lines.Count -eq 1) {
                    $body = Get-TextFromLine $lines[0]
                }
            } catch { }
        }

        if ($body.Trim() -eq "") {
            $body = "任务完成，请查看结果"
        }
        elseif ($body.Length -gt 150) {
            $body = $body.Substring(0, 147) + "..."
        }

    }
    elseif ($Event -eq "Notification") {
        $title = "$toastTitle - 需要确认"
        if ($data -and $data.message -and $data.message.Trim() -ne "") {
            $body = $data.message
            if ($body.Length -gt 150) { $body = $body.Substring(0, 147) + "..." }
        }
        else {
            $body = "等待你的输入或确认"
        }
    }
    elseif ($Event -eq "AskUserQuestion") {
        $projectName = if ($data -and $data.cwd) { Split-Path $data.cwd -Leaf } else { "" }
        $title = if ($projectName -ne "") { "$toastTitle - $projectName" } else { $toastTitle }
        $body = "有提问需要你的回答"
    }
    else {
        $title = $toastTitle
        $body = "收到事件: $Event"
    }
}

# 兜底值 (去掉了特殊长破折号，改为普通短横线)
if ($title -eq "") { $title = $toastTitle }
if ($body  -eq "") { $body  = "-" }

# =========================
# WinRT Toast
# =========================
function Send-ToastViaWinRT {
    param($t, $b, $needsAction = $false)

    [Windows.UI.Notifications.ToastNotificationManager,Windows.UI.Notifications,ContentType=WindowsRuntime] | Out-Null
    [Windows.Data.Xml.Dom.XmlDocument,Windows.Data.Xml.Dom,ContentType=WindowsRuntime] | Out-Null

    # 使用单引号包裹，避免大括号被解析器误判
    $appId = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'
    $safeTitle  = [System.Security.SecurityElement]::Escape($t)
    $safeBody   = [System.Security.SecurityElement]::Escape($b)

    if ($needsAction) {
        $safeAction = [System.Security.SecurityElement]::Escape("已阅")
        $xml = "<toast scenario='reminder'>
    <visual>
        <binding template='ToastGeneric'>
            <text>$safeTitle</text>
            <text>$safeBody</text>
        </binding>
    </visual>
    <actions>
        <action content='$safeAction' arguments='dismiss'/>
    </actions>
    <audio silent='true'/>
</toast>"
    } else {
        $xml = "<toast duration='long'>
    <visual>
        <binding template='ToastGeneric'>
            <text>$safeTitle</text>
            <text>$safeBody</text>
        </binding>
    </visual>
    <audio silent='true'/>
</toast>"
    }

    $toastXml = [Windows.Data.Xml.Dom.XmlDocument]::new()
    $toastXml.LoadXml($xml)
    $toast = [Windows.UI.Notifications.ToastNotification]::new($toastXml)
    [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($appId).Show($toast)
}

# =========================
# Balloon Fallback
# =========================
function Send-ToastViaBalloon {
    param($t, $b, $needsAction = $false)

    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $notify = New-Object System.Windows.Forms.NotifyIcon
    $notify.Icon = [System.Drawing.SystemIcons]::Information
    $notify.Visible = $true
    $notify.ShowBalloonTip(8000, $t, $b, [System.Windows.Forms.ToolTipIcon]::Info)
    Start-Sleep -Seconds 10
    $notify.Dispose()
}

# =========================
# Send Notification
# =========================
$needsAction = ($Event -eq "AskUserQuestion")
$title = "$title [$Event]"

try {
    Send-ToastViaWinRT $title $body $needsAction
}
catch {
    Send-ToastViaBalloon $title $body $needsAction
}
