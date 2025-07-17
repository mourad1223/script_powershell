# Définir le chemin racine
$basePath = "E:\Partages"

# Liste des dossiers à créer
$dossiers = @(
    "COMMERCIAL",
    "PREPRESSE",
    "PRODUCTION",
    "MAINTENANCE",
    "RH",
    "DIRECTION",
    "COMMUN"
)

# Créer le dossier racine si nécessaire
if (-not (Test-Path $basePath)) {
    New-Item -Path $basePath -ItemType Directory | Out-Null
    Write-Host "📁 Dossier racine créé : $basePath"
}

# Créer les sous-dossiers
foreach ($dossier in $dossiers) {
    $fullPath = Join-Path $basePath $dossier
    if (-not (Test-Path $fullPath)) {
        New-Item -Path $fullPath -ItemType Directory | Out-Null
        Write-Host "✅ Dossier créé : $fullPath"
    } else {
        Write-Host "⚠️ Dossier déjà existant : $fullPath"
    }
}

Write-Host "`n🎉 Arborescence de dossiers créée avec succès." -ForegroundColor Green
