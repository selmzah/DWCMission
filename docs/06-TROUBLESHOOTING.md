# 06 - Résolution des problèmes courants

Ce guide liste les problèmes les plus fréquemment rencontrés lors du déploiement et de l'utilisation de DWCMission.

---

## Problèmes de déploiement

### Erreur : "Service ups_btp_dwc not found"

**Message :** `Could not bind service ups_btp_dwc: The service instance could not be found`

**Cause :** Le User-Provided Service n'a pas été créé avant le déploiement.

**Solution :**
```bash
cf cups ups_btp_dwc -p '{
  "host": "YOUR_HOST.hanacloud.ondemand.com",
  "port": "443",
  "user": "YOUR_SCHEMA#TECH_USER",
  "password": "YOUR_PASSWORD",
  "schema": "YOUR_SCHEMA"
}'
```

---

### Erreur : "HDI deployment failed"

**Message :** `Error during HDI container deployment`

**Cause possible 1 :** Le synonym pointe vers un schéma inexistant dans Datasphere.

**Solution :** Vérifiez `db/src/dwc/dwc_synonym.hdbsynonym` :
```json
{
  "vTanks": {
    "target": {
      "object": "vTanks",
      "schema": "VOTRE_VRAI_SCHEMA"
    }
  }
}
```

**Cause possible 2 :** L'utilisateur technique Datasphere n'a pas les droits SELECT sur `vTanks`.

**Solution :** Dans Datasphere, vérifiez les droits de votre Database User.

---

### Erreur : "Quota exceeded"

**Message :** `Failed to bind service: quota exceeded`

**Cause :** Pas assez de quota dans votre space BTP.

**Solution :**
```bash
# Vérifier les quotas
cf quotas
cf space-quota
```

Augmentez les quotas dans BTP Cockpit ou libérez des ressources.

---

## Problèmes d'authentification

### Erreur 401 : "Unauthorized"

**Cause :** Token XSUAA invalide ou expiré.

**Solution :**
1. Vérifiez que le service XSUAA est bien lié à l'application
2. Reconnectez-vous via l'interface Build Apps
3. Vérifiez les logs : `cf logs dwcmission-srv --recent`

---

### Erreur 403 : "Forbidden"

**Cause :** L'utilisateur n'a pas le rôle requis.

**Solution :**
1. Dans BTP Cockpit → Security → Users
2. Trouvez l'utilisateur
3. Assignez la role collection `DWCMission_FieldTechnician`

---

### En local : "You are not authorized"

**Cause :** CDS utilise le mode mock mais l'utilisateur n'est pas dans `srv/user.csv`.

**Solution :** Vérifiez `srv/user.csv` :
```csv
ID,password,roles
field.technician@tester.sap.com,initial,FieldTechnician
```

Utilisez les bons credentials lors du test :
```bash
curl -u "field.technician@tester.sap.com:initial" http://localhost:4004/odata/v4/farm-tank/Tanks
```

---

## Problèmes de connexion Datasphere

### Erreur : "vTanks view not accessible"

**Cause :** La vue vTanks n'est pas exposée pour consommation dans Datasphere.

**Solution :**
1. Dans Datasphere, ouvrez la vue `vTanks`
2. Dans les propriétés, activez **Expose for Consumption**
3. Redéployez la vue
4. Redéployez l'HDI Container : `cf deploy gen/mta.tar --modules dwcmission-db-deployer`

---

### Erreur : "Connection refused to Datasphere host"

**Cause :** Host ou port incorrect dans le User-Provided Service.

**Solution :**
```bash
# Vérifier les paramètres du service
cf service ups_btp_dwc
cf curl /v2/user_provided_service_instances/$(cf service ups_btp_dwc --guid)
```

Pour mettre à jour :
```bash
cf uups ups_btp_dwc -p '{
  "host": "CORRECT_HOST.hanacloud.ondemand.com",
  ...
}'
```

---

## Problèmes avec SAP Build Apps

### Entités OData non découvertes

**Cause :** La destination n'est pas bien configurée ou le service CAP est arrêté.

**Solution :**
1. Vérifiez que le service CAP tourne : `cf app dwcmission-srv`
2. Testez la destination dans BTP Cockpit → **Check Connection**
3. Vérifiez que `HTML5.ForwardAuthToken = true` est bien configuré

---

### Les données Tanks ne s'affichent pas

**Cause 1 :** L'HDI Container ne peut pas accéder au synonym Datasphere.

**Solution :** Vérifiez les logs du déploiement HDI :
```bash
cf logs dwcmission-db-deployer --recent
```

**Cause 2 :** En développement local, le fichier CSV n'est pas chargé.

**Solution :** Vérifiez que `db/data/com.sap.dwcm-Tanks.csv` existe et relancez `cds watch`.

---

## Commandes utiles

```bash
# Voir les logs en temps réel
cf logs dwcmission-srv

# Voir les derniers logs
cf logs dwcmission-srv --recent

# Redémarrer le service
cf restart dwcmission-srv

# Voir les variables d'environnement
cf env dwcmission-srv

# Voir l'état de tous les services
cf services

# Voir l'état de toutes les apps
cf apps

# SSH dans le container (debugging avancé)
cf ssh dwcmission-srv
```

---

## Obtenir de l'aide

- **Documentation CAP** : [cap.cloud.sap/docs](https://cap.cloud.sap/docs/)
- **Documentation Datasphere** : [help.sap.com/docs/SAP_DATASPHERE](https://help.sap.com/docs/SAP_DATASPHERE)
- **SAP Community** : [community.sap.com](https://community.sap.com)
- **Issues GitHub** : [github.com/selmzah/DWCMission/issues](https://github.com/selmzah/DWCMission/issues)
