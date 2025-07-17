<#
.SYNOPSIS
    Vérifie l'état de réplication DFS-R entre deux serveurs (service, backlog, accès UNC, événements).

.DESCRIPTION
    Ce script effectue les actions suivantes :
    - Vérifie que le service DFSR est actif sur chaque serveur
    - Vérifie le backlog DFSR (fichiers en attente de réplication)
    - Teste l’accès réseau aux partages
    - Analyse les événements DFSR récents dans les journaux

.PARAMETER SourceServer
    Nom du serveur source DFSR

.PARAMETER DestinationServer
    Nom du serveur destination DFSR

.PARAMETER GroupName
    Nom du groupe de réplication DFSR (ex : "GroupeDFSR")

.PARAMETER FolderName
    Nom du dossier DFSR partagé (ex : "partages")

.EXAMPLE
    .\Check-DfsrReplication.ps1 -SourceServer "fs01" -DestinationServer "fs02" -GroupName "GroupeDFSR" -FolderName "partages"

.NOTES
    Auteur : Ton Nom
    GitHub : https://github.com/ton-compte/Check-DfsrReplication
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$SourceServer,

    [Parameter(Mandatory = $true)]
    [string]$DestinationServer,

    [Parameter(Mandatory = $true)]
    [string]$GroupName,

    [Parameter(Mandatory = $true)]
    [string]$FolderName
)

Write-Host "`n🔧 Vérification DFSR entre $SourceServer → $DestinationServer sur '$FolderName' (Groupe : $GroupName)" -ForegroundColor Cyan

function Test-ServiceDFSR {
    param($Server)
    try {
        $svc = Get-Service -ComputerName $Server -Name DFSR -ErrorAction Stop
        if ($svc.Status -ne "Running") {
            Write-Warning "⚠ Le service DFSR n'est pas actif sur $Server (Status = $($svc.Status))."
            return $false
        }
        Write-Host "✅ Service DFSR OK sur $Server"
        return $true
    } catch {
        Write-Warning "❌ Service DFSR introuvable ou erreur sur $Server : $_"
        return $false
    }
}

# Vérification des services
if (-not (Test-ServiceDFSR $SourceServer) -or -not (Test-ServiceDFSR $DestinationServer)) {
    Write-Warning "⛔ Le service DFSR doit être actif sur les deux serveurs. Arrêt du script."
    exit
}

# Vérification backlog DFSR
Write-Host "`n📦 Vérification du backlog DFSR..."
try {
    $backlog = Get-DfsrBack
