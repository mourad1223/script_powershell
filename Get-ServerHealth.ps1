<#
.SYNOPSIS
    Affiche un résumé de la santé du serveur (CPU, RAM).

.DESCRIPTION
    Ce script interroge l’état des ressources matérielles de base sur un ou plusieurs serveurs :
    charge CPU moyenne, mémoire disponible et totale.

.PARAMETER Servers
    Liste des serveurs à auditer.

.EXAMPLE
    .\Get-ServerHealth.ps1 -Servers @("FS01", "DC02")
#>

param(
    [string[]]$Servers = @("localhost")
)

foreach ($server in $Servers) {
    Write-Host "`n📈 État du serveur $server" -ForegroundColor Cyan
    Invoke-Command -ComputerName $server -ScriptBlock {
        $cpu = Get-CimInstance Win32_Processor | Measure-Object -Property LoadPercentage -Average
        $ram = Get-CimInstance Win32_OperatingSystem
        $freeMemGB = [math]::Round($ram.FreePhysicalMemory / 1MB, 2)
        $totalMemGB = [math]::Round($ram.TotalVisibleMemorySize / 1MB, 2)

        [PSCustomObject]@{
            Server       = $env:COMPUTERNAME
            CPU_Load_%   = $cpu.Average
            RAM_Free_GB  = $freeMemGB
            RAM_Total_GB = $totalMemGB
            Time         = Get-Date
        }
    }
}
