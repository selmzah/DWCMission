'use strict';

/**
 * Handlers métier pour FarmTankService
 *
 * Ce fichier implémente la logique métier pour le service OData v4.
 * Il gère notamment :
 * - L'enrichissement automatique des nouvelles lectures (date, technicien)
 * - Les validations métier avant persistence
 * - Les contrôles d'accès
 */
const cds = require('@sap/cds');

module.exports = class FarmTankService extends cds.ApplicationService {

  /** Initialisation des handlers */
  async init() {

    const { TankVolumes, Tanks } = this.entities;

    // ──────────────────────────────────────────────────────────
    // Handler BEFORE CREATE : Enrichissement automatique
    // ──────────────────────────────────────────────────────────
    this.before('CREATE', TankVolumes, async (req) => {
      const data = req.data;

      // Renseigner automatiquement la date de lecture si absente
      if (!data.ReadingDate) {
        data.ReadingDate = new Date().toISOString();
      }

      // Renseigner automatiquement le technicien depuis le contexte auth
      if (!data.Technician && req.user) {
        data.Technician = req.user.id || req.user.attr?.email || 'unknown';
      }

      // Validation : le volume doit être positif
      if (data.Volume !== undefined && data.Volume < 0) {
        req.error(400, `Le volume ne peut pas être négatif. Valeur reçue : ${data.Volume}`);
        return;
      }

      // Validation : le TankID est obligatoire
      if (!data.TankID) {
        req.error(400, 'Le champ TankID est obligatoire.');
        return;
      }
    });

    // ──────────────────────────────────────────────────────────
    // Handler BEFORE UPDATE : Validations de mise à jour
    // ──────────────────────────────────────────────────────────
    this.before('UPDATE', TankVolumes, async (req) => {
      const data = req.data;

      // Validation : le volume doit être positif si fourni
      if (data.Volume !== undefined && data.Volume < 0) {
        req.error(400, `Le volume ne peut pas être négatif. Valeur reçue : ${data.Volume}`);
        return;
      }
    });

    // ──────────────────────────────────────────────────────────
    // Handler AFTER READ Tanks : Calcul du pourcentage de remplissage
    // Ajoute une propriété virtuelle pour faciliter l'affichage
    // ──────────────────────────────────────────────────────────
    this.after('READ', Tanks, (tanks) => {
      const list = Array.isArray(tanks) ? tanks : [tanks];
      list.forEach(tank => {
        if (tank && tank.Capacity && tank.Capacity > 0) {
          // Calcul du pourcentage (0-100)
          tank.FillPercentage = Math.round((tank.CurrentLevel / tank.Capacity) * 100);
        } else if (tank) {
          tank.FillPercentage = 0;
        }
      });
    });

    // ──────────────────────────────────────────────────────────
    // Délégation au handler parent
    // ──────────────────────────────────────────────────────────
    return super.init();
  }
};
