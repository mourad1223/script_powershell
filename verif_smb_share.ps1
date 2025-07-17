# Définir les serveurs à comparer
$serverA = "w22-fichier01"
$serverB = "w22-fichier02"

# Fonction pour récupérer les noms de partages créés (exclut C$, ADMIN$ etc.)
function Get-CustomShares($server) {
    Invoke-Command -ComputerName $server -ScriptBlock {
        Get-SmbShare | Where-Object {
            $_.Name -like "PARTAGE_*"
        } | Select-Object -ExpandProperty Name
    }
}

# Récupérer les partages sur chaque serveur
$sharesA = Get-CustomShares -server $serverA
$sharesB = Get-CustomShares -server $serverB

# Comparer les listes
Write-Host "🔍 Comparaison des partages SMB entre $serverA et $serverB ..." -ForegroundColor Cyan
Write-Host ""

Write-Host "✅ Partages présents sur les DEUX serveurs :" -ForegroundColor Green
($sharesA | Where-Object { $sharesB -contains $_ }) | ForEach-Object { Write-Host "  $_" }

Write-Host "`n❌ Partages manquants sur $serverB :" -ForegroundColor Yellow
($sharesA | Where-Object { $sharesB -notcontains $_ }) | ForEach-Object { Write-Host "  $_" }

Write-Host "`n❌ Partages manquants sur $serverA :" -ForegroundColor Yellow
($sharesB | Where-Object { $sharesA -notcontains $_ }) | ForEach-Object { Write-Host "  $_" }
