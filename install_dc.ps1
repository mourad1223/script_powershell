<#
.SYNOPSIS
    Déploie un nouveau domaine Active Directory (AD DS) avec un contrôleur de domaine principal.

.DESCRIPTION
    Utilise le module ADDSDeployment pour installer un nouveau domaine dans une nouvelle forêt,
    avec options de configuration personnalisables.

.PARAMETER DomainName
    Nom DNS complet du domaine (ex : neoinfra.fr)

.PARAMETER NetbiosName
    Nom NetBIOS du domaine (ex : NEOINFRA)

.PARAMETER ForestMode
    Niveau fonctionnel de la forêt (ex : WinThreshold, Win2016, Win2012R2)

.PARAMETER DomainMode
    Niveau fonctionnel du domaine (ex : WinThreshold, Win2016, Win2012R2)

.PARAMETER InstallDNS
    Active ou non le rôle DNS en même temps

.PARAMETER DatabasePath
    Chemin du fichier NTDS.dit

.PARAMETER LogPath
    Chemin des journaux NTDS

.PARAMETER SysvolPath
    Répertoire SYSVOL

.EXAMPLE
    .\Deploy-ADDSForest.ps1 -DomainName "neoinfra.fr" -NetbiosName "NEOINFRA"

.NOTES
    Auteur : Ton Nom  
    GitHub : https://github.com/ton-compte/Deploy-ADDSForest
    Nécessite une machine propre avec Windows Server et RSAT
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$DomainName,

    [Parameter(Mandatory = $true)]
    [string]$NetbiosName,

    [string]$ForestMode = "WinThreshold",
    [string]$DomainMode = "WinThreshold",

    [bool]$InstallDNS = $true,

    [string]$DatabasePath = "C:\Windows\NTDS",
    [string]$LogPath = "C:\Windows\NTDS",
    [string]$SysvolPath = "C:\Windows\SYSVOL"
)

Import-Module ADDSDeployment

Install-ADDSForest `
    -CreateDnsDelegation:$false `
    -DatabasePath $DatabasePath `
    -DomainMode $DomainMode `
    -DomainName $DomainName `
    -DomainNetbiosName $NetbiosName `
    -ForestMode $ForestMode `
    -InstallDns:$InstallDNS `
    -LogPath $LogPath `
    -SysvolPath $SysvolPath `
    -NoRebootOnCompletion:$false `
    -Force:$true
