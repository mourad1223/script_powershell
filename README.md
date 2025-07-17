# NEOINFRA
Projet ESGI M1 NEOINFRA
# 🏗️ Projet ESGI M1 – NEOINFRA

## 📌 Description

Ce dépôt Git regroupe l'ensemble des scripts PowerShell et fichiers techniques développés dans le cadre du projet annuel **NEOINFRA**, réalisé en M1 ESGI – filière SRC (Systèmes, Réseaux & Cloud).

Le projet visait à concevoir et déployer une infrastructure virtuelle complète, incluant :
- Deux hôtes **VMware ESXi** avec stockage partagé
- Un **Active Directory local** + intégration Azure AD (partielle)
- Un système de **supervision Zabbix**
- Une **infrastructure réseau sécurisée** avec VLANs et **pare-feu FortiGate**
- Des accès **VPN distants** pour les utilisateurs

---

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

## 🧪 Objectif pédagogique

- Automatiser les tâches d'administration avec PowerShell
- Structurer un environnement Active Directory de manière industrialisée
- Documenter et versionner le travail réalisé dans un dépôt Git centralisé
- Capitaliser les scripts pour réutilisation future ou démonstration technique

---

## 🔒 Accès & usage

Ce dépôt est public à but pédagogique. Merci de ne pas l’utiliser en production sans vérification préalable.

---

## 👤 Auteur

Mourad / Qunetin / Emilie*  
Projet réalisé avec Quentin, Émilie – M1 SRC – ESGI Nantes 
Juillet 2025
