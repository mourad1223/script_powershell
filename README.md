
# 🛠️ Scripts PowerShell – Infrastructure Active Directory & Administration Serveurs

Ce dépôt regroupe une collection de scripts PowerShell conçus pour automatiser :

- le déploiement et la configuration d’une infrastructure Active Directory (AD)
- la gestion des serveurs de fichiers et de la réplication DFS-R
- l’administration système quotidienne des serveurs Windows

---

## 📋 Objectifs

- 🏗️ Déploiement rapide d’un environnement Active Directory structuré
- 👥 Création automatisée d’utilisateurs, OU et groupes
- 🔁 Mise en place et vérification de la réplication DFS-R
- 🔒 Gestion centralisée des permissions NTFS et partages SMB
- 🖥️ Scripts d’audit & maintenance pour l’administration système

---

## ⚙️ Prérequis

- Windows Server avec PowerShell 5.1 ou plus
- Droits d’administrateur sur les serveurs cibles
- PowerShell Remoting activé (`Enable-PSRemoting`)
- Modules nécessaires : `ActiveDirectory`, `DFSR`, `SmbShare`, `PSWindowsUpdate` (optionnel)

---

## 🚀 Utilisation

1. Clonez le dépôt sur votre machine d’administration :

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
| `Configuration_DFS.ps1`            | Mise en place du DFS-R (réplication de fichiers)                       |
| `Check_DFSr.ps1` / `test_dfsr.ps1` | Vérification du bon fonctionnement du DFS-R                            |
| `UpdatePermissions.ps1`           | Application de droits NTFS personnalisés                               |
| `verif_smb_share.ps1`              | Vérification des partages SMB                                          |
| `Script_Arborescence_Serveur...`   | Création de l’arborescence logique sur serveur de fichiers             |
| `Utilisateurs_100_complet.csv`     | Fichier source des utilisateurs (nom, login, etc.)                     |
| `Check-DiskSpace.ps1`              | Vérifie l’espace disque disponible (alerte si < seuil défini)          |
| `Restart-ServiceIfStopped.ps1`     | Redémarre un service s’il est arrêté sur un ou plusieurs serveurs      |
| `Get-PendingUpdates.ps1`           | Liste les mises à jour Windows en attente                              |
| `Get-ServerHealth.ps1`             | Affiche un résumé de l’état CPU/RAM d’un ou plusieurs serveurs         |
| `Get-ServiceStatus.ps1`            | Vérifie si des services critiques sont actifs sur plusieurs serveurs   |
| `README.md`                        | Ce fichier de documentation                                            |

---


