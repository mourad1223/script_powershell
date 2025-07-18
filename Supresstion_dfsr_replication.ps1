<#
.SYNOPSIS
    Supprime des dossiers répliqués DFS-R et leurs groupes de réplication associés.

.DESCRIPTION
    Ce script prend une liste d’objets avec les noms de groupes DFS-R et les noms des dossiers répliqués,
    puis supprime ces dossiers répliqués ainsi que les groupes, si présents.

.PARAMETER ReplicationItems
    Liste d’objets contenant :
      - Group (nom du groupe de réplication)
      - Folder (nom du dossier DFS-R à supprimer)

.EXAMPLE
    $items = @(
        @{ Group = "RG_IT"; Folder = "IT" },
        @{ Group = "RG_RH"; Folder = "RH" }
    )
    .\Remove-DfsReplication.ps1 -ReplicationItems $items

.NOTES
    Auteur : Ton Nom  
    GitHub : https://github.com/ton-compte/Remove-DfsReplication
#>

param (
    [Parameter(Mandatory = $true)]
    [array]$ReplicationItems
)

Import-Module DFSR

foreach ($item in $ReplicationItems) {
    $group = $item.Group
    $folder = $item.Folder

    Write-Host "`n🔍 Traitement de : Groupe = $group | Dossier = $folder" -ForegroundColor Cyan

    # Supprimer le dossier répliqué si présent
    try {
        $folderExists = Get-DfsReplicatedFolder -GroupName $group -FolderName $folder -ErrorAction Stop
        if ($folderExists) {
            Remove-DfsReplicatedFolder -GroupName $group -FolderName $folder -Confirm:$false
            Write-Host "🗑️ Dossier répliqué supprimé : $folder"
        }
    } catch {
        Write-Warning "⚠️ Aucun dossier répliqué trouvé ou erreur pour : $folder → $($_.Exception.Message)"
    }

    # Supprimer le groupe de réplication
    try {
        $groupExists = Get-DfsReplicationGroup -GroupName $group -ErrorAction Stop
        if ($groupExists) {
            Remove-DfsReplicationGroup -GroupName $group -Confirm:$false
            Write-Host "🗑️ Groupe de réplication supprimé : $group"
        }
    } catch {
        Write-Warning "⚠️ Aucun groupe trouvé ou erreur pour : $group → $($_.Exception.Message)"
    }
}

Write-Host "`n✅ Nettoyage terminé." -ForegroundColor Green
