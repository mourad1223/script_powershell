<#
.SYNOPSIS
    Audite les partages SMB, les droits SMB/NTFS, et l’accessibilité réseau sur une ou plusieurs machines distantes.

.DESCRIPTION
    Pour chaque serveur spécifié :
    - Récupère les partages SMB via CIM
    - Affiche les chemins et droits SMB
    - Lit les ACL NTFS locales du dossier partagé
    - Tente un accès réseau UNC (Test-Path)

.PARAMETER Servers
    Liste des noms d’hôtes à auditer (ex: "srv-fs01", "srv-fs02")

.EXAMPLE
    .\Audit-SmbShares.ps1 -Servers @("fs01", "fs02")

.NOTES
    Auteur : Ton Nom
    GitHub : https://github.com/ton-compte/AuditSmbShares
#>

param (
    [Parameter(Mandatory = $true)]
    [string[]]$Servers
)

foreach ($server in $Servers) {
    Write-Host "`n=== Serveur : $server ===`n"

    # Récupérer les partages SMB
    try {
        $shares = Get-SmbShare -CimSession $server -ErrorAction Stop
    } catch {
        Write-Warning "❌ Impossible de récupérer les partages sur $server : $_"
        continue
    }

    foreach ($share in $shares) {
        Write-Host "📁 Partage SMB : $($share.Name)"
        Write-Host "   📂 Chemin local : $($share.Path)"

        # Droits SMB
        try {
            $shareAccess = Get-SmbShareAccess -Name $share.Name -CimSession $server -ErrorAction Stop
            Write-Host "   🔐 Droits SMB :"
            foreach ($access in $shareAccess) {
                Write-Host "     $($access.AccountName) : $($access.AccessControlType) ($($access.AccessRight))"
            }
        } catch {
            Write-Warning "   ⚠️ Impossible de récupérer les droits SMB pour $($share.Name)"
        }

        # Droits NTFS
        try {
            $acl = Get-Acl -Path $share.Path -ErrorAction Stop
            Write-Host "   🔐 Droits NTFS :"
            foreach ($rule in $acl.Access) {
                Write-Host "     $($rule.IdentityReference) : $($rule.FileSystemRights) ($($rule.AccessControlType))"
            }
        } catch {
            Write-Warning "   ⚠️ Impossible de récupérer les droits NTFS sur $($share.Path)"
        }

        # Test accès réseau
        $uncPath = "\\$server\$($share.Name)"
        Write-Host "   🔎 Test accès réseau ($uncPath) :"
        try {
            if (Test-Path $uncPath) {
                Write-Host "     ✅ Accès OK"
            } else {
                Write-Warning "     ❌ Accès refusé ou non disponible"
            }
        } catch {
            Write-Warning "     ⚠️ Erreur lors du test d'accès : $_"
        }

        Write-Host ""
    }
}

Write-Host "`n🎯 Audit terminé pour tous les serveurs." -ForegroundColor Green
