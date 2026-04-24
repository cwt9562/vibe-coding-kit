# 需要先安装 BurntToast，在 PowerShell（管理员模式）中运行：
# Install-Module -Name BurntToast -Force

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
$toastIcon  = $null
$toastTitle = "ClaudeCode"

if ($null -ne $toastIcon -and -not (Test-Path $toastIcon)) {
    $toastIcon = $null
}

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
                $lines = Get-Content $data.transcript_path -Tail 30 -Encoding UTF8
                for ($i = $lines.Count - 1; $i -ge 0; $i--) {
                    $entry = $null
                    try { $entry = $lines[$i] | ConvertFrom-Json } catch { continue }

                    if ($entry -and $entry.message -and $entry.message.role -eq "assistant") {
                        $content = $entry.message.content
                        if ($content -is [string]) {
                            $body = $content
                        }
                        elseif ($content -is [array]) {
                            $textBlock = $content | Where-Object { $_.type -eq "text" } | Select-Object -First 1
                            if ($textBlock) { $body = $textBlock.text }
                        }
                        if ($body.Trim() -ne "") { break }
                    }
                }
            } catch { }
        }

        if ($body.Trim() -eq "") {
            $body = "Task completed, please review results."
        }
        elseif ($body.Length -gt 150) {
            $body = $body.Substring(0, 147) + "..."
        }

    }
    elseif ($Event -eq "Notification") {
        $title = "$toastTitle - Needs Attention"
        if ($data -and $data.message -and $data.message.Trim() -ne "") {
            $body = $data.message
            if ($body.Length -gt 150) { $body = $body.Substring(0, 147) + "..." }
        }
        else {
            $body = "Claude is waiting for your input or approval."
        }
    }
    else {
        $title = $toastTitle
        $body = "Event received: $Event"
    }
}

# 兜底值 (去掉了特殊长破折号，改为普通短横线)
if ($title -eq "") { $title = $toastTitle }
if ($body  -eq "") { $body  = "-" }

# =========================
# BurntToast
# =========================
function Send-ToastViaBurntToast {
    param($t, $b)
    Import-Module BurntToast -ErrorAction Stop
    New-BurntToastNotification -Text $t, $b -Silent
}

# =========================
# WinRT Toast
# =========================
function Send-ToastViaWinRT {
    param($t, $b)

    [Windows.UI.Notifications.ToastNotificationManager,Windows.UI.Notifications,ContentType=WindowsRuntime] | Out-Null
    [Windows.Data.Xml.Dom.XmlDocument,Windows.Data.Xml.Dom,ContentType=WindowsRuntime] | Out-Null

    # 使用单引号包裹，避免大括号被解析器误判
    $appId = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'
    $safeTitle = [System.Security.SecurityElement]::Escape($t)
    $safeBody  = [System.Security.SecurityElement]::Escape($b)

    # 废弃 @"..."@ 语法，改用普通多行字符串，彻底避免编辑器行尾空格导致的解析灾难
    $xml = "<toast>
    <visual>
        <binding template='ToastGeneric'>
            <text>$safeTitle</text>
            <text>$safeBody</text>
        </binding>
    </visual>
    <audio silent='true'/>
</toast>"

    $toastXml = [Windows.Data.Xml.Dom.XmlDocument]::new()
    $toastXml.LoadXml($xml)
    $toast = [Windows.UI.Notifications.ToastNotification]::new($toastXml)
    [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($appId).Show($toast)
}

# =========================
# Balloon Fallback
# =========================
function Send-ToastViaBalloon {
    param($t, $b)

    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $notify = New-Object System.Windows.Forms.NotifyIcon
    $notify.Icon = [System.Drawing.SystemIcons]::Information
    $notify.Visible = $true
    $notify.ShowBalloonTip(8000, $t, $b, [System.Windows.Forms.ToolTipIcon]::Info)
    Start-Sleep -Seconds 3
    $notify.Dispose()
}

# =========================
# Send Notification
# =========================
try {
    Send-ToastViaBurntToast $title $body
}
catch {
    try {
        Send-ToastViaWinRT $title $body
    }
    catch {
        Send-ToastViaBalloon $title $body
    }
}
