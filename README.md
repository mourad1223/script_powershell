
# 🛠️ Scripts PowerShell pour Infrastructure Active Directory et Serveurs Fichiers

Ce dépôt regroupe une collection de scripts PowerShell destinés à automatiser le déploiement, la configuration et la gestion d'une infrastructure Active Directory (AD), des serveurs de fichiers, ainsi que des services tels que DFS-R (Distributed File System Replication).

---

## 📋 Objectifs

- Déploiement rapide d’un environnement Active Directory structuré
- Création automatique d’utilisateurs et d’unités organisationnelles
- Configuration centralisée du DFS-R pour la réplication de données
- Gestion des permissions NTFS et des partages SMB
- Vérification de la bonne réplication et de la cohérence entre serveurs

---

## ⚙️ Prérequis

- Windows Server avec PowerShell 5.1 ou plus
- Droits d’administrateur sur les serveurs cibles
- PowerShell Remoting activé (`Enable-PSRemoting`)
- Modules nécessaires : `ActiveDirectory`, `DFSR`, `SmbShare`...

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
| `README.md`                        | Ce fichier de documentation                                            |

---


