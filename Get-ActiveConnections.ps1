<#
.SYNOPSIS
    Affiche les connexions réseau actives (TCP/UDP).

.DESCRIPTION
    Ce script récupère les connexions en cours sur un hôte local ou distant
    via Get-NetTCPConnection et Get-NetUDPEndpoint.

.PARAMETER ComputerName
    Nom du serveur à interroger.

.EXAMPLE
    .\Get-ActiveConnections.ps1 -ComputerName "SRV-DC01"
#>

param (
    [string]$ComputerName = "localhost"
)

Invoke-Command -ComputerName $ComputerName -ScriptBlock {
    Get-NetTCPConnection | Where-Object { $_.State -eq "Established" } |
        Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, State
}
