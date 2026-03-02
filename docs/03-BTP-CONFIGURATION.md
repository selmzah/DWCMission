# 03 - Configuration BTP

Ce guide décrit la configuration côté SAP BTP nécessaire avant le déploiement.

---

## Prérequis

- Avoir complété la [configuration Datasphere](./02-DATASPHERE-SETUP.md)
- Être connecté à Cloud Foundry via `cf login`
- Être dans le bon organization et space BTP

```bash
# Vérifier la connexion CF
cf target
```

---

## Étape 1 : Créer le User-Provided Service Datasphere

Le User-Provided Service `ups_btp_dwc` fournit les credentials Datasphere à l'HDI Container.

> **Pourquoi un User-Provided Service ?**  
> SAP Datasphere n'est pas disponible dans le marketplace SAP BTP. Il faut donc créer manuellement un service avec les credentials de connexion.

### 1.1 Créer le service

Remplacez les valeurs par vos propres credentials Datasphere (récupérés à l'[étape 5 du guide Datasphere](./02-DATASPHERE-SETUP.md)) :

```bash
cf cups ups_btp_dwc -p '{
  "host": "YOUR_DATASPHERE_HOST.hanacloud.ondemand.com",
  "port": "443",
  "user": "TANK_FARM_TECH_USER#TECH_USER",
  "password": "YOUR_PASSWORD",
  "schema": "TANK_FARM_TECH_USER",
  "hdi_dynamic_disable_foreign_key_constraint": true
}'
```

**Paramètres expliqués :**

| Paramètre | Description |
|-----------|-------------|
| `host` | Hostname HANA de votre tenant Datasphere |
| `port` | Toujours `443` (SSL) |
| `user` | Utilisateur technique Datasphere |
| `password` | Mot de passe de l'utilisateur technique |
| `schema` | Schéma correspondant au Database User Datasphere |
| `hdi_dynamic_disable_foreign_key_constraint` | Désactive les FK constraints pour la connexion cross-service |

### 1.2 Vérifier la création

```bash
cf services | grep ups_btp_dwc
```

Vous devriez voir :
```
ups_btp_dwc   user-provided
```

---

## Étape 2 : Configurer les Destinations

Les destinations permettent à SAP Build Apps de se connecter au service CAP.

### 2.1 Créer la destination dans BTP Cockpit

1. Allez dans **BTP Cockpit** → votre sous-compte → **Connectivity** → **Destinations**
2. Cliquez **+ New Destination**
3. Renseignez :

| Propriété | Valeur |
|-----------|--------|
| **Name** | `DWCMission_CAP` |
| **Type** | `HTTP` |
| **URL** | URL de votre service CAP après déploiement |
| **Proxy Type** | `Internet` |
| **Authentication** | `OAuth2JWTBearer` |
| **Client ID** | Client ID XSUAA de l'application |
| **Client Secret** | Client Secret XSUAA |
| **Token Service URL** | URL du token service XSUAA |

> 📝 Vous trouverez les informations XSUAA dans les variables d'environnement de l'application déployée :
> ```bash
> cf env dwcmission-srv | grep -A 20 "xsuaa"
> ```

### 2.2 Propriétés additionnelles

Dans **Additional Properties**, ajoutez :

| Propriété | Valeur |
|-----------|--------|
| `HTML5.DynamicDestination` | `true` |
| `HTML5.ForwardAuthToken` | `true` |
| `WebIDEEnabled` | `true` |
| `WebIDEUsage` | `odata_gen` |

---

## Étape 3 : Assigner les rôles aux utilisateurs

### 3.1 Via BTP Cockpit

1. Allez dans **BTP Cockpit** → votre sous-compte → **Security** → **Users**
2. Trouvez l'utilisateur (ex: `field.technician@tester.sap.com`)
3. Cliquez sur **Assign Role Collection**
4. Sélectionnez `DWCMission_FieldTechnician`
5. Confirmez

### 3.2 Via CF CLI

```bash
# Lister les role collections disponibles
cf curl /v2/apps/$(cf app dwcmission-srv --guid)/env | python3 -m json.tool

# Assigner via BTP API (ou via l'interface graphique)
```

### Rôles disponibles

| Role Collection | Rôle | Permissions |
|----------------|------|-------------|
| `DWCMission_FieldTechnician` | FieldTechnician | Lecture Tanks + CRUD TankVolumes |
| `DWCMission_Admin` | Admin | Accès complet + suppression |

---

## Étape 4 : Configurer HANA Cloud

Votre instance HANA Cloud doit être accessible depuis le space Cloud Foundry.

### 4.1 Vérifier l'accès HANA Cloud

```bash
# Lister les services HANA disponibles
cf marketplace -e hana
```

Vous devriez voir le plan `hdi-shared`.

### 4.2 Vérifier l'instance HDI (après déploiement)

```bash
cf services | grep dwcmission-db
```

---

## Prochaines étapes

1. [Déploiement de l'application →](./04-DEPLOYMENT.md)
