/**
 * Définition du service OData v4 : FarmTankService
 * 
 * Ce service expose les données via OData v4 à destination de :
 * - SAP Build Apps (interface mobile des techniciens)
 * - SAP Analytics Cloud (tableaux de bord)
 * - Tout client OData standard
 */
using com.sap.dwcm from '../db/schema';

/**
 * FarmTankService
 * Accessible à l'URL : /odata/v4/farm-tank
 */
service FarmTankService @(path: '/odata/v4/farm-tank') {

  /**
   * Tanks : Données master des réservoirs (lecture seule)
   * Source : SAP Datasphere via synonym HDI
   * Utilisateurs autorisés : FieldTechnician, Admin
   */
  @readonly
  @(restrict: [
    { grant: 'READ', to: ['FieldTechnician', 'Admin'] }
  ])
  entity Tanks as projection on dwcm.Tanks;

  /**
   * TankVolumes : Lectures manuelles de volume (CRUD complet)
   * Source : HDI Container local (HANA Cloud)
   * Lecture : FieldTechnician, Admin
   * Écriture : FieldTechnician, Admin
   */
  @(restrict: [
    { grant: 'READ',   to: ['FieldTechnician', 'Admin'] },
    { grant: 'CREATE', to: ['FieldTechnician', 'Admin'] },
    { grant: 'UPDATE', to: ['FieldTechnician', 'Admin'] },
    { grant: 'DELETE', to: ['Admin'] }
  ])
  entity TankVolumes as projection on dwcm.TankVolumes;
}
