<#
.SYNOPSIS
    Ajoute automatiquement les utilisateurs d’une OU dans un groupe AD correspondant.

.DESCRIPTION
    Pour chaque service (ex : "RH"), ce script :
    - Recherche l’OU "OU=RH,<BaseDN>"
    - Récupère tous les utilisateurs de cette OU
    - Ajoute ces utilisateurs dans le groupe global nommé "G_RH"

.PARAMETER BaseDN
    DN de base du domaine (ex: "DC=entreprise,DC=local")

.PARAMETER Services
    Liste des OUs à traiter (ex: "RH", "IT", "PRODUCTION")

.PARAMETER GroupPrefix
    Préfixe pour les noms de groupes (défaut: "G_")

.EXAMPLE
    .\AddUsersToGroups.ps1 -BaseDN "DC=entreprise,DC=local" -Services @("RH", "IT")

.NOTES
    Auteur : Ton Nom
    GitHub : https://github.com/ton-compte/AddUsersToGroups
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$BaseDN,

    [Parameter(Mandatory = $true)]
    [string[]]$Services,

    [string]$GroupPrefix = "G_"
)

Import-Module ActiveDirectory

foreach ($service in $Services) {
    $ouPath = "OU=$service,$BaseDN"
    $groupName = "$GroupPrefix$service"

    # Vérifie si le groupe existe
    if (-not (Get-ADGroup -Filter { Name -eq $groupName })) {
        Write-Warning "🚫 Groupe $groupName introuvable. Ignoré pour ce service."
        continue
    }

    # Récupérer les utilisateurs dans l'OU
    try {
        $users = Get-ADUser -SearchBase $ouPath -Filter * -Properties SamAccountName
    } catch {
        Write-Warning "⚠️ Erreur lors de la lecture de l'OU : $ouPath → $($_.Exception.Message)"
        continue
    }

    foreach ($user in $users) {
        try {
            Add-ADGroupMember -Identity $groupName -Members $user.SamAccountName -ErrorAction Stop
            Write-Host "✅ $($user.SamAccountName) ajouté à $groupName"
        } catch {
            Write-Warning "⚠️ Erreur avec $($user.SamAccountName) → $($_.Exception.Message)"
        }
    }
}

Write-Host "`n🎯 Traitement terminé avec succès." -ForegroundColor Green
