# 04 - Déploiement sur SAP BTP

Ce guide décrit le déploiement de l'application DWCMission sur SAP BTP Cloud Foundry.

---

## Prérequis

- ✅ [Installation locale fonctionnelle](./01-INSTALLATION.md)
- ✅ [Datasphere configuré](./02-DATASPHERE-SETUP.md)
- ✅ [User-Provided Service `ups_btp_dwc` créé](./03-BTP-CONFIGURATION.md)
- ✅ Connecté à Cloud Foundry : `cf login -a API_URL -o ORG -s SPACE`
- ✅ `mbt` installé : `npm install -g mbt`
- ✅ Plugin multiapps installé : `cf install-plugin multiapps`

---

## Étape 1 : Mise à jour du fichier HDI synonym

Avant de déployer, mettez à jour le fichier `db/src/dwc/dwc_synonym.hdbsynonym` avec le schéma réel de votre Database User Datasphere :

```json
{
  "vTanks": {
    "target": {
      "object": "vTanks",
      "schema": "TANK_FARM_TECH_USER"
    }
  }
}
```

Remplacez `TANK_FARM_TECH_USER` par le schéma réel indiqué dans votre configuration Datasphere.

De même, mettez à jour `db/src/dwc/dwc_role.hdbrole` :

```json
{
  "role": {
    "name": "dwc_role",
    "object_privileges": [
      {
        "name": "vTanks",
        "type": "VIEW",
        "privileges": ["SELECT"],
        "schema": "TANK_FARM_TECH_USER"
      }
    ]
  }
}
```

---

## Étape 2 : Build de l'application

### 2.1 Build CDS

```bash
cds build --production
```

Cela génère le dossier `gen/` avec les artifacts optimisés pour la production.

### 2.2 Build MTA

```bash
mbt build -t gen --mtar mta.tar
```

Cette commande :
- Compile tous les modules MTA
- Crée le fichier `gen/mta.tar` prêt pour le déploiement

---

## Étape 3 : Déploiement

```bash
cf deploy gen/mta.tar
```

Le déploiement prend généralement 5 à 10 minutes. Vous verrez la progression en temps réel.

### Déploiement partiel (si besoin)

Pour redéployer uniquement le service sans toucher à la base de données :

```bash
cf deploy gen/mta.tar --modules dwcmission-srv
```

---

## Étape 4 : Vérification post-déploiement

### 4.1 Vérifier que les applications tournent

```bash
cf apps
```

Vous devriez voir :
```
name                  requested state   instances   memory   disk   urls
dwcmission-srv        started           1/1         256M     512M   dwcmission-srv.cfapps.eu10.hana.ondemand.com
dwcmission-app        started           1/1         64M      128M   dwcmission-app.cfapps.eu10.hana.ondemand.com
```

### 4.2 Vérifier les services

```bash
cf services
```

Vous devriez voir :
```
name                  service          plan         bound apps
dwcmission-db         hana             hdi-shared   dwcmission-srv, dwcmission-db-deployer
dwcmission-xsuaa      xsuaa            application  dwcmission-srv
ups_btp_dwc           user-provided                 dwcmission-db-deployer
```

### 4.3 Tester le service OData

```bash
# Récupérer l'URL du service
cf app dwcmission-srv | grep urls

# Tester avec curl (remplacer l'URL)
curl https://dwcmission-srv.cfapps.eu10.hana.ondemand.com/odata/v4/farm-tank/$metadata
```

### 4.4 Consulter les logs

```bash
# Logs en temps réel
cf logs dwcmission-srv

# Derniers logs
cf logs dwcmission-srv --recent
```

---

## Mise à jour après modification

Pour redéployer après des modifications :

```bash
# 1. Rebuild
mbt build -t gen --mtar mta.tar

# 2. Redéployer
cf deploy gen/mta.tar
```

---

## Suppression / Nettoyage

```bash
# Désinstaller l'application MTA
cf undeploy dwcmission --delete-services --delete-service-keys
```

> ⚠️ **Attention** : `--delete-services` supprime définitivement les données dans l'HDI Container.

---

## Prochaines étapes

1. [Intégration SAP Build Apps →](./05-BUILD-APPS.md)
