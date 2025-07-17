Import-Module ActiveDirectory

# Configuration
$basePath = "E:\Partages"
$domain = "neoinfra.fr"
$services = @("COMMERCIAL", "PREPRESSE", "PRODUCTION", "MAINTENANCE", "RH", "DIRECTION", "COMMUN")

# Créer les dossiers et les partager
foreach ($service in $services) {
    $folderPath = Join-Path $basePath $service
    $shareName = "PARTAGE_$service"
    $groupName = "DL_${service}_PARTAGE"

    # Créer le dossier si inexistant
    if (-not (Test-Path $folderPath)) {
        New-Item -Path $folderPath -ItemType Directory | Out-Null
        Write-Host "📁 Dossier créé : $folderPath"
    }

    # Créer le partage (si non existant)
    if (-not (Get-SmbShare -Name $shareName -ErrorAction SilentlyContinue)) {
        New-SmbShare -Name $shareName -Path $folderPath -FullAccess "Administrators" -ChangeAccess "$domain\$groupName" -ReadAccess "Everyone"
        Write-Host "🔗 Partage créé : $shareName → $folderPath"
    } else {
        Write-Host "⚠️ Partage déjà existant : $shareName"
    }

    # Attribuer les droits NTFS (si le groupe existe)
    if (Get-ADGroup -Filter "Name -eq '$groupName'") {
        $acl = Get-Acl $folderPath

        # Créer une nouvelle règle d'autorisation
        $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
            "$domain\$groupName",
            "Modify",
            "ContainerInherit,ObjectInherit",
            "None",
            "Allow"
        )

        $acl.SetAccessRule($accessRule)
        Set-Acl -Path $folderPath -AclObject $acl

        Write-Host "🔐 Droits NTFS appliqués pour $groupName sur $folderPath"
    } else {
        Write-Warning "🚫 Groupe $groupName introuvable dans l'AD. Vérifie sa création."
    }
}

Write-Host "`n🎯 Tous les partages ont été créés et configurés avec succès." -ForegroundColor Green
