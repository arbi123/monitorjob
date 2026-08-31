param(
    [string]$Message,
    [switch]$EventDetected
)

if ($EventDetected) {
    $url = if ($env:MONITOR_URLS) { ($env:MONITOR_URLS -split ',')[0].Trim() } else { 'https://eu.ebileta.al/biglietteria/listaEventiPub.do' }
    $time = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $Message = @"
An event with Ireland has been added to the ticket website!

Go there and buy your tickets now:
$url

Detected at: $time
"@
}

if (-not $Message) {
    throw 'Provide -Message or use -EventDetected.'
}

function Send-JsonPost {
    param(
        [string]$Uri,
        [object]$Payload
    )
    $json = $Payload | ConvertTo-Json -Compress -Depth 4
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($json)
    Invoke-RestMethod -Uri $Uri -Method Post -ContentType 'application/json; charset=utf-8' -Body $bytes
}

if ($env:DISCORD_WEBHOOK_URL) {
    $discordPayload = [ordered]@{
        content = "@everyone`n$Message"
        allowed_mentions = @{
            parse = @('everyone')
        }
    }
    Send-JsonPost -Uri $env:DISCORD_WEBHOOK_URL -Payload $discordPayload
    Write-Host 'Discord alert sent.'
}

if ($env:SLACK_WEBHOOK_URL) {
    Send-JsonPost -Uri $env:SLACK_WEBHOOK_URL -Payload @{ text = $Message }
    Write-Host 'Slack alert sent.'
}
