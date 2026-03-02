/**
 * Modèle de données DWCMission
 * 
 * Ce fichier définit les entités principales de l'application :
 * - Tanks      : Données master des réservoirs (lues depuis SAP Datasphere)
 * - TankVolumes: Lectures manuelles de volume (stockées dans l'HDI Container local)
 */
namespace com.sap.dwcm;

/**
 * Tanks : Données master des réservoirs
 * 
 * Cette entité est mappée via un synonym HDI sur la vue vTanks 
 * exposée par SAP Datasphere. Elle est donc en lecture seule.
 * 
 * En développement local (sans Datasphere), les données sont 
 * chargées depuis db/data/com.sap.dwcm-Tanks.csv
 */
entity Tanks {
  key TankID       : String(10);        // Identifiant unique du réservoir
      TankName     : String(100);       // Nom descriptif du réservoir
      Capacity     : Integer;           // Capacité maximale en litres
      CurrentLevel : Integer;           // Niveau actuel en litres
      Location     : String(200);       // Localisation géographique
      Status       : String(20);        // Statut : ACTIVE, MAINTENANCE, INACTIVE
}

/**
 * TankVolumes : Lectures manuelles de volume
 * 
 * Cette entité stocke les mesures saisies par les techniciens terrain.
 * Elle est persistée dans l'HDI Container local (HANA Cloud).
 */
entity TankVolumes {
  key ID          : UUID;               // Identifiant unique généré automatiquement
      TankID      : String(10);         // Référence au réservoir
      Volume      : Integer;            // Volume mesuré en litres
      ReadingDate : DateTime;           // Date et heure de la mesure
      Technician  : String(100);        // Email/nom du technicien
      Notes       : String(500);        // Observations éventuelles
}
