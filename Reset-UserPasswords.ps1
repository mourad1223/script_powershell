<#
.SYNOPSIS
    Réinitialise les mots de passe d’une liste d’utilisateurs AD.

.DESCRIPTION
    Ce script prend une liste d’utilisateurs (via CSV ou tableau) et leur affecte un mot de passe temporaire,
    puis force la réinitialisation à la prochaine connexion.

.PARAMETER Users
    Liste d’identifiants utilisateurs AD (SamAccountName).

.EXAMPLE
    .\Reset-UserPasswords.ps1 -Users @("jdupont", "mlegrand")
#>

param (
    [string[]]$Users
)

Import-Module ActiveDirectory

foreach ($user in $Users) {
    $pwd = ConvertTo-SecureString "#Definir Mot de passe!" -AsPlainText -Force
    try {
        Set-ADAccountPassword -Identity $user -NewPassword $pwd -Reset
        Set-ADUser -Identity $user -ChangePasswordAtLogon $true
        Write-Host "🔁 Mot de passe réinitialisé pour $user" -ForegroundColor Green
    } catch {
        Write-Host "❌ Erreur pour $user : $_" -ForegroundColor Red
    }
}
