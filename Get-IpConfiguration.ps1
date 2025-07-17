<#
.SYNOPSIS
    Affiche la configuration réseau IP des interfaces actives.

.DESCRIPTION
    Ce script collecte l’adresse IP, la passerelle et les serveurs DNS configurés
    pour chaque carte réseau activée sur un ou plusieurs serveurs.

.PARAMETER ComputerName
    Nom du serveur à interroger (ou localhost).

.EXAMPLE
    .\Get-IpConfiguration.ps1 -ComputerName "SRV-FS01"
#>

param (
    [string[]]$ComputerName = @("localhost")
)

foreach ($comp in $ComputerName) {
    Write-Host "`n🔍 $comp" -ForegroundColor Cyan
    Invoke-Command -ComputerName $comp -ScriptBlock {
        Get-NetIPConfiguration | Where-Object { $_.IPv4Address } | Select-Object InterfaceAlias, IPv4Address, IPv4DefaultGateway, DNSServer
    }
}
