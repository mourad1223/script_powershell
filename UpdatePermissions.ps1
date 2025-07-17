# Variables
$userToRemove = "NEOINFRA\b.beugre"
$domainAdmin = "NEOINFRA\Administrateur"

# Liste des partages SMB et chemins NTFS correspondants
$sharesAndPaths = @{
    "partages"              = "E:\partages"
    "PARTAGE_COMMERCIAL"    = "E:\Partages\COMMERCIAL"
    "PARTAGE_COMMUN"        = "E:\Partages\COMMUN"
    "PARTAGE_DIRECTION"     = "E:\Partages\DIRECTION"
    "PARTAGE_MAINTENANCE"   = "E:\Partages\MAINTENANCE"
    "PARTAGE_PREPRESSE"     = "E:\Partages\PREPRESSE"
    "PARTAGE_PRODUCTION"    = "E:\Partages\PRODUCTION"
    "PARTAGE_RH"            = "E:\Partages\RH"
}

# Fonction pour gérer les permissions SMB
function Update-SmbShareAccess {
    param(
        [string]$shareName,
        [string]$userToRemove,
        [string]$userToAdd
    )

    Write-Output "Traitement SMB du partage : $shareName"

    # Supprimer utilisateur à retirer (silencieux si pas trouvé)
    try {
        Revoke-SmbShareAccess -Name $shareName -AccountName $userToRemove -Force -ErrorAction Stop
        Write-Output "Retiré $userToRemove des permissions SMB sur $shareName"
    } catch {
        Write-Output "$userToRemove non présent dans $shareName, pas de suppression nécessaire"
    }

    # Ajouter administrateur domaine avec Full
    try {
        Grant-SmbShareAccess -Name $shareName -AccountName $userToAdd -AccessRight Full -Force
        Write-Output "Ajouté $userToAdd avec droits Full sur $shareName"
    } catch {
        Write-Error "Erreur lors de l'ajout de $userToAdd sur $shareName : $_"
    }
}

# Fonction pour gérer les permissions NTFS
function Update-NtfsPermissions {
    param(
        [string]$path,
        [string]$userToRemove,
        [string]$userToAdd
    )

    Write-Output "Traitement NTFS du dossier : $path"

    if (-Not (Test-Path $path)) {
        Write-Warning "Le chemin $path n'existe pas, passage au suivant."
        return
    }

    $acl = Get-Acl -Path $path

    # Retirer les règles du user à supprimer
    $rulesToRemove = $acl.Access | Where-Object { $_.IdentityReference -eq $userToRemove }
    foreach ($rule in $rulesToRemove) {
        $acl.RemoveAccessRule($rule)
        Write-Output "Retiré $userToRemove des permissions NTFS sur $path"
    }

    # Ajouter administrateur domaine avec FullControl, héritage activé
    $inheritFlags = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit,ObjectInherit"
    $propagationFlags = [System.Security.AccessControl.PropagationFlags]::None
    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($userToAdd, "FullControl", $inheritFlags, $propagationFlags, "Allow")
    $acl.AddAccessRule($accessRule)

    # Appliquer les changements
    try {
        Set-Acl -Path $path -AclObject $acl
        Write-Output "Ajouté $userToAdd avec FullControl sur $path"
    } catch {
        Write-Error "Erreur lors de la modification des permissions NTFS sur $path : $_"
    }
}

# Exécution des mises à jour
foreach ($share in $sharesAndPaths.Keys) {
    $path = $sharesAndPaths[$share]

    Update-SmbShareAccess -shareName $share -userToRemove $userToRemove -userToAdd $domainAdmin
    Update-NtfsPermissions -path $path -userToRemove $userToRemove -userToAdd $domainAdmin
}

Write-Output "Script terminé."
