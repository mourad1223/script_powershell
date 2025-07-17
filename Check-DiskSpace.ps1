<#
.SYNOPSIS
    Vérifie l’espace disque disponible sur un ou plusieurs serveurs.

.DESCRIPTION
    Ce script interroge les lecteurs physiques (type 3) sur des serveurs distants et affiche l’espace libre et total. Il signale également les disques en dessous d’un seuil défini.

.PARAMETER Servers
    Liste des serveurs à analyser (par défaut : localhost).

.PARAMETER ThresholdGB
    Seuil d’alerte en Go en dessous duquel l'espace disque est considéré comme faible.

.EXAMPLE
    .\Check-DiskSpace.ps1 -Servers @("Server1", "Server2") -ThresholdGB 15
#>
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
