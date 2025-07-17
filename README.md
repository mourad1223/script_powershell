
# 🛠️ Scripts PowerShell – Infrastructure Active Directory, Administration Système & Réseau

Ce dépôt regroupe une collection de scripts PowerShell destinés à automatiser :

- le déploiement et la gestion d’une infrastructure Active Directory
- la configuration des serveurs de fichiers (DFS, NTFS, SMB)
- l’administration système et réseau de serveurs Windows

---

## 📋 Objectifs

- 🏗️ Déploiement rapide d’un environnement Active Directory structuré
- 👥 Création automatisée d’utilisateurs, OU et groupes
- 🔁 Mise en place et vérification de la réplication DFS-R
- 🔒 Gestion centralisée des permissions NTFS et des partages SMB
- 🖥️ Supervision et maintenance des serveurs
- 🌐 Outils pour tests réseau, connectivité, DNS, ports

---

## ⚙️ Prérequis

- Windows Server avec PowerShell 5.1 ou supérieur
- Droits d’administrateur sur les serveurs cibles
- PowerShell Remoting activé (`Enable-PSRemoting`)
- Modules recommandés :
  - `ActiveDirectory`
  - `DFSR`
  - `SmbShare`
  - `PSWindowsUpdate` (optionnel pour les mises à jour)
  - `NetTCPIP` (inclus par défaut)

---

## 🚀 Utilisation

1. Clonez le dépôt :

```powershell
git clone https://github.com/votre-utilisateur/nom-du-repo.git
cd nom-du-repo



## 📂 Contenu du dépôt

| Fichier                             | Description                                                            |
|------------------------------------|------------------------------------------------------------------------|
| `install_dcp.ps1`                  | Installation et promotion du contrôleur de domaine                     |
| `Create-ADUsersFromCSV.ps1`        | Création automatique d'utilisateurs depuis un fichier `.csv`           |
| `Create-OU-Structure-Neoinfra.ps1` | Création de l’arborescence des unités organisationnelles               |
| `Ajout_user_Groupes.ps1`           | Ajout d’utilisateurs dans des groupes prédéfinis                       |
| `Utilisateurs_100_complet.csv`     | Fichier source des utilisateurs (nom, login, etc.)                     |
| `Script_Arborescence_Serveur...`   | Création de l’arborescence logique sur serveur de fichiers             |
| `UpdatePermissions.ps1`           | Application de droits NTFS personnalisés                               |
| `Configuration_DFS.ps1`            | Mise en place du DFS-R (réplication de fichiers)                       |
| `Check_DFSr.ps1` / `test_dfsr.ps1` | Vérification du bon fonctionnement du DFS-R                            |
| `verif_smb_share.ps1`              | Vérification des partages SMB                                          |
| `Check-DiskSpace.ps1`              | Vérifie l’espace disque disponible sur les serveurs                    |
| `Restart-ServiceIfStopped.ps1`     | Redémarre automatiquement un service arrêté                            |
| `Get-PendingUpdates.ps1`           | Liste les mises à jour Windows en attente                              |
| `Get-ServerHealth.ps1`             | Résumé des ressources système : CPU, RAM                               |
| `Get-ServiceStatus.ps1`            | Vérifie si des services critiques sont actifs                          |
| `Test-NetworkConnectivity.ps1`     | Vérifie la connectivité réseau (ping ICMP)                             |
| `Get-DnsResolution.ps1`            | Résolution DNS de noms d’hôtes                                         |
| `Scan-TcpPort.ps1`                 | Scan de ports TCP sur une machine cible                                |
| `Get-IpConfiguration.ps1`          | Affiche la configuration IP, passerelle et DNS                         |
| `Get-OpenSessions.ps1`             | Affiche les connexions SMB actives sur un serveur                      |
| `Get-ActiveConnections.ps1`        | Liste des connexions TCP actives (équivalent à `netstat`)              |
| `README.md`                        | Ce fichier de documentation                                            |

---

