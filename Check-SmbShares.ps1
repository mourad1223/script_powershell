param(
    [string[]]$Servers = @("w22-fichier01", "w22-fichier02")
)

foreach ($server in $Servers) {
    Write-Host "`n=== Serveur : $server ===`n"

    # Récupérer les partages SMB
    try {
        $shares = Get-SmbShare -CimSession $server -ErrorAction Stop
    } catch {
        Write-Warning "Impossible de récupérer les partages sur $server : $_"
        continue
    }

    foreach ($share in $shares) {
        Write-Host "Partage SMB : $($share.Name)"
        Write-Host "  Chemin local : $($share.Path)"

        # Droits SMB
        try {
            $shareAccess = Get-SmbShareAccess -Name $share.Name -CimSession $server -ErrorAction Stop
            Write-Host "  Droits SMB :"
            foreach ($access in $shareAccess) {
                Write-Host "    $($access.AccountName) : $($access.AccessControlType) ($($access.AccessRight))"
            }
        } catch {
            Write-Warning "  Impossible de récupérer les droits SMB pour $($share.Name) sur $server"
        }

        # Droits NTFS
        try {
            $acl = Get-Acl -Path $share.Path -ErrorAction Stop
            Write-Host "  Droits NTFS :"
            foreach ($rule in $acl.Access) {
                Write-Host "    $($rule.IdentityReference) : $($rule.FileSystemRights) ($($rule.AccessControlType))"
            }
        } catch {
            Write-Warning "  Impossible de récupérer les droits NTFS sur $($share.Path) sur $server"
        }

        # Test accès réseau
        $uncPath = "\\$server\$($share.Name)"
        Write-Host "  Test accès réseau ($uncPath) :"
        try {
            if (Test-Path $uncPath) {
                Write-Host "    Accès OK"
            } else {
                Write-Warning "    Accès refusé ou non disponible"
            }
        } catch {
            Write-Warning "    Erreur lors du test d'accès : $_"
        }

        Write-Host ""
    }
}
