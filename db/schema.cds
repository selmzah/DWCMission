namespace com.sap.dwcm;

/**
 * Tanks : Données depuis Datasphere vTanks
 * Schema: POOL_XA_00002376
 */
entity Tanks {
  key TANK_ID           : String(30);
      LATITUDE          : Decimal(38,19);
      LONGITUDE         : Decimal(38,19);
      INSPECTIONDATE    : Date;
      SIZE              : String(10);
      MEASURETECHNIQUE  : String(10);
      MAX_CAPACITY      : Integer64;
      UOM               : String(10);
}

/**
 * TankVolumes : Lectures manuelles stockées en local
 */
entity TankVolumes {
  key ID          : UUID;
      TANK_ID     : String(30);
      Volume      : Integer;
      ReadingDate : DateTime;
      Technician  : String(100);
      Notes       : String(500);
}