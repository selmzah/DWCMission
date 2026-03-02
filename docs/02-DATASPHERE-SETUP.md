# 02 - Configuration de SAP Datasphere

Ce guide décrit comment préparer SAP Datasphere pour l'intégration avec l'application CAP DWCMission.

---

## Architecture Datasphere

```
Datasphere Space (TANK_FARM)
  ├── Table locale : Tank_Basic_Data
  ├── Vue graphique : vTanks  (exposée pour consommation externe)
  └── Database User : DWCM_TECH_USER (accès lecture pour le HDI Container)
```

---

## Étape 1 : Créer un espace (Space)

1. Connectez-vous à votre tenant SAP Datasphere
2. Allez dans **Space Management**
3. Cliquez sur **+ Create Space**
4. Renseignez :
   - **Space ID** : `TANK_FARM`
   - **Space Name** : `Tank Farm Management`
   - **Disk Storage** : 1 GB (minimum pour un POC)
   - **In-Memory Storage** : 1 GB
5. Cliquez **Save**

---

## Étape 2 : Créer la table de données master

### 2.1 Ouvrir le Data Builder

Dans votre espace `TANK_FARM`, allez dans **Data Builder** → **+ New** → **Local Table**.

### 2.2 Définir la structure

| Nom de colonne | Type de données | Longueur | Clé | Obligatoire |
|----------------|----------------|----------|-----|-------------|
| `TankID`       | String         | 10       | ✅  | ✅          |
| `TankName`     | String         | 100      |     | ✅          |
| `Capacity`     | Integer        |          |     |             |
| `CurrentLevel` | Integer        |          |     |             |
| `Location`     | String         | 200      |     |             |
| `Status`       | String         | 20       |     |             |

### 2.3 Nommer et sauvegarder

- **Business Name** : `Tank Basic Data`
- **Technical Name** : `Tank_Basic_Data`
- Cliquez **Save and Deploy**

---

## Étape 3 : Importer les données de test

1. Dans la table `Tank_Basic_Data`, cliquez sur **Import CSV**
2. Téléchargez le fichier `db/data/com.sap.dwcm-Tanks.csv` depuis ce dépôt
3. Mappez les colonnes
4. Cliquez **Import**

Données importées :
```csv
TankID,TankName,Capacity,CurrentLevel,Location,Status
T001,Réservoir Nord A,50000,32000,Ferme Nord - Bâtiment A,ACTIVE
...
```

---

## Étape 4 : Créer la vue graphique vTanks

### 4.1 Créer la vue

Dans **Data Builder** → **+ New** → **Graphical View**.

### 4.2 Configurer la vue

1. Faites glisser la table `Tank_Basic_Data` dans l'éditeur
2. Sélectionnez toutes les colonnes
3. Renommez la vue :
   - **Business Name** : `Tanks View`
   - **Technical Name** : `vTanks`

### 4.3 Exposer pour la consommation

1. Dans les propriétés de la vue, activez **Expose for Consumption**
2. Cliquez **Save and Deploy**

> ⚠️ **Important** : L'option "Expose for Consumption" est nécessaire pour rendre la vue accessible depuis l'extérieur de Datasphere.

---

## Étape 5 : Créer le Database User technique

Ce compte permet à l'HDI Container (via le User-Provided Service) de se connecter à Datasphere.

### 5.1 Créer l'utilisateur

1. Dans votre espace `TANK_FARM`, allez dans **Space Settings** → **Database Users**
2. Cliquez **+ Add Database User**
3. Renseignez :
   - **Database User Name Suffix** : `TECH_USER`
   - **Enable Read Access (SQL)** : ✅
4. Cliquez **Create**

### 5.2 Accorder les droits sur la vue

L'utilisateur technique doit avoir accès en lecture à `vTanks` :

1. Dans la liste des Database Users, cliquez sur votre utilisateur
2. Dans **Privileges**, ajoutez :
   - **Object** : `vTanks`
   - **Privilege** : `SELECT`
3. Cliquez **Save**

### 5.3 Récupérer les credentials

Notez ces informations, elles seront utilisées dans le User-Provided Service :

| Information | Exemple | Comment l'obtenir |
|-------------|---------|-------------------|
| **Host** | `abc123.hanacloud.ondemand.com` | Space Settings → Database Users |
| **Port** | `443` | Toujours 443 pour Datasphere |
| **User** | `TANK_FARM_TECH_USER#TECH_USER` | Affiché dans la liste des users |
| **Password** | `*****` | Affiché lors de la création (à noter impérativement) |
| **Schema** | `TANK_FARM_TECH_USER` | Préfixe de l'espace + suffixe |

> 🔐 **Sécurité** : Ne stockez jamais ces credentials en clair dans le code source !

---

## Vérification

Pour vérifier que la vue est accessible, vous pouvez utiliser un client SQL (ex: DBeaver, SAP HANA Studio) :

```sql
SELECT * FROM "TANK_FARM_TECH_USER"."vTanks";
```

---

## Prochaines étapes

1. [Configuration BTP (User-Provided Service) →](./03-BTP-CONFIGURATION.md)
