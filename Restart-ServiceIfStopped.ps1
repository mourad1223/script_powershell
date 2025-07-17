<#
.SYNOPSIS
    Redémarre un service s’il est arrêté sur un ou plusieurs serveurs.

.DESCRIPTION
    Ce script vérifie l’état d’un service donné sur une liste de serveurs.
    Si le service est arrêté, il tente de le démarrer.

.PARAMETER ServiceName
    Nom du service à contrôler (ex: "Spooler").

.PARAMETER Servers
    Liste des serveurs distants à cibler.

.EXAMPLE
    .\Restart-ServiceIfStopped.ps1 -ServiceName "W32Time" -Servers @("DC01", "FS01")
#>

param(
    [string]$ServiceName = "Spooler",
    [string[]]$Servers = @("localhost")
)

foreach ($server in $Servers) {
    Write-Host "`n🔧 Vérification du service '$ServiceName' sur $server" -ForegroundColor Yellow
    Invoke-Command -ComputerName $server -ScriptBlock {
        param($ServiceName)
        $svc = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
        if ($null -eq $svc) {
            Write-Output "❌ Service '$ServiceName' introuvable sur $env:COMPUTERNAME"
        } elseif ($svc.Status -ne "Running") {
            Write-Output "🔁 Service arrêté, tentative de démarrage..."
            Start-Service -Name $ServiceName
            Start-Sleep -Seconds 2
            Get-Service -Name $ServiceName
        } else {
            Write-Output "✅ Service déjà en cours d'exécution."
        }
    } -ArgumentList $ServiceName
}
