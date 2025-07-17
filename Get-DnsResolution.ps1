<#
.SYNOPSIS
    Vérifie la résolution DNS de noms d’hôtes.

.DESCRIPTION
    Ce script résout les noms DNS spécifiés et retourne les adresses IP correspondantes.
    Idéal pour tester des problèmes de résolution ou de routage.

.PARAMETER Hostnames
    Liste de noms à résoudre.

.EXAMPLE
    .\Get-DnsResolution.ps1 -Hostnames @("google.com", "dc01.local")
#>

param (
    [string[]]$Hostnames = @("localhost", "google.com")
)

foreach ($name in $Hostnames) {
    try {
        $addresses = [System.Net.Dns]::GetHostAddresses($name)
        foreach ($ip in $addresses) {
            Write-Host "✅ $name -> $ip"
        }
    } catch {
        Write-Host "❌ $name n'a pas pu être résolu." -ForegroundColor Red
    }
}
