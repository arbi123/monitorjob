param(
    [Parameter(Mandatory = $true)]
    [string]$Message
)

function Send-JsonPost {
    param(
        [string]$Uri,
        [hashtable]$Payload
    )
    $json = $Payload | ConvertTo-Json -Compress
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($json)
    Invoke-RestMethod -Uri $Uri -Method Post -ContentType 'application/json; charset=utf-8' -Body $bytes
}

if ($env:DISCORD_WEBHOOK_URL) {
    Send-JsonPost -Uri $env:DISCORD_WEBHOOK_URL -Payload @{ content = $Message }
    Write-Host 'Discord alert sent.'
}

if ($env:SLACK_WEBHOOK_URL) {
    Send-JsonPost -Uri $env:SLACK_WEBHOOK_URL -Payload @{ text = $Message }
    Write-Host 'Slack alert sent.'
}
