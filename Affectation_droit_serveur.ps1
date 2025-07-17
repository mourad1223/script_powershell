<#
.SYNOPSIS
    Crée des dossiers, partages SMB et applique les droits NTFS pour une liste de services dans un environnement Active Directory.

.DESCRIPTION
    Ce script est générique et peut être utilisé dans tout environnement Active Directory.
    Il prend en charge la création de dossiers, de partages SMB, et l'application de droits NTFS basés sur des groupes AD nommés dynamiquement.

.PARAMETER BasePath
    Chemin de base où seront créés les dossiers (ex : E:\Partages)

.PARAMETER Services
    Liste des services à traiter (ex : "IT", "RH", "FINANCE")

.PARAMETER SharePrefix
    Préfixe pour nommer les partages (ex : "PARTAGE_")

.PARAMETER GroupPrefix
    Préfixe pour les noms de groupes AD (ex : "DL_")

.PARAMETER GroupSuffix
    Suffixe pour les noms de groupes AD (ex : "_PARTAGE")

.EXAMPLE
    .\CreateShares.ps1 -BasePath "D:\Shares" -Services @("IT", "RH")

.NOTES
    Auteur : Ton Nom
    GitHub : https://github.com/ton-compte/CreateShares
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$BasePath,

    [Parameter(Mandatory = $true)]
    [string[]]$Services,

    [string]$SharePrefix = "PARTAGE_",
    [string]$GroupPrefix = "DL_",
    [string]$GroupSuffix = "_PARTAGE"
)

Import-Module ActiveDirectory

# Obtenir dynamiquement le nom du domaine courant
$Domain = (Get-ADDomain).DNSRoot

function Create-ShareAndPermissions {
    param (
        [string]$Service
    )

    $folderPath = Join-Path $BasePath $Service
    $shareName = "$SharePrefix$Service"
    $groupName = "$GroupPrefix$Service$GroupSuffix"

    # Créer le dossier si inexistant
    if (-not (Test-Path $folderPath)) {
        New-Item -Path $folderPath -ItemType Directory | Out-Null
        Write-Host "📁 Dossier créé : $folderPath"
    }

    # Créer le partage si inexistant
    if (-not (Get-SmbShare -Name $shareName -ErrorAction SilentlyContinue)) {
        New-SmbShare -Name $shareName -Path $folderPath `
            -FullAccess "Administrators" `
            -ChangeAccess "$Domain\$groupName" `
            -ReadAccess "Everyone"

        Write-Host "🔗 Partage créé : $shareName → $folderPath"
    } else {
        Write-Host "⚠️ Partage déjà existant : $shareName"
    }

    # Appliquer les droits NTFS si le groupe existe
    if (Get-ADGroup -Filter "Name -eq '$groupName'") {
        $acl = Get-Acl $folderPath

        $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
            "$Domain\$groupName",
            "Modify",
            "ContainerInherit,ObjectInherit",
            "None",
            "Allow"
        )

        $acl.SetAccessRule($accessRule)
        Set-Acl -Path $folderPath -AclObject $acl

        Write-Host "🔐 Droits NTFS appliqués pour $groupName sur $folderPath"
    } else {
        Write-Warning "🚫 Groupe AD introuvable : $groupName"
    }
}

# Traitement de chaque service
foreach ($service in $Services) {
    Create-ShareAndPermissions -Service $service
}

Write-Host "`n✅ Traitement terminé avec succès." -ForegroundColor Green
