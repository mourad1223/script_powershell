<#
.SYNOPSIS
    Affiche les sessions SMB actives sur un serveur.

.DESCRIPTION
    Ce script affiche les connexions utilisateurs actives vers les partages SMB
    pour surveiller l’activité sur un serveur de fichiers.

.PARAMETER Server
    Nom du serveur de fichiers.

.EXAMPLE
    .\Get-OpenSessions.ps1 -Server "SRV-FICHIER01"
#>

param (
    [string]$Server = "localhost"
)

Invoke-Command -ComputerName $Server -ScriptBlock {
    Get-SmbSession | Select-Object ClientComputerName, ClientUserName, NumOpens, SessionId
}
