<#
.SYNOPSIS
    Supprime un utilisateur d'une liste de partages SMB et de dossiers NTFS, puis ajoute un autre utilisateur (par défaut un compte admin).

.DESCRIPTION
    Pour chaque partage défini, le script :
    - Supprime les droits SMB et NTFS de l'utilisateur ciblé
    - Ajoute un utilisateur de remplacement (avec droits complets)
    - S'assure que les chemins existent avant traitement

.PARAMETER UserToRemove
    Nom de l'utilisateur à retirer des permissions (ex : "DOMAIN\user")

.PARAMETER UserToAdd
    Nom du compte à ajouter (avec droits complets) (ex : "DOMAIN\Admin")

.PARAMETER ShareAndPathMap
    Dictionnaire des partages SMB (clés) et leurs chemins NTFS (valeurs)

.EXAMPLE
    $map = @{
        "PARTAGE_IT" = "E:\Partages\IT"
        "PARTAGE_RH" = "E:\Partages\RH"
    }

    .\Update-ShareAndNtfsPermissions.ps1 -UserToRemove "DOMAIN\user1" -UserToAdd "DOMAIN\Administrateur" -ShareAndPathMap $map

.NOTES
    Auteur : Ton Nom  
    GitHub : https://github.com/ton-compte/Update-ShareAndNtfsPermissions
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$UserToRemove,

    [Parameter(Mandatory = $true)]
    [string]$UserToAdd,

    [Parameter(Mandatory = $true)]
    [hashtable]$ShareAndPathMap
)

function Update-SmbShareAccess {
    param(
        [string]$ShareName,
        [string]$UserToRemove,
        [string]$UserToAdd
    )

    Write-Output "`n🔧 Traitement SMB du partage : $ShareName"

    try {
        Revoke-SmbShareAccess -Name $ShareName -AccountName $UserToRemove -Force -ErrorAction Stop
        Write-Output "   ❌ Supprimé $UserToRemove des droits SMB"
    } catch {
        Write-Output "   ℹ️ $UserToRemove non présent sur $ShareName"
    }

    try {
        Grant-SmbShareAccess -Name $ShareName -AccountName $UserToAdd -AccessRight Full -Force
        Write-Output "   ✅ Ajouté $UserToAdd avec droits Full SMB"
    } catch {
        Write-Warning "   ❌ Erreur ajout $UserToAdd sur $ShareName → $_"
    }
}

function Update-NtfsPermissions {
    param(
        [string]$Path,
        [string]$UserToRemove,
        [string]$UserToAdd
    )

    Write-Output "🔧 Traitement NTFS sur : $Path"

    if (-not (Test-Path $Path)) {
        Write-Warning "   ⚠️ Chemin $Path introuvable. Ignoré."
        return
    }

    try {
        $acl = Get-Acl -Path $Path

        # Supprimer les règles existantes
        $toRemove = $acl.Access | Where-Object { $_.IdentityReference -eq $UserToRemove }
        foreach ($rule in $toRemove) {
            $acl.RemoveAccessRule($rule) | Out-Null
            Write-Output "   ❌ Supprimé $UserToRemove des droits NTFS"
        }

        # Ajouter nouvel utilisateur
        $inherit = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit,ObjectInherit"
        $prop = [System.Security.AccessControl.PropagationFlags]::None
        $newRule = New-Object System.Security.AccessControl.FileSystemAccessRule($UserToAdd, "FullControl", $inherit, $prop, "Allow")
        $acl.AddAccessRule($newRule)

        Set-Acl -Path $Path -AclObject $acl
        Write-Output "   ✅ Ajouté $UserToAdd avec FullControl"
    } catch {
        Write-Warning "   ❌ Erreur permissions NTFS sur $Path → $_"
    }
}

# Execution
foreach ($share in $ShareAndPathMap.Keys) {
    $path = $ShareAndPathMap[$share]

    Update-SmbShareAccess -ShareName $share -UserToRemove $UserToRemove -UserToAdd $UserToAdd
    Update-NtfsPermissions -Path $path -UserToRemove $UserToRemove -UserToAdd $UserToAdd
}

Write-Host "`n✅ Script terminé." -ForegroundColor Green
