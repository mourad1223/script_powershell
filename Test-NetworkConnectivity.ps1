<#
.SYNOPSIS
    Teste la connectivité réseau vers une liste de machines (ping).

.DESCRIPTION
    Ce script effectue un test de connectivité ICMP (ping) vers une ou plusieurs machines
    et affiche le statut (réussite/échec) avec latence moyenne.

.PARAMETER Hosts
    Liste de noms d’hôtes ou adresses IP à tester.

.EXAMPLE
    .\Test-NetworkConnectivity.ps1 -Hosts @("8.8.8.8", "srv-dc01", "192.168.1.1")
#>

param (
    [string[]]$Hosts = @("8.8.8.8", "localhost")
)

foreach ($host in $Hosts) {
    $result = Test-Connection -ComputerName $host -Count 2 -Quiet
    if ($result) {
        $avg = (Test-Connection -ComputerName $host -Count 2 | Measure-Object -Property ResponseTime -Average).Average
        Write-Host "✅ $host est joignable - Moyenne ${avg}ms" -ForegroundColor Green
    } else {
        Write-Host "❌ $host est injoignable" -ForegroundColor Red
    }
}
