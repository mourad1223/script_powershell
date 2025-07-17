<#
.SYNOPSIS
    Liste les comptes AD dont le mot de passe est expiré ou bientôt expiré.

.DESCRIPTION
    Permet d’auditer les comptes utilisateurs avec des mots de passe expirés ou proches de l’expiration.

.PARAMETER DaysThreshold
    Seuil en jours pour alerter les mots de passe expirants bientôt.

.EXAMPLE
    .\Find-ADAccountsWithExpiredPassword.ps1 -DaysThreshold 10
#>

param (
    [int]$DaysThreshold = 10
)

Import-Module ActiveDirectory

$today = Get-Date
$warningDate = $today.AddDays($DaysThreshold)

$users = Get-ADUser -Filter {Enabled -eq $true -and PasswordNeverExpires -eq $false} -Properties "msDS-UserPasswordExpiryTimeComputed", "DisplayName" | Where-Object {
    ($_.msDS-UserPasswordExpiryTimeComputed -ne $null) -and
    ([datetime]::FromFileTime($_.msDS-UserPasswordExpiryTimeComputed) -le $warningDate)
} | Select-Object DisplayName, SamAccountName,
    @{Name='ExpiryDate'; Expression={[datetime]::FromFileTime($_.'msDS-UserPasswordExpiryTimeComputed')}}

$users | Format-Table -AutoSize
