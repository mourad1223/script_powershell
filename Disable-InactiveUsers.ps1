<#
.SYNOPSIS
    Désactive les comptes utilisateurs inactifs depuis X jours.

.DESCRIPTION
    Ce script parcourt les utilisateurs Active Directory et désactive ceux dont la dernière connexion
    remonte à plus de X jours. Idéal pour nettoyer les comptes obsolètes.

.PARAMETER DaysInactive
    Nombre de jours d'inactivité à partir duquel désactiver le compte.

.EXAMPLE
    .\Disable-InactiveUsers.ps1 -DaysInactive 90
#>

param (
    [int]$DaysInactive = 90
)

Import-Module ActiveDirectory

$threshold = (Get-Date).AddDays(-$DaysInactive)
$users = Get-ADUser -Filter {Enabled -eq $true -and LastLogonDate -lt $threshold} -Properties LastLogonDate

foreach ($user in $users) {
    Write-Host "🔒 Désactivation de $($user.SamAccountName) - Dernière connexion : $($user.LastLogonDate)" -ForegroundColor Yellow
    Disable-ADAccount -Identity $user
}
