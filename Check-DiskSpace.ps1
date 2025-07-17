param(
    [string[]]$Servers = @("localhost"),
    [int]$ThresholdGB = 10
)

foreach ($server in $Servers) {
    Write-Host "`n📊 Vérification de $server" -ForegroundColor Cyan

    Invoke-Command -ComputerName $server -ScriptBlock {
        Get-WmiObject Win32_LogicalDisk -Filter "DriveType = 3" | ForEach-Object {
            $freeGB = [math]::Round($_.FreeSpace / 1GB, 2)
            $totalGB = [math]::Round($_.Size / 1GB, 2)
            [PSCustomObject]@{
                Drive       = $_.DeviceID
                FreeGB      = $freeGB
                TotalGB     = $totalGB
                Computer    = $env:COMPUTERNAME
                Status      = if ($freeGB -lt $using:ThresholdGB) { "⚠️ Low Space" } else { "OK" }
            }
        }
    }
}
