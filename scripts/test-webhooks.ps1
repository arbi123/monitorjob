param(
    [string]$DiscordUrl = $env:DISCORD_WEBHOOK_URL,
    [string]$SlackUrl = $env:SLACK_WEBHOOK_URL
)

if (-not $DiscordUrl -and -not $SlackUrl) {
    Write-Error "Set DISCORD_WEBHOOK_URL and/or SLACK_WEBHOOK_URL, or pass -DiscordUrl / -SlackUrl."
    exit 1
}

if ($DiscordUrl) {
    $env:DISCORD_WEBHOOK_URL = $DiscordUrl
}
if ($SlackUrl) {
    $env:SLACK_WEBHOOK_URL = $SlackUrl
}

& "$PSScriptRoot\send-alert.ps1" -EventDetected
Write-Host "Webhook test complete."
