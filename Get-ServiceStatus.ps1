<#
.SYNOPSIS
    Vérifie l’état d’une liste de services sur plusieurs serveurs.

.DESCRIPTION
    Ce script teste si des services critiques sont bien démarrés sur une ou plusieurs machines.
    Il signale ceux qui sont arrêtés ou absents.

.PARAMETER Servers
    Liste des serveurs sur lesquels exécuter les vérifications.

.PARAMETER ServiceNames
    Liste des noms de services à contrôler (ex: "Spooler", "DFSR").

.EXAMPLE
    .\Get-ServiceStatus.ps1 -Servers @("SRV01", "SRV02") -ServiceNames @("W32Time", "DFSR")
#>

param(
    [string[]]$Servers = @("localhost"),
    [string[]]$ServiceNames = @("Spooler", "W32Time", "DFSR")
)

foreach ($server in $Servers) {
    Write-Host "`n Vérification des services sur $server" -ForegroundColor Blue
    foreach ($svc in $ServiceNames) {
        Invoke-Command -ComputerName $server -ScriptBlock {
            param($svc)
            $s = Get-Service -Name $svc -ErrorAction SilentlyContinue
            if ($null -eq $s) {
                Write-Output "❌ $svc introuvable sur $env:COMPUTERNAME"
            } else {
                Write-Output "$($s.DisplayName) : $($s.Status)"
            }
        } -ArgumentList $svc
    }
}
