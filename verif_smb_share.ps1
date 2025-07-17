<#
.SYNOPSIS
    Compare les partages SMB personnalisés entre deux serveurs.

.DESCRIPTION
    Ce script récupère les partages SMB (hors administratifs comme C$, ADMIN$, etc.)
    sur deux serveurs et affiche les partages communs et ceux manquants sur chaque serveur.

.PARAMETER ServerA
    Le premier serveur à comparer.

.PARAMETER ServerB
    Le second serveur à comparer.

.PARAMETER SharePrefix
    Préfixe utilisé pour filtrer les partages (ex: "PARTAGE_").

.EXAMPLE
    .\Compare-SmbShares.ps1 -ServerA "Server1" -ServerB "Server2" -SharePrefix "PARTAGE_"
#>

param(
    [string]$ServerA = "Server1",
    [string]$ServerB = "Server2",
    [string]$SharePrefix = "PARTAGE_"
)

function Get-CustomShares {
    param (
        [string]$Server,
        [string]$Prefix
    )
    Invoke-Command -ComputerName $Server -ScriptBlock {
        param($Prefix)
        Get-SmbShare | Where-Object {
            $_.Name -like "$Prefix*"
        } | Select-Object -ExpandProperty Name
    } -ArgumentList $Prefix
}

# Récupération des partages
Write-Host "`n🔄 Récupération des partages SMB sur les serveurs..." -ForegroundColor Cyan
$SharesA = Get-CustomShares -Server $ServerA -Prefix $SharePrefix
$SharesB = Get-CustomShares -S
