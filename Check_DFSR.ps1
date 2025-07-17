# Variables
$sourceServer = "w22-fichier01"
$destServer = "w22-fichier02"
$groupName = "GroupeDFSR"
$folderName = "partages"

Write-Host "🔧 Vérification DFSR entre $sourceServer → $destServer sur '$folderName' (Groupe : $groupName)" -ForegroundColor Cyan

# 1. Vérifier que le service DFSR est en cours d'exécution sur les deux serveurs
function Test-ServiceDFSR {
    param($server)
    $svc = Get-Service -ComputerName $server -Name DFSR -ErrorAction SilentlyContinue
    if ($null -eq $svc) {
        Write-Warning "⚠ Le service DFSR n'a pas été trouvé sur $server."
        return $false
    }
    if ($svc.Status -ne "Running") {
        Write-Warning "⚠ Le service DFSR n'est pas en cours sur $server (Status = $($svc.Status))."
        return $false
    }
    Write-Host "✅ Service DFSR OK sur $server"
    return $true
}

if (-not (Test-ServiceDFSR $sourceServer) -or -not (Test-ServiceDFSR $destServer)) {
    Write-Warning "Le service DFSR doit être démarré sur les deux serveurs pour poursuivre."
    exit
}

# 2. Vérifier backlog DFSR (fichiers en attente de réplication)
Write-Host "`n📦 Vérification du backlog DFSR..."
try {
    $backlog = Get-DfsrBacklog -SourceComputerName $sourceServer -DestinationComputerName $destServer -GroupName $groupName -FolderName $folderName -ErrorAction Stop
    if ($backlog.Count -eq 0) {
        Write-Host "✅ Pas de fichiers en attente de réplication (backlog vide)."
    } else {
        Write-Warning "⚠ $($backlog.Count) fichier(s) en attente de réplication :"
        $backlog | ForEach-Object {
            Write-Host " - $($_.Name)"
        }
    }
} catch {
    Write-Warning "Erreur lors de la récupération du backlog DFSR : $_"
}

# 3. Tester l'accès aux partages sur les deux serveurs
Write-Host "`n🔄 Test d'accès aux partages \\$sourceServer\$folderName et \\$destServer\$folderName"
foreach ($srv in @($sourceServer, $destServer)) {
    $path = "\\$srv\$folderName"
    if (Test-Path $path) {
        Write-Host "✅ Accès réussi à $path"
    } else {
        Write-Warning "❌ Échec d'accès à $path"
    }
}

# 4. Vérifier les événements DFSR récents (dernières 24h) sur les deux serveurs
Write-Host "`n📅 Vérification des événements DFSR dans le journal d'applications (24 dernières heures)..."
foreach ($srv in @($sourceServer, $destServer)) {
    Write-Host "`n➡ Événements DFSR sur $srv :"
    try {
        $events = Get-WinEvent -ComputerName $srv -FilterHashtable @{LogName='Microsoft-Windows-DFSR/Operational'; StartTime=(Get-Date).AddDays(-1)} -MaxEvents 10
        if ($events.Count -eq 0) {
            Write-Host "Aucun événement DFSR récent trouvé."
        } else {
            foreach ($evt in $events) {
                $time = $evt.TimeCreated.ToString("yyyy-MM-dd HH:mm:ss")
                Write-Host "[$time] ID:$($evt.Id) - $($evt.Message.Split("`n")[0])"
            }
        }
    } catch {
        Write-Warning "Impossible de récupérer les événements sur $srv : $_"
    }
}

Write-Host "`n✅ Vérification DFSR terminée."
