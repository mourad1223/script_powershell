# Variables
$servers = @("w22-fichier01", "w22-fichier02")
$domainNamespace = "\\neoinfra.fr\Partages"
$shares = @(
    "COMMERCIAL",
    "PREPRESSE",
    "PRODUCTION",
    "MAINTENANCE",
    "RH",
    "DIRECTION",
    "COMMUN"
)
$localPathRoot = "E:\Partages"

# 1. Créer le namespace DFS domaine
Write-Host "Création du namespace DFS domaine $domainNamespace ..."
Try {
    New-DfsNamespace -Name "Partages" -Path $domainNamespace -Type DomainV2 -ErrorAction Stop
    Write-Host "Namespace DFS créé."
} Catch {
    Write-Warning "Namespace DFS déjà existant ou erreur : $_"
}

# 2. Ajouter les dossiers cibles (targets) dans le namespace DFS
foreach ($share in $shares) {
    $folderPath = "$domainNamespace\$share"
    Write-Host "Ajout des dossiers cibles DFS pour $folderPath ..."
    
    foreach ($server in $servers) {
        $targetPath = "\\$server\PARTAGE_$share"
        Try {
            # Ajout du dossier cible uniquement s'il n'existe pas déjà
            $existingTargets = Get-DfsnFolderTarget -Path $folderPath -ErrorAction SilentlyContinue
            if ($existingTargets -and $existingTargets.TargetPath -contains $targetPath) {
                Write-Host "Cible $targetPath déjà présente pour $folderPath"
            } else {
                Add-DfsnFolderTarget -Path $folderPath -TargetPath $targetPath -ErrorAction Stop
                Write-Host "Cible $targetPath ajoutée pour $folderPath"
            }
        } Catch {
            Write-Warning "Erreur lors de l'ajout de la cible $targetPath : $_"
        }
    }
}

# 3. Configurer la réplication DFS
foreach ($share in $shares) {
    $rgName = "RG_$share"
    Write-Host "Création du groupe de réplication $rgName ..."
    Try {
        New-DfsReplicationGroup -GroupName $rgName -ErrorAction Stop
        Write-Host "Groupe de réplication $rgName créé."
    } Catch {
        Write-Warning "Groupe $rgName déjà existant ou erreur : $_"
    }
    
    # Ajouter les membres
    foreach ($server in $servers) {
        Try {
            Add-DfsrMember -GroupName $rgName -ComputerName $server -ErrorAction Stop
            Write-Host "Serveur $server ajouté au groupe $rgName"
        } Catch {
            Write-Warning "Serveur $server déjà membre ou erreur : $_"
        }
    }

    # Créer le dossier répliqué
    Try {
        New-DfsReplicatedFolder -GroupName $rgName -FolderName $share -ErrorAction Stop
        Write-Host "Dossier répliqué $share créé dans $rgName"
    } Catch {
        Write-Warning "Dossier $share déjà présent dans $rgName ou erreur : $_"
    }

    # Ajouter les connexions entre serveurs
    Try {
        Add-DfsrConnection -GroupName $rgName -SourceComputerName $servers[0] -DestinationComputerName $servers[1] -ErrorAction Stop
        Add-DfsrConnection -GroupName $rgName -SourceComputerName $servers[1] -DestinationComputerName $servers[0] -ErrorAction Stop
        Write-Host "Connexions de réplication configurées pour $rgName"
    } Catch {
        Write-Warning "Erreur lors de la configuration des connexions : $_"
    }

    # Configurer les chemins locaux pour chaque membre
    foreach ($server in $servers) {
        $localPath = Join-Path $localPathRoot $share
        Try {
            Set-DfsrMembership -GroupName $rgName -FolderName $share -ComputerName $server -LocalPath $localPath -ErrorAction Stop
            Write-Host "Chemin local $localPath configuré pour $server dans $rgName"
        } Catch {
            Write-Warning "Erreur lors de la configuration du chemin local sur $server : $_"
        }
    }
}

Write-Host "=== Configuration DFS terminée ==="
