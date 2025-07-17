Import-Module ActiveDirectory

# Domaine racine
$baseDN = "OU=Utilisateurs,DC=neoinfra,DC=fr"

# Lister toutes les OU services
$services = @("COMMERCIAL", "PREPRESSE", "PRODUCTION", "MAINTENANCE", "RH", "DIRECTION", "COMMUN")

foreach ($service in $services) {
    $ouPath = "OU=$service,$baseDN"
    $groupeGlobal = "G_$service"

    # Vérifie si le groupe existe
    if (-not (Get-ADGroup -Filter { Name -eq $groupeGlobal })) {
        Write-Warning "🚫 Groupe $groupeGlobal introuvable. Création ignorée pour ce service."
        continue
    }

    # Récupérer les utilisateurs dans l'OU
    $users = Get-ADUser -SearchBase $ouPath -Filter * -Properties DistinguishedName

    foreach ($user in $users) {
        try {
            Add-ADGroupMember -Identity $groupeGlobal -Members $user.SamAccountName -ErrorAction Stop
            Write-Host "✅ $($user.SamAccountName) ajouté à $groupeGlobal"
        } catch {
            Write-Warning "⚠️ Erreur avec $($user.SamAccountName) → $($_.Exception.Message)"
        }
    }
}
