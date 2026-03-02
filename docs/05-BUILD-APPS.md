# 05 - Intégration SAP Build Apps

Ce guide décrit comment configurer SAP Build Apps pour se connecter à l'application CAP DWCMission.

---

## Architecture de l'intégration

```
Technicien (mobile)
     │
     ▼
SAP Build Apps
     │  (OData v4 via Destination BTP)
     ▼
CAP Service (FarmTankService)
     │
     ├── READ Tanks ──────► SAP Datasphere (vTanks)
     └── CRUD TankVolumes ► SAP HANA Cloud (HDI Container)
```

---

## Prérequis

- ✅ Application CAP déployée ([voir guide déploiement](./04-DEPLOYMENT.md))
- ✅ Destination `DWCMission_CAP` configurée dans BTP ([voir guide BTP](./03-BTP-CONFIGURATION.md))
- ✅ Accès à SAP Build Apps dans votre sous-compte BTP

---

## Étape 1 : Accéder à SAP Build Apps

1. Dans **BTP Cockpit**, allez dans **Services** → **Instances and Subscriptions**
2. Trouvez **SAP Build Apps** et cliquez sur **Go to Application**

---

## Étape 2 : Créer un nouveau projet

1. Dans SAP Build Apps, cliquez sur **Create** → **Build an Application** → **Web & Mobile Application**
2. Nommez votre application : `DWCMission - Tank Entry`
3. Cliquez **Create**

---

## Étape 3 : Configurer la source de données

### 3.1 Ajouter une intégration OData

1. Dans le menu de gauche, allez dans **Data** (icône base de données)
2. Cliquez sur **+ Add Integration** → **BTP Destinations**
3. Sélectionnez la destination `DWCMission_CAP`
4. SAP Build Apps découvrira automatiquement les entités OData disponibles

### 3.2 Activer les entités

Activez les entités suivantes :
- ✅ `Tanks` - pour afficher la liste des réservoirs
- ✅ `TankVolumes` - pour créer/consulter les lectures

### 3.3 Sauvegarder

Cliquez **Save** pour confirmer la configuration.

---

## Étape 4 : Créer les pages de l'application

### Page 1 : Liste des réservoirs

1. Dans **UI Builder**, créez une nouvelle page : `Tanks List`
2. Ajoutez un composant **List** 
3. Liez-le à la source de données `Tanks`
4. Configurez l'affichage :
   - **Titre** : `TankName`
   - **Sous-titre** : `Location`
   - **Indicateur** : `Status`

### Page 2 : Saisie de lecture de volume

1. Créez une nouvelle page : `New Reading`
2. Ajoutez les champs suivants :

| Champ | Composant | Source de données |
|-------|-----------|-------------------|
| Réservoir | Dropdown | `Tanks` (TankID, TankName) |
| Volume (litres) | Number Input | `TankVolumes.Volume` |
| Date de lecture | Date Picker | `TankVolumes.ReadingDate` |
| Notes | Text Area | `TankVolumes.Notes` |

3. Ajoutez un bouton **Enregistrer** avec l'action :
   - **Type** : `Create Record`
   - **Collection** : `TankVolumes`
   - **Données** : mapper les champs du formulaire

### Page 3 : Historique des lectures

1. Créez une nouvelle page : `Reading History`
2. Ajoutez une liste liée à `TankVolumes`
3. Affichez : TankID, Volume, ReadingDate, Technician

---

## Étape 5 : Configurer l'authentification

### 5.1 Activer l'auth XSUAA

1. Dans **Settings** → **Authentication**
2. Sélectionnez **SAP BTP Authentication**
3. Configurez avec les informations XSUAA de votre application

### 5.2 Règles de navigation

- Pages publiques : accueil uniquement
- Pages protégées : Tanks List, New Reading, Reading History

---

## Étape 6 : Tester l'application

### 6.1 Lancer le preview

Cliquez sur **Launch** → **Preview** dans SAP Build Apps.

### 6.2 Tester la connexion

1. Connectez-vous avec `field.technician@tester.sap.com`
2. Vérifiez que la liste des réservoirs s'affiche
3. Créez une nouvelle lecture de volume
4. Vérifiez que la lecture apparaît dans l'historique

---

## Étape 7 : Déployer l'application Build Apps

### 7.1 Build

Dans SAP Build Apps, cliquez sur **Build** → **Web** et configurez les paramètres de build.

### 7.2 Déployer sur SAP Build Work Zone

Après le build, l'application peut être publiée sur **SAP Build Work Zone** pour être accessible via un portail unifié.

---

## Dépannage courant

| Problème | Solution |
|----------|----------|
| "No data available" | Vérifier que la destination est bien configurée |
| Erreur 401 | Vérifier les rôles assignés à l'utilisateur |
| Erreur 403 | L'utilisateur n'a pas le rôle `FieldTechnician` |
| Entités non découvertes | Vérifier que le service CAP est déployé et accessible |

---

## Prochaines étapes

1. [Résolution des problèmes →](./06-TROUBLESHOOTING.md)
