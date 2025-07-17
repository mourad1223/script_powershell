<#
.SYNOPSIS
    Liste les mises à jour Windows en attente d’installation.

.DESCRIPTION
    Ce script utilise le module PSWindowsUpdate pour récupérer les mises à jour en attente
    sur un ou plusieurs serveurs.

.PARAMETER Servers
    Liste des serveurs sur lesquels vérifier les mises à jour.

.EXAMPLE
    .\Get-PendingUpdates.ps1 -Servers @("SRV-AD01", "SRV-FS01")
#>

param(
    [string[]]$Servers = @("localhost")
)

foreach ($server in $Servers) {
    Write-Host "`n🛠️ Mises à jour en attente sur $server" -ForegroundColor Green
    Invoke-Command -ComputerName $server -ScriptBlock {
        Import-Module PSWindowsUpdate
        Get-WindowsUpdate -IsPending
    }
}
