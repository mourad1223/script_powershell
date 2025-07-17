<#
.SYNOPSIS
    Crée une arborescence de dossiers à partir d'une liste définie, dans un chemin racine donné.

.DESCRIPTION
    Pour chaque dossier spécifié dans la liste, le script :
    - Vérifie l'existence du dossier racine
    - Crée le sous-dossier s’il n’existe pas déjà
    - Affiche un message de confirmation

.PARAMETER BasePath
    Chemin racine où l’arborescence sera créée (ex: "D:\Partages")

.PARAMETER FolderNames
    Liste des noms de dossiers à créer sous le répertoire racine

.EXAMPLE
    .\Create-FolderStructure.ps1 -BasePath "E:\Partages" -FolderNames @("RH", "IT", "COMMUN")

.NOTES
    Auteur : Ton Nom  
    GitHub : https://github.com/ton-compte/Create-FolderStructure
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$BasePath,

    [Parameter(Mandatory = $true)]
    [string[]]$FolderNames
)

Write-Host "`n📂 Création de l’arborescence de dossiers..." -ForegroundColor Cyan

# Créer le dossier racine s’il n’existe pas
if (-not (Test-Path $BasePath)) {
    try {
        New-Item -Path $BasePath -ItemType Directory | Out-Null
        Write-Host "📁 Dossier racine créé : $BasePath"
    } catch {
        Write-Warning "❌ Impossible de créer le dossier racine : $_"
        exit
    }
} else {
    Write-Host "📂 Dossier racine déjà existant : $BasePath"
}

# Créer les sous-dossiers
foreach ($name in $FolderNames) {
    $fullPath = Join-Path $BasePath $name
    if (-not (Test-Path $fullPath)) {
        try {
            New-Item -Path $fullPath -ItemType Directory | Out-Null
            Write-Host "✅ Dossier créé : $fullPath"
        } catch {
            Write-Warning "❌ Erreur lors de la création de : $fullPath → $_"
        }
    } else {
        Write-Host "⚠️ Dossier déjà existant : $fullPath"
    }
}

Write-Host "`n🎉 Arborescence créée avec succès." -ForegroundColor Green
