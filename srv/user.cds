/**
 * Définition des utilisateurs pour l'authentification basique
 * Utilisé uniquement en développement local (mock auth)
 * 
 * En production sur BTP, l'authentification est gérée par XSUAA.
 */
using { User } from '@sap/cds/common';

/**
 * Service de gestion des utilisateurs (usage interne)
 * Ce fichier est utilisé par CDS pour les mocks d'authentification locaux
 */
type Role : String enum {
  FieldTechnician;
  Admin;
}
