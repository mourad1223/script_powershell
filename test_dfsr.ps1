<#
.SYNOPSIS
    Teste la réplication DFSR entre deux serveurs.

.DESCRIPTION
    Ce script crée un fichier de test sur un serveur source,
    attend un délai donné, puis vérifie si le fichier a été répliqué
    sur le serveur de destination via DFSR.

.PARAMETER Share
    Le nom du partage DFS utilisé.

.PARAMETER FileName
    Le nom du fichier de test à créer.

.PARAMETER Servers
    Un tableau contenant les noms des deux serveurs DFS (source et destination).

.PARAMETER Delay
    Le délai (en secondes) à attendre avant de vérifier la réplication.

.EXAMPLE
    .\Test-DfsReplication.ps1 -Share "a definir"L" -FileName "test_dfsr.txt" -Servers @("Server1", "Server2") -Delay 30
#>

param(
    [string]$Share = "# a definir",
    [string]$FileName = "test_dfsr.txt",
    [string[]]$Servers = @("Server1", "Server2"),
    [int]$Delay = 30
)

# Contenu du fichier de test
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$TestFileContent = "Test de réplication DFSR - $timestamp"

# Chemin local (identique sur tous les serveurs DFSR)
$LocalPath = "E:\Partages\$Share"

# 1. Créer le fichier test sur le serveur source
Write-Host "`n[INFO] Création du fichier sur le serveur source : $($Servers[0])"
Invoke-Command -ComputerName $Servers[0] -ScriptBlock {
    param($Path, $FileName, $Content)
    $FullPath = Join-Path $Path $FileName
    Set-Content -Path $FullPath -Value $Content -Force
    Write-Output "Fichier créé sur $env:COMPUTERNAME : $FullPath"
} -ArgumentList $LocalPath, $FileName, $TestFileContent

# 2. Attendre le temps de réplication
Write-Host "`n[INFO] Attente de $Delay secondes pour permettre la réplication..."
Start-Sleep -Seconds $Delay

# 3. Vérifier si le fichier est présent sur le serveur destination
Write-Host "`n[INFO] Vérification sur le serveur de destination : $($Servers[1])"
Invoke-Command -ComputerName $Servers[1] -ScriptBlock {
    param($Path, $FileName)
    $FullPath = Join-Path $Path $FileName
    if (Test-Path $FullPath) {
        Write-Output "✅ Fichier répliqué trouvé sur $env:COMPUTERNAME : $FullPath"
        Write-Output "Contenu du fichier :"
        Get-Content $FullPath
    } else {
        Write-Output "❌ Fichier non trouvé sur $env:COMPUTERNAME : $FullPath"
    }
} -ArgumentList $LocalPath, $FileName
