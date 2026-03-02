# 01 - Guide d'installation

## Prérequis

### Comptes et abonnements requis

| Service | Description |
|---------|-------------|
| **SAP BTP** | Compte Business Technology Platform avec Cloud Foundry activé |
| **SAP Datasphere** | Tenant Datasphere actif (essai ou production) |
| **SAP HANA Cloud** | Instance HANA Cloud dans votre espace BTP |
| **SAP Build Apps** *(optionnel)* | Pour l'interface mobile |
| **SAP Analytics Cloud** *(optionnel)* | Pour les dashboards |

### Outils locaux

| Outil | Version minimale | Installation |
|-------|-----------------|--------------|
| **Node.js** | 18.x | [nodejs.org](https://nodejs.org) |
| **npm** | 9.x | Inclus avec Node.js |
| **@sap/cds-dk** | 7.x | `npm install -g @sap/cds-dk` |
| **Cloud Foundry CLI** | 8.x | [Voir doc CF](https://docs.cloudfoundry.org/cf-cli/install-go-cli.html) |
| **MTA Build Tool** | latest | `npm install -g mbt` |
| **cf multiapps plugin** | latest | `cf install-plugin multiapps` |

---

## Installation

### Étape 1 : Cloner le dépôt

```bash
git clone https://github.com/selmzah/DWCMission.git
cd DWCMission
```

### Étape 2 : Installer les dépendances

```bash
npm install
```

### Étape 3 : Vérifier l'installation CDS

```bash
cds version
```

Vous devriez voir une sortie similaire à :
```
@cap-js/sqlite: 1.x.x
@sap/cds: 7.x.x
@sap/cds-dk: 7.x.x
```

### Étape 4 : Lancer en mode développement local

```bash
cds watch
```

Le service sera accessible sur `http://localhost:4004`

> **Note :** En mode local, l'application utilise SQLite et des données de mock. Aucune connexion Datasphere n'est nécessaire pour tester localement.

---

## Structure du projet

```
DWCMission/
├── package.json          # Configuration Node.js / CDS
├── mta.yaml              # Configuration déploiement BTP
├── xs-security.json      # Rôles et scopes XSUAA
│
├── db/
│   ├── schema.cds        # Modèle de données (Tanks, TankVolumes)
│   ├── data/             # Données CSV de test
│   └── src/dwc/          # Artifacts HDI pour Datasphere
│
├── srv/
│   ├── farm-tank-service.cds   # Définition service OData v4
│   └── farm-tank-service.js    # Logique métier
│
├── app/
│   └── index.html        # Page d'accueil
│
└── docs/                 # Documentation complète
```

---

## Test local rapide

Une fois `cds watch` lancé, vous pouvez tester :

1. **Page d'accueil** : [http://localhost:4004](http://localhost:4004)
2. **Metadata OData** : [http://localhost:4004/odata/v4/farm-tank/$metadata](http://localhost:4004/odata/v4/farm-tank/$metadata)
3. **Liste des tanks** : [http://localhost:4004/odata/v4/farm-tank/Tanks](http://localhost:4004/odata/v4/farm-tank/Tanks)
4. **Lectures de volume** : [http://localhost:4004/odata/v4/farm-tank/TankVolumes](http://localhost:4004/odata/v4/farm-tank/TankVolumes)

---

## Prochaines étapes

1. [Configuration de SAP Datasphere →](./02-DATASPHERE-SETUP.md)
2. [Configuration BTP →](./03-BTP-CONFIGURATION.md)
3. [Déploiement →](./04-DEPLOYMENT.md)
