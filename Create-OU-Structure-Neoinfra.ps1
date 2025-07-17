<#
.SYNOPSIS
    Script de création d'une arborescence Active Directory pour la PME industrielle "neoinfra.fr".

.DESCRIPTION
    Ce script crée automatiquement une structure d'OU hiérarchisée adaptée à une PME de 100 utilisateurs,
    en séparant les services, les ressources techniques, les groupes de sécurité et les serveurs.

.NOTES
    Auteur : ChatGPT / OpenAI
    Domaine cible : neoinfra.fr
    Exécuter en tant qu'administrateur avec les outils RSAT installés.
#>

# Charger le module AD (si ce n’est pas déjà fait)
Import-Module ActiveDirectory

# Récupérer le DistinguishedName du domaine courant
$baseDN = (Get-ADDomain).DistinguishedName

Write-Host "`n--- Création des OU racines ---`n"

# Création des OU de niveau racine
$rootOUs = @(
    "_Ressources",
    "Utilisateurs",
    "GroupesSécurité",
    "GroupesDistribution",
    "Serveurs"
)

foreach ($ou in $rootOUs) {
    $ouPath = "OU=$ou,$baseDN"
    if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$ouPath'" -ErrorAction SilentlyContinue)) {
        Write-Host "Création de l'OU racine : $ou"
        New-ADOrganizationalUnit -Name $ou -Path $baseDN -ProtectedFromAccidentalDeletion $true
    } else {
        Write-Host "✔️ L'OU existe déjà : $ou"
    }
}

Write-Host "`n--- Création des sous-OU ---`n"

# Dictionnaire des sous-OU à créer sous chaque OU racine
$subOUs = @{
    "_Ressources" = @("Ordinateurs", "Groupes", "Imprimantes", "Services")
    "Utilisateurs" = @("Direction", "RH", "Finance", "Production", "Qualité", "IT", "Commerciaux")
    "GroupesSécurité" = @("AccèsPartages", "GroupesGPO")
    "GroupesDistribution" = @("TousUtilisateurs", "Direction", "Production")
    "Serveurs" = @("ContrôleursDeDomaine", "Fichiers")
}

# Boucle de création des sous-OU
foreach ($parent in $subOUs.Keys) {
    foreach ($child in $subOUs[$parent]) {
        $parentPath = "OU=$parent,$baseDN"
        $childPath = "OU=$child,$parentPath"
        if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$childPath'" -ErrorAction SilentlyContinue)) {
            Write-Host "Création de l'OU : $child sous $parent"
            New-ADOrganizationalUnit -Name $child -Path $parentPath -ProtectedFromAccidentalDeletion $true
        } else {
            Write-Host "✔️ L'OU existe déjà : $child sous $parent"
        }
    }
}

Write-Host "`n✅ Structure Active Directory créée avec succès !" -ForegroundColor Green
