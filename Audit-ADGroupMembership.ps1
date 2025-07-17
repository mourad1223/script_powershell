<#
.SYNOPSIS
    Exporte les membres d’un ou plusieurs groupes AD.

.DESCRIPTION
    Ce script récupère les membres d’un ou plusieurs groupes Active Directory
    et les exporte dans un fichier CSV.

.PARAMETER Groups
    Liste des groupes à auditer.

.PARAMETER OutputPath
    Chemin du fichier de sortie CSV.

.EXAMPLE
    .\Audit-ADGroupMembership.ps1 -Groups "Administrateurs", "DFS_Admins" -OutputPath "groupes.csv"
#>

param (
    [string[]]$Groups,
    [string]$OutputPath = "GroupMembershipReport.csv"
)

Import-Module ActiveDirectory

$data = foreach ($group in $Groups) {
    Get-ADGroupMember -Identity $group | ForEach-Object {
        [PSCustomObject]@{
            Group     = $group
            Member    = $_.SamAccountName
            Type      = $_.ObjectClass
        }
    }
}

$data | Export-Csv -NoTypeInformation -Path $OutputPath
Write-Host "✅ Export terminé vers $OutputPath" -ForegroundColor Green
