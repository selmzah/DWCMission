# DWCMission - SAP Datasphere + CAP Integration

Reproduction complète du projet SAP "Enable End-User Data Entry into SAP Datasphere via SAP Build Apps"

## 🎯 Vue d'ensemble

Cette application CAP (Cloud Application Programming Model) permet aux techniciens terrain de saisir des lectures manuelles de niveau de réservoirs via SAP Build Apps, en s'intégrant avec SAP Datasphere pour l'analyse des données.

## 📋 Architecture

```
SAP Build Apps (mobile)
       │
       ▼
CAP Application (OData v4)  ←─── SAP Analytics Cloud
       │
       ├── READ  ──► SAP Datasphere (vTanks - données master)
       └── WRITE ──► SAP HANA Cloud (TankVolumes - lectures manuelles)
```

**Composants :**
- **SAP Datasphere** : Stockage des données master (réservoirs)
- **CAP Application** : Service OData v4 pour lecture/écriture
- **SAP Build Apps** : Interface mobile de saisie pour les techniciens terrain
- **SAP Analytics Cloud** : Dashboards analytiques
- **SAP Build Work Zone** : Portail d'accès unifié

## 🚀 Démarrage rapide (local)

### Prérequis

- Node.js 18.x ou supérieur
- `npm install -g @sap/cds-dk`

### Installation

```bash
git clone https://github.com/selmzah/DWCMission.git
cd DWCMission
npm install
cds watch
```

L'application est accessible sur [http://localhost:4004](http://localhost:4004)

### Endpoints disponibles

| Endpoint | Description |
|----------|-------------|
| `/odata/v4/farm-tank/Tanks` | Liste des réservoirs (depuis Datasphere) |
| `/odata/v4/farm-tank/TankVolumes` | Lectures manuelles de volume |
| `/odata/v4/farm-tank/$metadata` | Métadonnées du service OData v4 |

### Utilisateurs de test

| Email | Mot de passe | Rôle |
|-------|-------------|------|
| `field.technician@tester.sap.com` | `initial` | FieldTechnician |
| `admin@tester.sap.com` | `initial` | Admin |

## 📦 Structure du projet

```
DWCMission/
├── package.json                    # Configuration Node.js / CDS
├── mta.yaml                        # Configuration déploiement BTP
├── xs-security.json                # Rôles et scopes XSUAA
│
├── db/
│   ├── schema.cds                  # Modèle de données (Tanks, TankVolumes)
│   ├── data/
│   │   └── com.sap.dwcm-Tanks.csv  # Données de test
│   └── src/dwc/                    # Artifacts HDI pour Datasphere
│       ├── .hdiconfig
│       ├── dwc_role.hdbrole        # Rôle de lecture Datasphere
│       ├── dwc_synonym.hdbsynonym  # Synonym vers vTanks Datasphere
│       └── dwc_view.hdbview        # Vue HDI locale
│
├── srv/
│   ├── farm-tank-service.cds       # Définition service OData v4
│   ├── farm-tank-service.js        # Logique métier et handlers
│   ├── user.cds                    # Types utilisateurs
│   └── user.csv                    # Utilisateurs de test (mock auth)
│
├── app/
│   └── index.html                  # Page d'accueil
│
└── docs/
    ├── 01-INSTALLATION.md          # Guide d'installation
    ├── 02-DATASPHERE-SETUP.md      # Configuration Datasphere
    ├── 03-BTP-CONFIGURATION.md     # Configuration BTP
    ├── 04-DEPLOYMENT.md            # Déploiement
    ├── 05-BUILD-APPS.md            # Intégration Build Apps
    └── 06-TROUBLESHOOTING.md       # Résolution problèmes
```

## 📚 Documentation

| Guide | Description |
|-------|-------------|
| [01 - Installation](./docs/01-INSTALLATION.md) | Prérequis, installation locale |
| [02 - Datasphere Setup](./docs/02-DATASPHERE-SETUP.md) | Configuration de SAP Datasphere |
| [03 - BTP Configuration](./docs/03-BTP-CONFIGURATION.md) | User-Provided Service, Destinations, Rôles |
| [04 - Deployment](./docs/04-DEPLOYMENT.md) | Build et déploiement sur BTP |
| [05 - Build Apps](./docs/05-BUILD-APPS.md) | Intégration SAP Build Apps |
| [06 - Troubleshooting](./docs/06-TROUBLESHOOTING.md) | Résolution des problèmes courants |

## 🔑 Points clés de l'architecture

1. **User-Provided Service** (`ups_btp_dwc`) : La connexion Datasphere se fait via un User-Provided Service car Datasphere n'est pas dans le marketplace BTP.

2. **HDI Container** : Nécessaire pour stocker les `TankVolumes` en local dans HANA Cloud.

3. **Synonym HDI** : Permet de lire les données Datasphere (`vTanks`) comme si elles étaient locales.

4. **Authentification XSUAA** : Utilise les rôles `FieldTechnician` et `Admin` pour contrôler les accès.

## 🔧 Déploiement sur BTP

```bash
# 1. Créer le User-Provided Service Datasphere
cf cups ups_btp_dwc -p '{"host":"YOUR_HOST","port":"443","user":"YOUR_USER","password":"YOUR_PASSWORD","schema":"YOUR_SCHEMA"}'

# 2. Build
mbt build -t gen --mtar mta.tar

# 3. Deploy
cf deploy gen/mta.tar
```

## 🔗 Références

- [Projet SAP original](https://github.com/SAP-samples/datasphere-build-apps-data-entry)
- [Documentation CAP](https://cap.cloud.sap/docs/)
- [Documentation SAP Datasphere](https://help.sap.com/docs/SAP_DATASPHERE)
- [Documentation SAP Build Apps](https://help.sap.com/docs/BUILD_APPS)

## 📄 Licence

Apache 2.0