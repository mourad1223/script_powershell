<#
.SYNOPSIS
    Crée automatiquement des groupes AD (Global + DomainLocal) pour chaque service spécifié,
    et établit les liens entre eux selon le modèle AGDLP.

.DESCRIPTION
    Pour chaque service :
    - Crée un groupe Global (G_<service>)
    - Crée un groupe DomainLocal (DL_<service>_PARTAGE)
    - Ajoute le groupe global dans le domaine local

.PARAMETER DomainName
    Nom DNS du domaine (ex: "entreprise.local")

.PARAMETER GroupOU
    OU cible pour créer les groupes (DN complet, ex: "OU=Groupes,DC=entreprise,DC=local")

.PARAMETER Services
    Liste des services pour lesquels créer les groupes

.EXAMPLE
    .\Create-AdGroups.ps1 -DomainName "entreprise.local" -GroupOU "OU=Groupes,DC=entreprise,DC=local" -Services @("IT", "HR", "COMM")

.NOTES
    Auteur : Ton Nom  
    GitHub : https://github.com/ton-compte/Create-AdGroups
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$DomainName,

    [Parameter(Mandatory = $true)]
    [string]$GroupOU,

    [Parameter(Mandatory = $true)]
    [string[]]$Services
)

Import-Module ActiveDirectory

# Vérification de l’OU "Groupes"
if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$GroupOU'" -ErrorAction SilentlyContinue)) {
    try {
        $ouName = ($GroupOU -split ",")[0].Replace("OU=", "")
        $ouPath = ($GroupOU -split ",", 2)[1]
        New-ADOrganizationalUnit -Name $ouName -Path $ouPath -ProtectedFromAccidentalDeletion $true
        Write-Host "📁 OU créée : $GroupOU"
    } catch {
        Write-Warning "❌ Impossible de créer l'OU : $GroupOU → $_"
        exit
    }
} else {
    Write-Host "📂 OU déjà existante : $GroupOU"
}

# Création des groupes pour chaque service
foreach ($service in $Services) {
    $groupGlobal = "G_$service"
    $groupLocal = "DL_${service}_PARTAGE"

    # Créer le groupe global
    if (-not (Get-ADGroup -Filter { Name -eq $groupGlobal })) {
        New-ADGroup -Name $groupGlobal -GroupScope Global -GroupCategory Security -Path $GroupOU
        Write-Host "✅ Groupe global créé : $groupGlobal"
    } else {
        Write-Host "✔️ Groupe global déjà existant : $groupGlobal"
    }

    # Créer le groupe domaine local
    if (-not (Get-ADGroup -Filter { Name -eq $groupLocal })) {
        New-ADGroup -Name $groupLocal -GroupScope DomainLocal -GroupCategory Security -Path $GroupOU
        Write-Host "✅ Groupe domaine local créé : $groupLocal"
    } else {
        Write-Host "✔️ Groupe domaine local déjà existant : $groupLocal"
    }

    # Ajouter le groupe global au groupe local
    try {
        Add-ADGroupMember -Identity $groupLocal -Members $groupGlobal -ErrorAction Stop
        Write-Host "🔁 Ajouté : $groupGlobal ➜ $groupLocal"
    } catch {
        Write-Warning "⚠️ $groupGlobal est peut-être déjà membre de $groupLocal → $_"
    }
}

Write-Host "`n✅ Création des groupes terminée." -ForegroundColor Green
