Import-Module ActiveDirectory

# Configuration
$domain = "neoinfra.fr"
$ouGroupes = "OU=Groupes,DC=neoinfra,DC=fr"  # OU cible pour les groupes

# Vérifier si l'OU existe, sinon la créer
if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$ouGroupes'" -ErrorAction SilentlyContinue)) {
    New-ADOrganizationalUnit -Name "Groupes" -Path "DC=neoinfra,DC=fr"
    Write-Host "📁 OU 'Groupes' créée."
} else {
    Write-Host "📂 OU 'Groupes' existe déjà."
}

# Liste des services
$services = @(
    "COMMERCIAL",
    "PREPRESSE",
    "PRODUCTION",
    "MAINTENANCE",
    "RH",
    "DIRECTION",
    "COMMUN"
)

foreach ($service in $services) {
    $gg = "G_$service"             # Groupe global
    $dl = "DL_${service}_PARTAGE"  # Groupe domaine local

    # Créer le groupe global
    if (-not (Get-ADGroup -Filter { Name -eq $gg })) {
        New-ADGroup -Name $gg -GroupScope Global -GroupCategory Security -Path $ouGroupes
        Write-Host "✅ Groupe global créé : $gg"
    } else {
        Write-Host "⚠️ Groupe global déjà existant : $gg"
    }

    # Créer le groupe domaine local
    if (-not (Get-ADGroup -Filter { Name -eq $dl })) {
        New-ADGroup -Name $dl -GroupScope DomainLocal -GroupCategory Security -Path $ouGroupes
        Write-Host "✅ Groupe domaine local créé : $dl"
    } else {
        Write-Host "⚠️ Groupe domaine local déjà existant : $dl"
    }

    # Ajouter le groupe global dans le groupe domaine local
    try {
        Add-ADGroupMember -Identity $dl -Members $gg -ErrorAction Stop
        Write-Host "🔁 $gg ajouté à $dl"
    }
    catch {
        Write-Host "⚠️ $gg est déjà membre de $dl ou erreur: $_"
    }
}
