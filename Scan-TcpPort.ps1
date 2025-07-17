<#
.SYNOPSIS
    Vérifie l’ouverture de ports TCP sur un ou plusieurs hôtes.

.DESCRIPTION
    Utilise un TcpClient pour tester la connectivité à distance sur les ports spécifiés.

.PARAMETER Host
    Nom d’hôte ou IP cible.

.PARAMETER Ports
    Liste des ports à tester.

.EXAMPLE
    .\Scan-TcpPort.ps1 -Host "dc01" -Ports 80, 443, 3389
#>

param (
    [string]$Host = "localhost",
    [int[]]$Ports = @(80, 443, 3389)
)

foreach ($port in $Ports) {
    $tcp = New-Object System.Net.Sockets.TcpClient
    try {
        $tcp.Connect($Host, $port)
        if ($tcp.Connected) {
            Write-Host "✅ Port $port ouvert sur $Host" -ForegroundColor Green
        }
        $tcp.Close()
    } catch {
        Write-Host "❌ Port $port fermé sur $Host" -ForegroundColor Red
    }
}
