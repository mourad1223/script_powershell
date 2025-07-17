# Import du module Active Directory
Import-Module ActiveDirectory

# Chemin du fichier CSV
$csvPath = "C:\Scripts\Utilisateurs_100_complet.csv"

# Récupère le DN du domaine courant
$baseDN = (Get-ADDomain).DistinguishedName

# Import des utilisateurs
$utilisateurs = Import-Csv -Path $csvPath

foreach ($user in $utilisateurs) {
    $ouPath = "OU=$($user.Service),OU=Utilisateurs,$baseDN"

    # Vérifie si l'utilisateur existe déjà
    if (-not (Get-ADUser -Filter "SamAccountName -eq '$($user.Login)'" -ErrorAction SilentlyContinue)) {
        $securePass = ConvertTo-SecureString $user.Password -AsPlainText -Force

        New-ADUser `
            -Name "$($user.Prenom) $($user.Nom)" `
            -GivenName $user.Prenom `
            -Surname $user.Nom `
            -DisplayName "$($user.Prenom) $($user.Nom)" `
            -SamAccountName $user.Login `
            -UserPrincipalName "$($user.Login)@$((Get-ADDomain).DNSRoot)" `
            -Department $user.Service `
            -Title $user.Titre `
            -EmailAddress $user.Email `
            -OfficePhone $user.TelFixe `
            -MobilePhone $user.TelMobile `
            -Company $user.Entreprise `
            -Path $ouPath `
            -AccountPassword $securePass `
            -Enabled $true `
            -ChangePasswordAtLogon $true `
            -PasswordNeverExpires $false

        Write-Host "✅ Utilisateur $($user.Login) créé dans $ouPath" -ForegroundColor Green
    }
    else {
        Write-Host "⚠️  Utilisateur $($user.Login) existe déjà" -ForegroundColor Yellow
    }
}
