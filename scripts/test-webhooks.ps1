param(
    [string]$DiscordUrl = $env:DISCORD_WEBHOOK_URL,
    [string]$SlackUrl = $env:SLACK_WEBHOOK_URL
)

if (-not $DiscordUrl -and -not $SlackUrl) {
    Write-Error "Set DISCORD_WEBHOOK_URL and/or SLACK_WEBHOOK_URL, or pass -DiscordUrl / -SlackUrl."
    exit 1
}

$message = "✅ **Kosova Ticket Monitor** webhook test`nBoth Discord and Slack are configured. You will be alerted when Ireland / Nations League tickets appear."

if ($DiscordUrl) {
    $env:DISCORD_WEBHOOK_URL = $DiscordUrl
}
if ($SlackUrl) {
    $env:SLACK_WEBHOOK_URL = $SlackUrl
}

& "$PSScriptRoot\send-alert.ps1" -Message $message
Write-Host "Webhook test complete."
