$groups = @(
    @{Group="RG_MAINTENANCE"; Folder="MAINTENANCE"},
    @{Group="RG_RH"; Folder="RH"},
    @{Group="RG_DIRECTION"; Folder="DIRECTION"},
    @{Group="RG_COMMUN"; Folder="COMMUN"}
)

foreach ($g in $groups) {
    Write-Host "Suppression du dossier répliqué : $($g.Folder)"
    Remove-DfsReplicatedFolder -GroupName $g.Group -FolderName $g.Folder -Confirm:$false
    Write-Host "✔️ Dossier supprimé : $($g.Folder)"
    
    Write-Host "Suppression du groupe de réplication : $($g.Group)"
    Remove-DfsReplicationGroup -GroupName $g.Group -Confirm:$false
    Write-Host "✔️ Groupe supprimé : $($g.Group)"
}
