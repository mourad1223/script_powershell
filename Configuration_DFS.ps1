<#
.SYNOPSIS
    Configure un namespace DFS, ajoute les cibles, et met en place la réplication DFS-R entre plusieurs serveurs.

.DESCRIPTION
    Ce script crée :
    - Un namespace DFS domaine
    - Des dossiers cibles (folder targets) pour chaque partage
    - Des groupes de réplication DFS-R
    - Les membres, connexions et chemins locaux pour la réplication

.PARAMETER Servers
    Liste des serveurs hébergeant les partages DFS

.PARAMETER DomainNamespace
    Chemin DFS du namespace (ex : \\domain.local\Partages)

.PARAMETER Shares
    Liste des noms de partages DFS (et dossiers) à configurer

.PARAMETER LocalPathRoot
    Racine locale des dossiers partagés sur chaque serveur (ex : E:\Partages)

.EXAMPLE
    .\Setup-DfsStructure.ps1 -Servers @("FS01", "FS02") -DomainNamespace "\\domain.local\Partages" -Shares @("RH", "IT") -LocalPathRoot "D:\Shares"

.NOTES
    Auteur : Ton Nom
    GitHub : https://github.com/ton-compte/Setup-DfsStructure
#>

param (
    [Parameter(Mandatory = $true)]
    [string[]]$Servers,

    [Parameter(Mandatory = $true)]
    [string]$DomainNamespace,

    [Parameter(Mandatory = $true)]
    [string[]]$Shares,

    [Parameter(Mandatory = $true)]
    [string]$LocalPathRoot
)

# 1. Créer le namespace DFS
Write-Host "🛠️ Création du namespace DFS domaine $DomainNamespace ..."
try {
    New-DfsNamespace -Name ($DomainNamespace.Split('\')[-1]) -Path $DomainNamespace -Type DomainV2 -ErrorAction Stop
    Write-Host "✅ Namespace DFS créé."
} catch {
    Write-Warning "⚠️ Namespace DFS déjà existant ou erreur : $_"
}

# 2. Ajouter les cibles dans le namespace
foreach ($share in $Shares) {
    $folderPath = "$DomainNamespace\$share"
    Write-Host "`n📁 Traitement du partage DFS : $folderPath"

    foreach ($server in $Servers) {
        $targetPath = "\\$server\PARTAGE_$share"
        try {
            $existingTargets = Get-DfsnFolderTarget -Path $folderPath -ErrorAction SilentlyContinue
            if ($existingTargets -and $existingTargets.TargetPath -contains $targetPath) {
                Write-Host "   ➖ Cible déjà présente : $targetPath"
            } else {
                Add-DfsnFolderTarget -Path $folderPath -TargetPath $targetPath -ErrorAction Stop
                Write-Host "   ✅ Cible ajoutée : $targetPath"
            }
        } catch {
            Write-Warning "   ❌ Erreur ajout cible $targetPath : $_"
        }
    }
}

# 3. Configurer la réplication DFS-R
foreach ($share in $Shares) {
    $rgName = "RG_$share"
    Write-Host "`n🔄 Configuration DFS-R pour $share (groupe $rgName)"

    # Créer le groupe
    try {
        New-DfsReplicationGroup -GroupName $rgName -ErrorAction Stop
        Write-Host "   ✅ Groupe DFS-R $rgName créé."
    } catch {
        Write-Warning "   ⚠️ Groupe $rgName déjà existant ou erreur : $_"
    }

    # Ajouter les membres
    foreach ($server in $Servers) {
        try {
            Add-DfsrMember -GroupName $rgName -ComputerName $server -ErrorAction Stop
            Write-Host "   ➕ $server ajouté à $rgName"
        } catch {
            Write-Warning "   ⚠️ $server déjà membre ou erreur : $_"
        }
    }

    # Créer le dossier répliqué
    try {
        New-DfsReplicatedFolder -GroupName $rgName -FolderName $share -ErrorAction Stop
        Write-Host "   ✅ Dossier répliqué $share créé"
    } catch {
        Write-Warning "   ⚠️ Dossier $share déjà présent ou erreur : $_"
    }

    # Ajouter connexions de réplication bidirectionnelles
    for ($i = 0; $i -lt $Servers.Count; $i++) {
        for ($j = 0; $j -lt $Servers.Count; $j++) {
            if ($i -ne $j) {
                try {
                    Add-DfsrConnection -GroupName $rgName -SourceComputerName $Servers[$i] -DestinationComputerName $Servers[$j] -ErrorAction Stop
                    Write-Host "   🔁 Connexion ajoutée : $($Servers[$i]) ➝ $($Servers[$j])"
                } catch {
                    Write-Warning "   ⚠️ Connexion déjà existante ou erreur : $_"
                }
            }
        }
    }

    # Configurer les chemins locaux
    foreach ($server in $Servers) {
        $localPath = Join-Path $LocalPathRoot $share
        try {
            Set-DfsrMembership -GroupName $rgName -FolderName $share -ComputerName $server -LocalPath $localPath -ErrorAction Stop
            Write-Host "   🗂️ Chemin local défini : $server ➝ $localPath"
        } catch {
            Write-Warning "   ❌ Erreur chemin local sur $server : $_"
        }
    }
}

Write-Host "`n🎯 Configuration DFS terminée avec succès." -ForegroundColor Green
