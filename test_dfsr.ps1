# Variables
$share = "COMMERCIAL"
$testFileName = "test_dfsr.txt"
$servers = @("w22-fichier01", "w22-fichier02")
$localPath = "E:\Partages\$share"
$testFileContent = "Test de réplication DFSR - $(Get-Date)"

# 1. Créer un fichier test sur le premier serveur
Invoke-Command -ComputerName $servers[0] -ScriptBlock {
    param($path, $fileName, $content)
    $fullPath = Join-Path $path $fileName
    Set-Content -Path $fullPath -Value $content
    Write-Output "Fichier créé sur $env:COMPUTERNAME : $fullPath"
} -ArgumentList $localPath, $testFileName, $testFileContent

# 2. Attendre 30 secondes (tu peux ajuster le délai)
Start-Sleep -Seconds 30

# 3. Vérifier sur le deuxième serveur si le fichier est bien présent
Invoke-Command -ComputerName $servers[1] -ScriptBlock {
    param($path, $fileName)
    $fullPath = Join-Path $path $fileName
    if (Test-Path $fullPath) {
        Write-Output "Fichier répliqué trouvé sur $env:COMPUTERNAME : $fullPath"
        Get-Content $fullPath
    } else {
        Write-Output "Fichier non trouvé sur $env:COMPUTERNAME : $fullPath"
    }
} -ArgumentList $localPath, $testFileName
