--Aktuālās ēku ģeometrijas un daļa teksta datu, t.sk. adrese.
DROP MATERIALIZED VIEW IF EXISTS vzd.nivkis_ekas_rekviziti;

CREATE MATERIALIZED VIEW vzd.nivkis_ekas_rekviziti
AS
WITH p
AS (
  SELECT p."ObjectCadastreNrData" "BuildingCadastreNr"
    ,oo2."OwnershipStatus"
    ,STRING_AGG(DISTINCT op2."PersonStatus", ', ' ORDER BY op2."PersonStatus") "PersonStatus"
  FROM vzd.nivkis_property_object p
  LEFT OUTER JOIN vzd.nivkis_ownership o2 ON p."ProCadastreNr" = o2."ObjectCadastreNr"
  LEFT OUTER JOIN vzd.nivkis_ownership_status oo2 ON o2."OwnershipStatus" = oo2.id
  LEFT OUTER JOIN vzd.nivkis_ownership_personstatus op2 ON o2."PersonStatus" = op2.id
  WHERE o2."ObjectCadastreNr" IS NOT NULL
  GROUP BY p."ObjectCadastreNrData"
    ,oo2."OwnershipStatus"
  )
  ,a
AS (
  SELECT DISTINCT a.code "BuildingCadastreNr"
    ,u."BuildingUseKindName"
    ,b."BuildingName"
    ,b."BuildingExploitYear"
    ,UNNEST(e."MaterialKindName") "MaterialKindName1"
    ,m."MaterialKindName" "MaterialKindName2"
    ,b."BuildingGroundFloors"
    ,v."ARCode"
    ,v2.std
    ,COALESCE(oo."OwnershipStatus", p."OwnershipStatus") "OwnershipStatus"
    ,COALESCE(op."PersonStatus", p."PersonStatus") "PersonStatus"
    ,a.geom
  FROM vzd.nivkis_buves a
  LEFT OUTER JOIN vzd.nivkis_building b ON a.code = b."BuildingCadastreNr"
  LEFT OUTER JOIN vzd.nivkis_building_element e ON a.code = e."BuildingCadastreNr"
    AND e."BuildingElementName" = 1
  LEFT OUTER JOIN vzd.nivkis_building_usekind u ON b."BuildingUseKindId" = u."BuildingUseKindId"
  LEFT OUTER JOIN vzd.nivkis_building_materialkind m ON b."MaterialKindId" = m."MaterialKindId"
  LEFT OUTER JOIN vzd.nivkis_address v ON a.code = v."ObjectCadastreNr"
  LEFT OUTER JOIN vzd.adreses v2 ON v."ARCode" = v2.adr_cd
  LEFT OUTER JOIN p ON a.code = p."BuildingCadastreNr"
  LEFT OUTER JOIN vzd.nivkis_ownership o ON a.code = o."ObjectCadastreNr"
  LEFT OUTER JOIN vzd.nivkis_ownership_status oo ON o."OwnershipStatus" = oo.id
  LEFT OUTER JOIN vzd.nivkis_ownership_personstatus op ON o."PersonStatus" = op.id
  WHERE a.date_deleted IS NULL
    AND a.object_code < 6000000000
    AND b.date_deleted IS NULL
    AND v.date_deleted IS NULL
    AND v2.dat_beig IS NULL
    AND o.date_deleted IS NULL
  )
  ,b
AS (
  SELECT "BuildingCadastreNr"
    ,"BuildingUseKindName"
    ,"BuildingName"
    ,"BuildingExploitYear"
    ,COALESCE("MaterialKindName1", "MaterialKindName2") "MaterialKindName"
    ,"BuildingGroundFloors"
    ,"ARCode"
    ,std
    ,"OwnershipStatus"
    ,STRING_AGG(DISTINCT "PersonStatus", ', ' ORDER BY "PersonStatus") "PersonStatus"
    ,geom
  FROM a
  GROUP BY "BuildingCadastreNr"
    ,"BuildingUseKindName"
    ,"BuildingName"
    ,"BuildingExploitYear"
    ,"MaterialKindName"
    ,"BuildingGroundFloors"
    ,"ARCode"
    ,std
    ,"OwnershipStatus"
    ,geom
  )
  ,c
AS (
  SELECT "BuildingCadastreNr"
    ,"BuildingUseKindName"
    ,"BuildingName"
    ,"BuildingExploitYear"
    ,"MaterialKindName"
    ,"BuildingGroundFloors"
    ,"ARCode"
    ,std
    ,ARRAY_AGG("OwnershipStatus" || ': ' || "PersonStatus" ORDER BY "OwnershipStatus", "PersonStatus") "Ownership"
    ,geom
  FROM b
  GROUP BY "BuildingCadastreNr"
    ,"BuildingUseKindName"
    ,"BuildingName"
    ,"BuildingExploitYear"
    ,"MaterialKindName"
    ,"BuildingGroundFloors"
    ,"ARCode"
    ,std
    ,geom
  )
SELECT "BuildingCadastreNr"
  ,"BuildingUseKindName"
  ,"BuildingName"
  ,"BuildingExploitYear"
  ,ARRAY_AGG(DISTINCT "MaterialKindName" ORDER BY "MaterialKindName") "MaterialKindName"
  ,"BuildingGroundFloors"
  ,ARRAY_AGG(DISTINCT "ARCode" ORDER BY "ARCode") "ARCode"
  ,ARRAY_AGG(DISTINCT std ORDER BY std) std
  ,"Ownership"
  ,geom
FROM c
GROUP BY "BuildingCadastreNr"
  ,"BuildingUseKindName"
  ,"BuildingName"
  ,"BuildingExploitYear"
  ,"BuildingGroundFloors"
  ,"Ownership"
  ,geom
WITH NO DATA;

CREATE INDEX nivkis_ekas_rekviziti_geom_idx ON vzd.nivkis_ekas_rekviziti USING GIST (geom);

--Ar superlietotāja tiesībām.
ALTER MATERIALIZED VIEW vzd.nivkis_ekas_rekviziti OWNER TO scheduler;