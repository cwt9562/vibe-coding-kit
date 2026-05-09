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
# Build title & body from stdin
# =========================
$title = $toastTitle
$body  = "-"
$needsAction = $false

# Unified project name extraction
$projectName = ""
if ($data -and $data.cwd) {
    $projectName = Split-Path $data.cwd -Leaf
}

if ($projectName -eq "") {
    $projectName = $toastTitle
}

if ($data) {
    # =========================
    # Handle StopFailure event
    # =========================
    if ($data.hook_event_name -and $data.hook_event_name -eq "StopFailure") {
        $errorType = if ($data.error -and $data.error.Trim() -ne "") { $data.error.Trim() } else { "unknown" }
        $title = "$projectName - 错误: $errorType"

        if ($data.last_assistant_message -and $data.last_assistant_message.Trim() -ne "") {
            $body = $data.last_assistant_message.Trim()
        } elseif ($data.error_details -and $data.error_details.Trim() -ne "") {
            $body = $data.error_details.Trim()
        } else {
            $body = "对话因 API 错误异常结束"
        }

        if ($body.Length -gt 150) {
            $body = $body.Substring(0, 147) + "..."
        }

        $needsAction = $true
    # =========================
    # Handle PreToolUse event (AskUserQuestion)
    # =========================
    } elseif ($data.hook_event_name -and $data.hook_event_name -eq "PreToolUse" -and $data.tool_name -and $data.tool_name -match "AskUserQuestion") {
        $title = "$projectName - 需要你的回答"
        $body = "有提问需要你的回答"
        $needsAction = $true
    # =========================
    # Handle Stop event
    # =========================
    } elseif ($data.hook_event_name -and $data.hook_event_name -eq "Stop") {
        # Use unified $projectName extracted earlier
        $title = $projectName

        # Use last_assistant_message as body, with fallback
        if ($data.last_assistant_message -and $data.last_assistant_message.Trim() -ne "") {
            $body = $data.last_assistant_message.Trim()
        } else {
            $body = "任务完成，请查看结果"
        }

        if ($body.Length -gt 150) {
            $body = $body.Substring(0, 147) + "..."
        }

        $needsAction = $false
    } else {
        # Use notification_type for title prefix
        $notificationType = $data.notification_type
        $typeDisplay = $notificationType
        switch ($notificationType) {
            "permission_prompt"   { $typeDisplay = "权限请求" }
            "idle_prompt"         { $typeDisplay = "空闲提示" }
            "auth_success"        { $typeDisplay = "认证成功" }
            "elicitation_dialog"  { $typeDisplay = "引导对话框" }
            "elicitation_complete" { $typeDisplay = "引导完成" }
            "elicitation_response" { $typeDisplay = "引导响应" }
        }
        if ($typeDisplay -and $typeDisplay.Trim() -ne "") {
            $title = "$projectName - $typeDisplay"
        } else {
            $title = $projectName
        }

        # Use message from stdin
        if ($data.message -and $data.message.Trim() -ne "") {
            $body = $data.message
            if ($body.Length -gt 150) {
                $body = $body.Substring(0, 147) + "..."
            }
        }

        # Use title from stdin if available (prepend project name)
        if ($data.title -and $data.title.Trim() -ne "") {
            $title = "$projectName - $($data.title)"
        }

        # Determine if action button needed
        $needsAction = $data.notification_type -eq "permission_prompt"
    }
}

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
try {
    Send-ToastViaWinRT $title $body $needsAction
}
catch {
    Send-ToastViaBalloon $title $body $needsAction
}
