--nivkis_property.
DROP TABLE IF EXISTS vzd.nivkis_property;

CREATE TABLE vzd.nivkis_property (
  id SERIAL PRIMARY KEY
  ,"PropertyKind" SMALLINT NOT NULL
  ,"ProCadastreNr" VARCHAR(11) NOT NULL
  ,"ShareFlatProperty" BOOLEAN NULL
  ,"PropertyName" TEXT NULL
  ,"PropertyParcelTotalArea" INT NULL
  ,"PropertyPremiseGroupTotalArea" DECIMAL(7, 1) NULL
  ,"LandbookFolioNr" VARCHAR(12) NULL --Korektu datu gadījumā BIGINT, bet VZD mēdz ievadīt kļūdainus datus, jo specifikācijā šis ir teksta lauks.
  ,"LandbookFolioLiterNr" TEXT NULL
  ,"LandbookOfficeName" TEXT NULL
  ,"NotCorroboratedInLandbook" BOOLEAN NULL
  ,date_created DATE NOT NULL
  ,date_deleted DATE NULL
  );

COMMENT ON TABLE vzd.nivkis_property IS 'Nekustamā īpašuma valsts kadastra informācijas sistēmas atvērtie teksta dati par nekustamajiem īpašumiem.';

COMMENT ON COLUMN vzd.nivkis_property.id IS 'ID.';

COMMENT ON COLUMN vzd.nivkis_property."PropertyKind" IS 'Nekustamā īpašuma veida kods.';

COMMENT ON COLUMN vzd.nivkis_property."ProCadastreNr" IS 'Nekustamā īpašuma kadastra Nr.';

COMMENT ON COLUMN vzd.nivkis_property."ShareFlatProperty" IS 'Sadales dzīvokļa īpašumos pazīme.';

COMMENT ON COLUMN vzd.nivkis_property."PropertyName" IS 'Nekustamā īpašuma nosaukums.';

COMMENT ON COLUMN vzd.nivkis_property."PropertyParcelTotalArea" IS 'Īpašuma sastāvā esošo zemes vienību kopējā platība, m².';

COMMENT ON COLUMN vzd.nivkis_property."PropertyPremiseGroupTotalArea" IS 'Dzīvokļa īpašuma sastāvā esošo telpu grupu kopējā platība, m².';

COMMENT ON COLUMN vzd.nivkis_property."LandbookFolioNr" IS 'Zemesgrāmatas nodalījuma Nr.';

COMMENT ON COLUMN vzd.nivkis_property."LandbookFolioLiterNr" IS 'Apakšnodalījuma Nr. dzīvokļa īpašumam.';

COMMENT ON COLUMN vzd.nivkis_property."LandbookOfficeName" IS 'Apgabaltiesu zemesgrāmatas nodaļas nosaukums.';

COMMENT ON COLUMN vzd.nivkis_property."NotCorroboratedInLandbook" IS 'Kadastra datos veiktās izmaiņas nav nostiprinātas zemesgrāmatā.';

COMMENT ON COLUMN vzd.nivkis_property.date_created IS 'Izveidošanas datums. Atbilst datu kopā norādītajam datējumam.';

COMMENT ON COLUMN vzd.nivkis_property.date_deleted IS 'Dzēšanas datums. Atbilst vecākajā datu kopā, kurā vairs nav objekta ar šādiem atribūtiem, norādītajam datējumam.';

GRANT SELECT, INSERT, UPDATE, DELETE
  ON TABLE vzd.nivkis_property
  TO scheduler;

GRANT SELECT, UPDATE
  ON SEQUENCE vzd.nivkis_property_id_seq
  TO scheduler;

--nivkis_property_object.
DROP TABLE IF EXISTS vzd.nivkis_property_object;

CREATE TABLE vzd.nivkis_property_object (
  id SERIAL PRIMARY KEY
  ,"ProCadastreNr" VARCHAR(11) NOT NULL
  ,"ObjectKindData" SMALLINT NOT NULL
  ,"ObjectCadastreNrData" TEXT NOT NULL
  ,"ShareParts" BIGINT NULL
  ,"NrOfShares" BIGINT NULL
  ,date_created DATE NOT NULL
  ,date_deleted DATE NULL
  );

COMMENT ON TABLE vzd.nivkis_property_object IS 'Nekustamā īpašuma valsts kadastra informācijas sistēmas atvērtie teksta dati par nekustamo īpašumu sastāvu.';

COMMENT ON COLUMN vzd.nivkis_property_object.id IS 'ID.';

COMMENT ON COLUMN vzd.nivkis_property_object."ProCadastreNr" IS 'Nekustamā īpašuma kadastra Nr.';

COMMENT ON COLUMN vzd.nivkis_property_object."ObjectKindData" IS 'Kadastra objekta veida kods.';

COMMENT ON COLUMN vzd.nivkis_property_object."ObjectCadastreNrData" IS 'Kadastra objekta kadastra apzīmējums.';

COMMENT ON COLUMN vzd.nivkis_property_object."ShareParts" IS 'Dzīvokļa īpašuma kopīpašuma domājamās daļas vai nekustamā īpašuma objekta nesadalītās daļas skaitītājs.';

COMMENT ON COLUMN vzd.nivkis_property_object."NrOfShares" IS 'Dzīvokļa īpašuma kopīpašuma domājamās daļas vai nekustamā īpašuma objekta nesadalītās daļas saucējs.';

COMMENT ON COLUMN vzd.nivkis_property_object.date_created IS 'Izveidošanas datums. Atbilst datu kopā norādītajam datējumam.';

COMMENT ON COLUMN vzd.nivkis_property_object.date_deleted IS 'Dzēšanas datums. Atbilst vecākajā datu kopā, kurā vairs nav objekta ar šādiem atribūtiem, norādītajam datējumam.';

GRANT SELECT, INSERT, UPDATE, DELETE
  ON TABLE vzd.nivkis_property_object
  TO scheduler;

GRANT SELECT, UPDATE
  ON SEQUENCE vzd.nivkis_property_object_id_seq
  TO scheduler;

--PropertyKind klasifikators.
DROP TABLE IF EXISTS vzd.nivkis_property_kind;

CREATE TABLE vzd.nivkis_property_kind (
  id SERIAL PRIMARY KEY
  ,"PropertyKind" TEXT NOT NULL
  );

COMMENT ON TABLE vzd.nivkis_property_kind IS 'Nekustamā īpašuma veidu klasifikators Nekustamā īpašuma valsts kadastra informācijas sistēmas atvērtajos teksta datos.';

COMMENT ON COLUMN vzd.nivkis_property_kind.id IS 'Kods.';

COMMENT ON COLUMN vzd.nivkis_property_kind."PropertyKind" IS 'Nosaukums.';

GRANT SELECT, INSERT, UPDATE
  ON TABLE vzd.nivkis_property_kind
  TO scheduler;

GRANT SELECT, UPDATE
  ON SEQUENCE vzd.nivkis_property_kind_id_seq
  TO scheduler;

ALTER TABLE vzd.nivkis_property ADD CONSTRAINT "nivkis_property_fk_PropertyKind" FOREIGN KEY ("PropertyKind") REFERENCES vzd.nivkis_property_kind (id);

--ObjectKindData klasifikators.
DROP TABLE IF EXISTS vzd.nivkis_property_object_kind;

CREATE TABLE vzd.nivkis_property_object_kind (
  id SERIAL PRIMARY KEY
  ,"ObjectKindData" TEXT NOT NULL
  );

COMMENT ON TABLE vzd.nivkis_property_object_kind IS 'Kadastra objekta veidu klasifikators Nekustamā īpašuma valsts kadastra informācijas sistēmas atvērtajos teksta datos.';

COMMENT ON COLUMN vzd.nivkis_property_object_kind.id IS 'Kods.';

COMMENT ON COLUMN vzd.nivkis_property_object_kind."ObjectKindData" IS 'Nosaukums.';

GRANT SELECT, INSERT, UPDATE
  ON TABLE vzd.nivkis_property_object_kind
  TO scheduler;

GRANT SELECT, UPDATE
  ON SEQUENCE vzd.nivkis_property_object_kind_id_seq
  TO scheduler;

ALTER TABLE vzd.nivkis_property_object ADD CONSTRAINT "nivkis_property_object_fk_ObjectKindData" FOREIGN KEY ("ObjectKindData") REFERENCES vzd.nivkis_property_object_kind (id);

--nivkis_ownership.
DROP TABLE IF EXISTS vzd.nivkis_ownership;

CREATE TABLE vzd.nivkis_ownership (
  id serial PRIMARY KEY
  ,"ObjectCadastreNr" VARCHAR(14) NOT NULL
  ,"OwnershipStatus" SMALLINT NOT NULL
  ,"PersonStatus" SMALLINT NOT NULL
  ,date_created DATE NOT NULL
  ,date_deleted DATE NULL
  );

COMMENT ON TABLE vzd.nivkis_ownership IS 'Nekustamā īpašuma valsts kadastra informācijas sistēmas atvērtie teksta dati par personu īpašumtiesībām.';

COMMENT ON COLUMN vzd.nivkis_ownership.id IS 'ID.';

COMMENT ON COLUMN vzd.nivkis_ownership."ObjectCadastreNr" IS 'Kadastra objekta kadastra Nr. vai apzīmējums.';

COMMENT ON COLUMN vzd.nivkis_ownership."OwnershipStatus" IS 'Personas īpašuma tiesību statusa kods.';

COMMENT ON COLUMN vzd.nivkis_ownership."PersonStatus" IS 'Personas statusa kods.';

COMMENT ON COLUMN vzd.nivkis_ownership.date_created IS 'Izveidošanas datums. Atbilst datu kopā norādītajam datējumam.';

COMMENT ON COLUMN vzd.nivkis_ownership.date_deleted IS 'Dzēšanas datums. Atbilst vecākajā datu kopā, kurā vairs nav objekta ar šādiem atribūtiem, norādītajam datējumam.';

GRANT SELECT, INSERT, UPDATE, DELETE
  ON TABLE vzd.nivkis_ownership
  TO scheduler;

GRANT SELECT, UPDATE
  ON SEQUENCE vzd.nivkis_ownership_id_seq
  TO scheduler;

--OwnershipStatus klasifikators.
DROP TABLE IF EXISTS vzd.nivkis_ownership_status;

CREATE TABLE vzd.nivkis_ownership_status (
  id SERIAL PRIMARY KEY
  ,"OwnershipStatus" TEXT NOT NULL
  );

COMMENT ON TABLE vzd.nivkis_ownership_status IS 'Personas īpašuma tiesību statusu klasifikators Nekustamā īpašuma valsts kadastra informācijas sistēmas atvērtajos teksta datos.';

COMMENT ON COLUMN vzd.nivkis_ownership_status.id IS 'Kods.';

COMMENT ON COLUMN vzd.nivkis_ownership_status."OwnershipStatus" IS 'Nosaukums.';

GRANT SELECT, INSERT, UPDATE
  ON TABLE vzd.nivkis_ownership_status
  TO scheduler;

GRANT SELECT, UPDATE
  ON SEQUENCE vzd.nivkis_ownership_status_id_seq
  TO scheduler;

ALTER TABLE vzd.nivkis_ownership ADD CONSTRAINT "nivkis_ownership_fk_OwnershipStatus" FOREIGN KEY ("OwnershipStatus") REFERENCES vzd.nivkis_ownership_status (id);

--PersonStatus klasifikators.
DROP TABLE IF EXISTS vzd.nivkis_ownership_personstatus;

CREATE TABLE vzd.nivkis_ownership_personstatus (
  id SERIAL PRIMARY KEY
  ,"PersonStatus" TEXT NOT NULL
  );

COMMENT ON TABLE vzd.nivkis_ownership_personstatus IS 'Personas statusu klasifikators Nekustamā īpašuma valsts kadastra informācijas sistēmas atvērtajos teksta datos.';

COMMENT ON COLUMN vzd.nivkis_ownership_personstatus.id IS 'Kods.';

COMMENT ON COLUMN vzd.nivkis_ownership_personstatus."PersonStatus" IS 'Nosaukums.';

GRANT SELECT, INSERT, UPDATE
  ON TABLE vzd.nivkis_ownership_personstatus
  TO scheduler;

GRANT SELECT, UPDATE
  ON SEQUENCE vzd.nivkis_ownership_personstatus_id_seq
  TO scheduler;

ALTER TABLE vzd.nivkis_ownership ADD CONSTRAINT "nivkis_ownership_fk_PersonStatus" FOREIGN KEY ("PersonStatus") REFERENCES vzd.nivkis_ownership_personstatus (id);

--nivkis_parcel.
DROP TABLE IF EXISTS vzd.nivkis_parcel;

CREATE TABLE vzd.nivkis_parcel (
  id SERIAL PRIMARY KEY
  ,"ParcelCadastreNr" VARCHAR(11) NOT NULL
  ,"ParcelStatusKindId" SMALLINT NOT NULL
  ,"ParcelArea" INT NOT NULL
  ,"ParcelLizValue" SMALLINT
  ,"NewForestArea" INT
  ,date_created DATE NOT NULL
  ,date_deleted DATE NULL
  );

COMMENT ON TABLE vzd.nivkis_parcel IS 'Nekustamā īpašuma valsts kadastra informācijas sistēmas atvērtie teksta dati par zemes vienībām.';

COMMENT ON COLUMN vzd.nivkis_parcel.id IS 'ID.';

COMMENT ON COLUMN vzd.nivkis_parcel."ParcelCadastreNr" IS 'Zemes vienības kadastra apzīmējums.';

COMMENT ON COLUMN vzd.nivkis_parcel."ParcelStatusKindId" IS 'Zemes vienības statusa kods.';

COMMENT ON COLUMN vzd.nivkis_parcel."ParcelArea" IS 'Zemes vienības platība, m².';

COMMENT ON COLUMN vzd.nivkis_parcel."ParcelLizValue" IS 'Zemes vienības vidējais lauksaimniecībā izmantojamās zemes kvalitātes novērtējums ballēs.';

COMMENT ON COLUMN vzd.nivkis_parcel."NewForestArea" IS 'Jaunaudzes platība, m².';

COMMENT ON COLUMN vzd.nivkis_parcel.date_created IS 'Izveidošanas datums. Atbilst datu kopā norādītajam datējumam.';

COMMENT ON COLUMN vzd.nivkis_parcel.date_deleted IS 'Dzēšanas datums. Atbilst vecākajā datu kopā, kurā vairs nav objekta ar šādiem atribūtiem, norādītajam datējumam.';

GRANT SELECT, INSERT, UPDATE
  ON TABLE vzd.nivkis_parcel
  TO scheduler;

GRANT SELECT, UPDATE
  ON SEQUENCE vzd.nivkis_parcel_id_seq
  TO scheduler;

--ParcelStatus klasifikators.
DROP TABLE IF EXISTS vzd.nivkis_parcel_status;

CREATE TABLE vzd.nivkis_parcel_status (
  "ParcelStatusKindId" SMALLINT NOT NULL PRIMARY KEY
  ,"ParcelStatusKindName" TEXT NOT NULL
  );

GRANT SELECT, INSERT, UPDATE
  ON TABLE vzd.nivkis_parcel_status
  TO scheduler;

COMMENT ON TABLE vzd.nivkis_parcel_status IS 'Zemes vienības statusu klasifikators Nekustamā īpašuma valsts kadastra informācijas sistēmas atvērtajos teksta datos.';

COMMENT ON COLUMN vzd.nivkis_parcel_status."ParcelStatusKindId" IS 'Kods.';

COMMENT ON COLUMN vzd.nivkis_parcel_status."ParcelStatusKindName" IS 'Nosaukums.';

ALTER TABLE vzd.nivkis_parcel ADD CONSTRAINT "nivkis_parcel_fk_ParcelStatusKindId" FOREIGN KEY ("ParcelStatusKindId") REFERENCES vzd.nivkis_parcel_status ("ParcelStatusKindId");

--nivkis_parcel_landpurpose.
DROP TABLE IF EXISTS vzd.nivkis_parcel_landpurpose;

CREATE TABLE vzd.nivkis_parcel_landpurpose (
  id SERIAL PRIMARY KEY
  ,"ParcelCadastreNr" VARCHAR(11) NOT NULL
  ,"LandPurposeKindId" SMALLINT NOT NULL
  ,"Areable" INT
  ,"Orchards" INT
  ,"Meadows" INT
  ,"Pastures" INT
  ,"Forest" INT
  ,"Bushes" INT
  ,"Swamp" INT
  ,"UnderFishPonds" INT
  ,"Flooded" INT
  ,"UnderBuildings" INT
  ,"UnderRoads" INT
  ,"OtherLand" INT
  ,"Drained" INT
  ,date_created DATE NOT NULL
  ,date_deleted DATE NULL
  );

COMMENT ON TABLE vzd.nivkis_parcel_landpurpose IS 'Nekustamā īpašuma valsts kadastra informācijas sistēmas atvērtie teksta dati par zemes vienību lietošanas mērķiem.';

COMMENT ON COLUMN vzd.nivkis_parcel_landpurpose.id IS 'ID.';

COMMENT ON COLUMN vzd.nivkis_parcel_landpurpose."ParcelCadastreNr" IS 'Zemes vienības kadastra apzīmējums.';

COMMENT ON COLUMN vzd.nivkis_parcel_landpurpose."LandPurposeKindId" IS 'Nekustamā īpašuma lietošanas mērķa kods.';

COMMENT ON COLUMN vzd.nivkis_parcel_landpurpose."Areable" IS 'Aramzeme, m².';

COMMENT ON COLUMN vzd.nivkis_parcel_landpurpose."Orchards" IS 'Augļu dārzs, m².';

COMMENT ON COLUMN vzd.nivkis_parcel_landpurpose."Meadows" IS 'Pļava, m².';

COMMENT ON COLUMN vzd.nivkis_parcel_landpurpose."Pastures" IS 'Ganības, m².';

COMMENT ON COLUMN vzd.nivkis_parcel_landpurpose."Forest" IS 'Mežs, m².';

COMMENT ON COLUMN vzd.nivkis_parcel_landpurpose."Bushes" IS 'Krūmājs, m².';

COMMENT ON COLUMN vzd.nivkis_parcel_landpurpose."Swamp" IS 'Purvs, m².';

COMMENT ON COLUMN vzd.nivkis_parcel_landpurpose."UnderFishPonds" IS 'Ūdens objektu zeme zem zivju dīķiem, m².';

COMMENT ON COLUMN vzd.nivkis_parcel_landpurpose."Flooded" IS 'Ūdens objektu zeme zem ūdeņiem, m².';

COMMENT ON COLUMN vzd.nivkis_parcel_landpurpose."UnderBuildings" IS 'Zeme zem ēkām un pagalmiem, m².';

COMMENT ON COLUMN vzd.nivkis_parcel_landpurpose."UnderRoads" IS 'Zeme zem ceļiem, m².';

COMMENT ON COLUMN vzd.nivkis_parcel_landpurpose."OtherLand" IS 'Pārējās zemes, m².';

COMMENT ON COLUMN vzd.nivkis_parcel_landpurpose."Drained" IS 'Meliorētā lauksaimniecībā izmantojamā zeme, m².';

COMMENT ON COLUMN vzd.nivkis_parcel_landpurpose.date_created IS 'Izveidošanas datums. Atbilst datu kopā norādītajam datējumam.';

COMMENT ON COLUMN vzd.nivkis_parcel_landpurpose.date_deleted IS 'Dzēšanas datums. Atbilst vecākajā datu kopā, kurā vairs nav objekta ar šādiem atribūtiem, norādītajam datējumam.';

GRANT SELECT, INSERT, UPDATE
  ON TABLE vzd.nivkis_parcel_landpurpose
  TO scheduler;

GRANT SELECT, UPDATE
  ON SEQUENCE vzd.nivkis_parcel_landpurpose_id_seq
  TO scheduler;

--LandPurposeKind klasifikators.
DROP TABLE IF EXISTS vzd.nivkis_parcel_landpurpose_kind;

CREATE TABLE vzd.nivkis_parcel_landpurpose_kind (
  "LandPurposeKindId" SMALLINT NOT NULL PRIMARY KEY
  ,"LandPurposeKindName" TEXT NOT NULL
  );

COMMENT ON TABLE vzd.nivkis_parcel_landpurpose_kind IS 'Nekustamā īpašuma lietošanas mērķu klasifikators Nekustamā īpašuma valsts kadastra informācijas sistēmas atvērtajos teksta datos.';

COMMENT ON COLUMN vzd.nivkis_parcel_landpurpose_kind."LandPurposeKindId" IS 'Kods.';

COMMENT ON COLUMN vzd.nivkis_parcel_landpurpose_kind."LandPurposeKindId" IS 'Nosaukums.';

GRANT SELECT, INSERT, UPDATE
  ON TABLE vzd.nivkis_parcel_landpurpose_kind
  TO scheduler;

ALTER TABLE vzd.nivkis_parcel_landpurpose ADD CONSTRAINT "nivkis_parcel_landpurpose_fk_LandPurposeKindId" FOREIGN KEY ("LandPurposeKindId") REFERENCES vzd.nivkis_parcel_landpurpose_kind ("LandPurposeKindId");

--nivkis_parcel_survey.
DROP TABLE IF EXISTS vzd.nivkis_parcel_survey;

CREATE TABLE vzd.nivkis_parcel_survey (
  id SERIAL PRIMARY KEY
  ,"ParcelCadastreNr" VARCHAR(11) NOT NULL
  ,"SurveyKind" SMALLINT NOT NULL
  ,"SurveyDate" DATE NOT NULL
  ,date_created DATE NOT NULL
  ,date_deleted DATE NULL
  );

COMMENT ON TABLE vzd.nivkis_parcel_survey IS 'Nekustamā īpašuma valsts kadastra informācijas sistēmas atvērtie teksta dati par zemes vienību kadastrālo uzmērīšanu.';

COMMENT ON COLUMN vzd.nivkis_parcel_survey.id IS 'ID.';

COMMENT ON COLUMN vzd.nivkis_parcel_survey."ParcelCadastreNr" IS 'Zemes vienības kadastra apzīmējums.';

COMMENT ON COLUMN vzd.nivkis_parcel_survey."SurveyKind" IS 'Mērniecības metodes kods.';

COMMENT ON COLUMN vzd.nivkis_parcel_survey."SurveyDate" IS 'Uzmērīšanas datums.';

COMMENT ON COLUMN vzd.nivkis_parcel_survey.date_created IS 'Izveidošanas datums. Atbilst datu kopā norādītajam datējumam.';

COMMENT ON COLUMN vzd.nivkis_parcel_survey.date_deleted IS 'Dzēšanas datums. Atbilst vecākajā datu kopā, kurā vairs nav objekta ar šādiem atribūtiem, norādītajam datējumam.';

GRANT SELECT, INSERT, UPDATE
  ON TABLE vzd.nivkis_parcel_survey
  TO scheduler;

GRANT SELECT, UPDATE
  ON SEQUENCE vzd.nivkis_parcel_survey_id_seq
  TO scheduler;

--SurveyKind klasifikators.
DROP TABLE IF EXISTS vzd.nivkis_parcel_survey_kind;

CREATE TABLE vzd.nivkis_parcel_survey_kind (
  id SERIAL PRIMARY KEY
  ,"SurveyKind" TEXT NOT NULL
  );

COMMENT ON TABLE vzd.nivkis_parcel_survey_kind IS 'Mērniecības metožu klasifikators Nekustamā īpašuma valsts kadastra informācijas sistēmas atvērtajos teksta datos.';

COMMENT ON COLUMN vzd.nivkis_parcel_survey_kind.id IS 'Kods.';

COMMENT ON COLUMN vzd.nivkis_parcel_survey_kind."SurveyKind" IS 'Nosaukums.';

GRANT SELECT, INSERT, UPDATE
  ON TABLE vzd.nivkis_parcel_survey_kind
  TO scheduler;

GRANT SELECT, UPDATE
  ON SEQUENCE vzd.nivkis_parcel_survey_kind_id_seq
  TO scheduler;

ALTER TABLE vzd.nivkis_parcel_survey ADD CONSTRAINT "nivkis_parcel_survey_fk_SurveyKind" FOREIGN KEY ("SurveyKind") REFERENCES vzd.nivkis_parcel_survey_kind (id);

--nivkis_parcel_planned.
DROP TABLE IF EXISTS vzd.nivkis_parcel_planned;

CREATE TABLE vzd.nivkis_parcel_planned (
  id SERIAL PRIMARY KEY
  ,"ParcelCadastreNr" VARCHAR(11) NOT NULL
  ,"VARISCode" INT
  ,"PlannedParcelCadastreNr" TEXT NOT NULL
  ,"PlannedParcelArea" BIGINT NOT NULL
  ,date_created DATE NOT NULL
  ,date_deleted DATE NULL
  );

COMMENT ON TABLE vzd.nivkis_parcel_planned IS 'Nekustamā īpašuma valsts kadastra informācijas sistēmas atvērtie teksta dati par plānotajām zemes vienībām.';

COMMENT ON COLUMN vzd.nivkis_parcel_planned.id IS 'ID.';

COMMENT ON COLUMN vzd.nivkis_parcel_planned."ParcelCadastreNr" IS 'Zemes vienības kadastra apzīmējums.';

COMMENT ON COLUMN vzd.nivkis_parcel_planned."VARISCode" IS 'Adresācijas objekta kods.';

COMMENT ON COLUMN vzd.nivkis_parcel_planned."PlannedParcelCadastreNr" IS 'Plānotās zemes vienības kadastra apzīmējums.';

COMMENT ON COLUMN vzd.nivkis_parcel_planned."PlannedParcelArea" IS 'Plānotās zemes vienības platība, m².';

COMMENT ON COLUMN vzd.nivkis_parcel_planned.date_created IS 'Izveidošanas datums. Atbilst datu kopā norādītajam datējumam.';

COMMENT ON COLUMN vzd.nivkis_parcel_planned.date_deleted IS 'Dzēšanas datums. Atbilst vecākajā datu kopā, kurā vairs nav objekta ar šādiem atribūtiem, norādītajam datējumam.';

GRANT SELECT, INSERT, UPDATE
  ON TABLE vzd.nivkis_parcel_planned
  TO scheduler;

GRANT SELECT, UPDATE
  ON SEQUENCE vzd.nivkis_parcel_planned_id_seq
  TO scheduler;

--nivkis_parcelpart.
DROP TABLE IF EXISTS vzd.nivkis_parcelpart;

CREATE TABLE vzd.nivkis_parcelpart (
  id SERIAL PRIMARY KEY
  ,"ParcelPartCadastreNr" VARCHAR(15) NOT NULL
  ,"ParcelCadastreNr" VARCHAR(11) NOT NULL
  ,"ParcelPartArea" INT NOT NULL
  ,"ParcelPartLizValue" SMALLINT
  ,date_created DATE NOT NULL
  ,date_deleted DATE NULL
  );

COMMENT ON TABLE vzd.nivkis_parcelpart IS 'Nekustamā īpašuma valsts kadastra informācijas sistēmas atvērtie teksta dati par zemes vienību daļām.';

COMMENT ON COLUMN vzd.nivkis_parcelpart.id IS 'ID.';

COMMENT ON COLUMN vzd.nivkis_parcelpart."ParcelPartCadastreNr" IS 'Zemes vienības daļas kadastra apzīmējums.';

COMMENT ON COLUMN vzd.nivkis_parcelpart."ParcelCadastreNr" IS 'Zemes vienības kadastra apzīmējums.';

COMMENT ON COLUMN vzd.nivkis_parcelpart."ParcelPartArea" IS 'Zemes vienības daļas platība, m².';

COMMENT ON COLUMN vzd.nivkis_parcelpart."ParcelPartLizValue" IS 'Zemes vienības daļas vidējais lauksaimniecībā izmantojamās zemes kvalitātes novērtējums ballēs.';

COMMENT ON COLUMN vzd.nivkis_parcelpart.date_created IS 'Izveidošanas datums. Atbilst datu kopā norādītajam datējumam.';

COMMENT ON COLUMN vzd.nivkis_parcelpart.date_deleted IS 'Dzēšanas datums. Atbilst vecākajā datu kopā, kurā vairs nav objekta ar šādiem atribūtiem, norādītajam datējumam.';

GRANT SELECT, INSERT, UPDATE
  ON TABLE vzd.nivkis_parcelpart
  TO scheduler;

GRANT SELECT, UPDATE
  ON SEQUENCE vzd.nivkis_parcelpart_id_seq
  TO scheduler;

--nivkis_parcelpart_landpurpose.
DROP TABLE IF EXISTS vzd.nivkis_parcelpart_landpurpose;

CREATE TABLE vzd.nivkis_parcelpart_landpurpose (
  id SERIAL PRIMARY KEY
  ,"ParcelPartCadastreNr" VARCHAR(15) NOT NULL
  ,"LandPurposeKindId" SMALLINT NOT NULL
  ,"Areable" INT
  ,"Orchards" INT
  ,"Meadows" INT
  ,"Pastures" INT
  ,"Forest" INT
  ,"Bushes" INT
  ,"Swamp" INT
  ,"UnderFishPonds" INT
  ,"Flooded" INT
  ,"UnderBuildings" INT
  ,"UnderRoads" INT
  ,"OtherLand" INT
  ,"Drained" INT
  ,date_created DATE NOT NULL
  ,date_deleted DATE NULL
  );

COMMENT ON TABLE vzd.nivkis_parcelpart_landpurpose IS 'Nekustamā īpašuma valsts kadastra informācijas sistēmas atvērtie teksta dati par zemes vienību daļu lietošanas mērķiem.';

COMMENT ON COLUMN vzd.nivkis_parcelpart_landpurpose.id IS 'ID.';

COMMENT ON COLUMN vzd.nivkis_parcelpart_landpurpose."ParcelPartCadastreNr" IS 'Zemes vienības daļas kadastra apzīmējums.';

COMMENT ON COLUMN vzd.nivkis_parcelpart_landpurpose."LandPurposeKindId" IS 'Nekustamā īpašuma lietošanas mērķa kods.';

COMMENT ON COLUMN vzd.nivkis_parcelpart_landpurpose."Areable" IS 'Aramzeme, m².';

COMMENT ON COLUMN vzd.nivkis_parcelpart_landpurpose."Orchards" IS 'Augļu dārzs, m².';

COMMENT ON COLUMN vzd.nivkis_parcelpart_landpurpose."Meadows" IS 'Pļava, m².';

COMMENT ON COLUMN vzd.nivkis_parcelpart_landpurpose."Pastures" IS 'Ganības, m².';

COMMENT ON COLUMN vzd.nivkis_parcelpart_landpurpose."Forest" IS 'Mežs, m².';

COMMENT ON COLUMN vzd.nivkis_parcelpart_landpurpose."Bushes" IS 'Krūmājs, m².';

COMMENT ON COLUMN vzd.nivkis_parcelpart_landpurpose."Swamp" IS 'Purvs, m².';

COMMENT ON COLUMN vzd.nivkis_parcelpart_landpurpose."UnderFishPonds" IS 'Ūdens objektu zeme zem zivju dīķiem, m².';

COMMENT ON COLUMN vzd.nivkis_parcelpart_landpurpose."Flooded" IS 'Ūdens objektu zeme zem ūdeņiem, m².';

COMMENT ON COLUMN vzd.nivkis_parcelpart_landpurpose."UnderBuildings" IS 'Zeme zem ēkām un pagalmiem, m².';

COMMENT ON COLUMN vzd.nivkis_parcelpart_landpurpose."UnderRoads" IS 'Zeme zem ceļiem, m².';

COMMENT ON COLUMN vzd.nivkis_parcelpart_landpurpose."OtherLand" IS 'Pārējās zemes, m².';

COMMENT ON COLUMN vzd.nivkis_parcelpart_landpurpose."Drained" IS 'Meliorētā lauksaimniecībā izmantojamā zeme, m².';

COMMENT ON COLUMN vzd.nivkis_parcelpart_landpurpose.date_created IS 'Izveidošanas datums. Atbilst datu kopā norādītajam datējumam.';

COMMENT ON COLUMN vzd.nivkis_parcelpart_landpurpose.date_deleted IS 'Dzēšanas datums. Atbilst vecākajā datu kopā, kurā vairs nav objekta ar šādiem atribūtiem, norādītajam datējumam.';

GRANT SELECT, INSERT, UPDATE
  ON TABLE vzd.nivkis_parcelpart_landpurpose
  TO scheduler;

GRANT SELECT, UPDATE
  ON SEQUENCE vzd.nivkis_parcelpart_landpurpose_id_seq
  TO scheduler;

ALTER TABLE vzd.nivkis_parcelpart_landpurpose ADD CONSTRAINT "nivkis_parcelpart_landpurpose_fk_LandPurposeKindId" FOREIGN KEY ("LandPurposeKindId") REFERENCES vzd.nivkis_parcel_landpurpose_kind ("LandPurposeKindId");

--nivkis_parcelpart_survey.
DROP TABLE IF EXISTS vzd.nivkis_parcelpart_survey;

CREATE TABLE vzd.nivkis_parcelpart_survey (
  id SERIAL PRIMARY KEY
  ,"ParcelPartCadastreNr" VARCHAR(15) NOT NULL
  ,"SurveyKind" SMALLINT NOT NULL
  ,"SurveyDate" DATE NOT NULL
  ,date_created DATE NOT NULL
  ,date_deleted DATE NULL
  );

COMMENT ON TABLE vzd.nivkis_parcelpart_survey IS 'Nekustamā īpašuma valsts kadastra informācijas sistēmas atvērtie teksta dati par zemes vienību daļu kadastrālo uzmērīšanu.';

COMMENT ON COLUMN vzd.nivkis_parcelpart_survey.id IS 'ID.';

COMMENT ON COLUMN vzd.nivkis_parcelpart_survey."ParcelPartCadastreNr" IS 'Zemes vienības daļas kadastra apzīmējums.';

COMMENT ON COLUMN vzd.nivkis_parcelpart_survey."SurveyKind" IS 'Mērniecības metodes kods.';

COMMENT ON COLUMN vzd.nivkis_parcelpart_survey."SurveyDate" IS 'Uzmērīšanas datums.';

COMMENT ON COLUMN vzd.nivkis_parcelpart_survey.date_created IS 'Izveidošanas datums. Atbilst datu kopā norādītajam datējumam.';

COMMENT ON COLUMN vzd.nivkis_parcelpart_survey.date_deleted IS 'Dzēšanas datums. Atbilst vecākajā datu kopā, kurā vairs nav objekta ar šādiem atribūtiem, norādītajam datējumam.';

GRANT SELECT, INSERT, UPDATE
  ON TABLE vzd.nivkis_parcelpart_survey
  TO scheduler;

GRANT SELECT, UPDATE
  ON SEQUENCE vzd.nivkis_parcelpart_survey_id_seq
  TO scheduler;

ALTER TABLE vzd.nivkis_parcelpart_survey ADD CONSTRAINT "nivkis_parcelpart_survey_fk_SurveyKind" FOREIGN KEY ("SurveyKind") REFERENCES vzd.nivkis_parcel_survey_kind (id);

--nivkis_building.
DROP TABLE IF EXISTS vzd.nivkis_building;

CREATE TABLE vzd.nivkis_building (
  id SERIAL PRIMARY KEY
  ,"BuildingCadastreNr" VARCHAR(14) NOT NULL
  ,"ParcelCadastreNr" VARCHAR(11) NOT NULL
  ,"BuildingName" TEXT
  ,"BuildingUseKindId" SMALLINT
  ,"BuildingArea" DECIMAL(10, 2)
  ,"BuildingConstrArea" DECIMAL(11, 2)
  ,"BuildingGroundFloors" SMALLINT
  ,"BuildingUndergroundFloors" SMALLINT
  ,"MaterialKindId" SMALLINT
  ,"BuildingPregCount" SMALLINT
  ,"BuildingAcceptionYears" SMALLINT[]
  ,"BuildingExploitYear" SMALLINT
  ,"BuildingDeprecation" SMALLINT
  ,"BuildingDepValDate" DATE
  ,"BuildingSurveyDate" DATE
  ,"NotForLandBook" BOOLEAN
  ,"Prereg" BOOLEAN
  ,"NotExist" BOOLEAN
  ,"EngineeringStructureType" SMALLINT
  ,"BuildingKindId" INT[]
  ,"BuildingHistoricalLiter" TEXT
  ,"BuildingHistoricalName" TEXT
  ,"LivingArea" DECIMAL(7, 1)
  ,"FlatAuxArea" DECIMAL(7, 1)
  ,"FlatOuterArea" DECIMAL(6, 1)
  ,"NonlivingInteriorArea" DECIMAL(8, 1)
  ,"NonlivingOuterArea" DECIMAL(7, 1)
  ,"SharedInteriorArea" DECIMAL(7, 1)
  ,"SharedOuterArea" DECIMAL(6, 1)
  ,date_created DATE NOT NULL
  ,date_deleted DATE NULL
  );

COMMENT ON TABLE vzd.nivkis_building IS 'Nekustamā īpašuma valsts kadastra informācijas sistēmas atvērtie teksta dati par būvēm.';

COMMENT ON COLUMN vzd.nivkis_building.id IS 'ID.';

COMMENT ON COLUMN vzd.nivkis_building."BuildingCadastreNr" IS 'Būves kadastra apzīmējums.';

COMMENT ON COLUMN vzd.nivkis_building."ParcelCadastreNr" IS 'Galvenās zemes vienības kadastra apzīmējums.';

COMMENT ON COLUMN vzd.nivkis_building."BuildingName" IS 'Būves nosaukums.';

COMMENT ON COLUMN vzd.nivkis_building."BuildingUseKindId" IS 'Galvenā lietošanas veida kods.';

COMMENT ON COLUMN vzd.nivkis_building."BuildingArea" IS 'Kopējā platība, m².';

COMMENT ON COLUMN vzd.nivkis_building."BuildingConstrArea" IS 'Apbūves laukums, m².';

COMMENT ON COLUMN vzd.nivkis_building."BuildingGroundFloors" IS 'Virszemes stāvu skaits.';

COMMENT ON COLUMN vzd.nivkis_building."BuildingUndergroundFloors" IS 'Pazemes stāvu skaits.';

COMMENT ON COLUMN vzd.nivkis_building."MaterialKindId" IS 'Ārsienu materiāla kods.';

COMMENT ON COLUMN vzd.nivkis_building."BuildingPregCount" IS 'Telpu grupu skaits būvē.';

COMMENT ON COLUMN vzd.nivkis_building."BuildingAcceptionYears" IS 'Ekspluatācijā pieņemšanas gadi.';

COMMENT ON COLUMN vzd.nivkis_building."BuildingExploitYear" IS 'Ekspluatācijas uzsākšanas gads.';

COMMENT ON COLUMN vzd.nivkis_building."BuildingDeprecation" IS 'Nolietojums, %.';

COMMENT ON COLUMN vzd.nivkis_building."BuildingDepValDate" IS 'Nolietojuma aprēķina datums.';

COMMENT ON COLUMN vzd.nivkis_building."BuildingSurveyDate" IS 'Kadastrālās uzmērīšanas datums.';

COMMENT ON COLUMN vzd.nivkis_building."NotForLandBook" IS 'Pazīme, ka dati nav izmantojami ierakstīšanai zemesgrāmatā.';

COMMENT ON COLUMN vzd.nivkis_building."Prereg" IS 'Pazīme par pirmsreģistrētu būvi.';

COMMENT ON COLUMN vzd.nivkis_building."NotExist" IS 'Pazīme, ka, veicot kadastrālo uzmērīšanu, būve apvidū nav konstatēta.';

COMMENT ON COLUMN vzd.nivkis_building."EngineeringStructureType" IS 'Inženierbūves veids kods.';

COMMENT ON COLUMN vzd.nivkis_building."BuildingKindId" IS 'Būves tipa kods.';

COMMENT ON COLUMN vzd.nivkis_building."BuildingHistoricalLiter" IS 'Būves liters.';

COMMENT ON COLUMN vzd.nivkis_building."BuildingHistoricalName" IS 'Būves vēsturiskais nosaukums.';

COMMENT ON COLUMN vzd.nivkis_building."LivingArea" IS 'Dzīvojamo telpu platība, m².';

COMMENT ON COLUMN vzd.nivkis_building."FlatAuxArea" IS 'Palīgtelpu platība, m².';

COMMENT ON COLUMN vzd.nivkis_building."FlatOuterArea" IS 'Dzīvojamo telpu grupu ārtelpu platība, m².';

COMMENT ON COLUMN vzd.nivkis_building."NonlivingInteriorArea" IS 'Nedzīvojamo telpu grupu iekštelpu platība, m².';

COMMENT ON COLUMN vzd.nivkis_building."NonlivingOuterArea" IS 'Nedzīvojamo telpu grupu ārtelpu platība, m².';

COMMENT ON COLUMN vzd.nivkis_building."SharedInteriorArea" IS 'Koplietošanas telpu grupu iekštelpu platība, m².';

COMMENT ON COLUMN vzd.nivkis_building."SharedOuterArea" IS 'Koplietošanas telpu grupu ārtelpu platība, m².';

COMMENT ON COLUMN vzd.nivkis_building.date_created IS 'Izveidošanas datums. Atbilst datu kopā norādītajam datējumam.';

COMMENT ON COLUMN vzd.nivkis_building.date_deleted IS 'Dzēšanas datums. Atbilst vecākajā datu kopā, kurā vairs nav objekta ar šādiem atribūtiem, norādītajam datējumam.';

GRANT SELECT, INSERT, UPDATE
  ON TABLE vzd.nivkis_building
  TO scheduler;

GRANT SELECT, UPDATE
  ON SEQUENCE vzd.nivkis_building_id_seq
  TO scheduler;

--EngineeringStructureType klasifikators.
DROP TABLE IF EXISTS vzd.nivkis_building_estype;

CREATE TABLE vzd.nivkis_building_estype (
  id SERIAL PRIMARY KEY
  ,"EngineeringStructureType" TEXT NOT NULL
  );

COMMENT ON TABLE vzd.nivkis_building_estype IS 'Inženierbūves veidu klasifikators Nekustamā īpašuma valsts kadastra informācijas sistēmas atvērtajos teksta datos.';

COMMENT ON COLUMN vzd.nivkis_building_estype.id IS 'Kods.';

COMMENT ON COLUMN vzd.nivkis_building_estype."EngineeringStructureType" IS 'Nosaukums.';

GRANT SELECT, INSERT, UPDATE
  ON TABLE vzd.nivkis_building_estype
  TO scheduler;

GRANT SELECT, UPDATE
  ON SEQUENCE vzd.nivkis_building_estype_id_seq
  TO scheduler;

ALTER TABLE vzd.nivkis_building ADD CONSTRAINT "nivkis_building_fk_EngineeringStructureType" FOREIGN KEY ("EngineeringStructureType") REFERENCES vzd.nivkis_building_estype (id);

--BuildingUseKind klasifikators.
DROP TABLE IF EXISTS vzd.nivkis_building_usekind;

CREATE TABLE vzd.nivkis_building_usekind (
  "BuildingUseKindId" SMALLINT NOT NULL PRIMARY KEY
  ,"BuildingUseKindName" TEXT NOT NULL
  );

COMMENT ON TABLE vzd.nivkis_building_usekind IS 'Galveno lietošanas veidu klasifikators Nekustamā īpašuma valsts kadastra informācijas sistēmas atvērtajos teksta datos.';

COMMENT ON COLUMN vzd.nivkis_building_usekind."BuildingUseKindId" IS 'Kods.';

COMMENT ON COLUMN vzd.nivkis_building_usekind."BuildingUseKindName" IS 'Nosaukums.';

GRANT SELECT, INSERT, UPDATE
  ON TABLE vzd.nivkis_building_usekind
  TO scheduler;

ALTER TABLE vzd.nivkis_building ADD CONSTRAINT "nivkis_building_fk_BuildingUseKindId" FOREIGN KEY ("BuildingUseKindId") REFERENCES vzd.nivkis_building_usekind ("BuildingUseKindId");

--BuildingKind klasifikators.
DROP TABLE IF EXISTS vzd.nivkis_building_kind;

CREATE TABLE vzd.nivkis_building_kind (
  "BuildingKindId" INT NOT NULL PRIMARY KEY
  ,"BuildingKindName" TEXT NOT NULL
  );

COMMENT ON TABLE vzd.nivkis_building_kind IS 'Būves tipu klasifikators Nekustamā īpašuma valsts kadastra informācijas sistēmas atvērtajos teksta datos.';

COMMENT ON COLUMN vzd.nivkis_building_kind."BuildingKindId" IS 'Kods.';

COMMENT ON COLUMN vzd.nivkis_building_kind."BuildingKindName" IS 'Nosaukums.';

GRANT SELECT, INSERT, UPDATE
  ON TABLE vzd.nivkis_building_kind
  TO scheduler;

--BuildingMaterialKind klasifikators.
DROP TABLE IF EXISTS vzd.nivkis_building_materialkind;

CREATE TABLE vzd.nivkis_building_materialkind (
  "MaterialKindId" SMALLINT NOT NULL PRIMARY KEY
  ,"MaterialKindName" TEXT NOT NULL
  );

COMMENT ON TABLE vzd.nivkis_building_materialkind IS 'Ārsienu materiālu klasifikators Nekustamā īpašuma valsts kadastra informācijas sistēmas atvērtajos teksta datos.';

COMMENT ON COLUMN vzd.nivkis_building_materialkind."MaterialKindId" IS 'Kods.';

COMMENT ON COLUMN vzd.nivkis_building_materialkind."MaterialKindName" IS 'Nosaukums.';

GRANT SELECT, INSERT, UPDATE
  ON TABLE vzd.nivkis_building_materialkind
  TO scheduler;

ALTER TABLE vzd.nivkis_building ADD CONSTRAINT "nivkis_building_fk_MaterialKindId" FOREIGN KEY ("MaterialKindId") REFERENCES vzd.nivkis_building_materialkind ("MaterialKindId");

--nivkis_building_element (būves konstruktīvo elementu dati).
DROP TABLE IF EXISTS vzd.nivkis_building_element;

CREATE TABLE vzd.nivkis_building_element (
  id SERIAL PRIMARY KEY
  ,"BuildingCadastreNr" VARCHAR(14) NOT NULL
  ,"MaterialKindName" TEXT[]
  ,"BuildingElementName" SMALLINT
  --,"ConstructionKindName" TEXT[]
  ,"BuildingElementAcceptionYears" SMALLINT[]
  ,"BuildingElementExploitYear" SMALLINT
  ,"BuildingElementDeprecation" SMALLINT
  ,date_created DATE NOT NULL
  ,date_deleted DATE NULL
  );

COMMENT ON TABLE vzd.nivkis_building_element IS 'Nekustamā īpašuma valsts kadastra informācijas sistēmas atvērtie teksta dati par būvju konstruktīvajiem elementiem.';

COMMENT ON COLUMN vzd.nivkis_building_element.id IS 'ID.';

COMMENT ON COLUMN vzd.nivkis_building_element."BuildingCadastreNr" IS 'Būves kadastra apzīmējums.';

COMMENT ON COLUMN vzd.nivkis_building_element."MaterialKindName" IS 'Elementu materiālu nosaukumi.';

COMMENT ON COLUMN vzd.nivkis_building_element."BuildingElementName" IS 'Elementa kods.';

--COMMENT ON COLUMN vzd.nivkis_building_element."ConstructionKindName" IS 'Elementa konstrukcijas veida nosaukums.';

COMMENT ON COLUMN vzd.nivkis_building_element."BuildingElementAcceptionYears" IS 'Elementa ekspluatācijā pieņemšanas gadi.';

COMMENT ON COLUMN vzd.nivkis_building_element."BuildingElementExploitYear" IS 'Elementa ekspluatācijas uzsākšanas gads.';

COMMENT ON COLUMN vzd.nivkis_building_element."BuildingElementDeprecation" IS 'Elementa nolietojums, %.';

COMMENT ON COLUMN vzd.nivkis_building_element.date_created IS 'Izveidošanas datums. Atbilst datu kopā norādītajam datējumam.';

COMMENT ON COLUMN vzd.nivkis_building_element.date_deleted IS 'Dzēšanas datums. Atbilst vecākajā datu kopā, kurā vairs nav objekta ar šādiem atribūtiem, norādītajam datējumam.';

GRANT SELECT, INSERT, UPDATE
  ON TABLE vzd.nivkis_building_element
  TO scheduler;

GRANT SELECT, UPDATE
  ON SEQUENCE vzd.nivkis_building_element_id_seq
  TO scheduler;

--BuildingElementName klasifikators.
DROP TABLE IF EXISTS vzd.nivkis_building_elementname;

CREATE TABLE vzd.nivkis_building_elementname (
  id SERIAL PRIMARY KEY
  ,"BuildingElementName" TEXT NOT NULL
  );

COMMENT ON TABLE vzd.nivkis_building_elementname IS 'Būves konstruktīvo elementu klasifikators Nekustamā īpašuma valsts kadastra informācijas sistēmas atvērtajos teksta datos.';

COMMENT ON COLUMN vzd.nivkis_building_elementname.id IS 'Kods.';

COMMENT ON COLUMN vzd.nivkis_building_elementname."BuildingElementName" IS 'Nosaukums.';

GRANT SELECT, INSERT, UPDATE
  ON TABLE vzd.nivkis_building_elementname
  TO scheduler;

GRANT SELECT, UPDATE
  ON SEQUENCE vzd.nivkis_building_elementname_id_seq
  TO scheduler;

ALTER TABLE vzd.nivkis_building_element ADD CONSTRAINT "nivkis_building_element_fk_BuildingElementName" FOREIGN KEY ("BuildingElementName") REFERENCES vzd.nivkis_building_elementname (id);

--nivkis_building_amount (būves apjoma rādītāju dati).
DROP TABLE IF EXISTS vzd.nivkis_building_amount;

CREATE TABLE vzd.nivkis_building_amount (
  id SERIAL PRIMARY KEY
  ,"BuildingCadastreNr" VARCHAR(14) NOT NULL
  ,"AmountKindName" TEXT NOT NULL
  ,"BuildingAmountTitle" TEXT
  ,"BuildingAmountQuantity" DECIMAL(11, 2) NOT NULL
  ,"MeasureKindName" TEXT NOT NULL
  ,"BuildingKindId" INT
  ,date_created DATE NOT NULL
  ,date_deleted DATE NULL
  );

COMMENT ON TABLE vzd.nivkis_building_amount IS 'Nekustamā īpašuma valsts kadastra informācijas sistēmas atvērtie teksta dati par būvju apjoma rādītājiem.';

COMMENT ON COLUMN vzd.nivkis_building_amount.id IS 'ID.';

COMMENT ON COLUMN vzd.nivkis_building_amount."BuildingCadastreNr" IS 'Būves kadastra apzīmējums.';

COMMENT ON COLUMN vzd.nivkis_building_amount."AmountKindName" IS 'Apjoma rādītāja veida nosaukums.';

COMMENT ON COLUMN vzd.nivkis_building_amount."BuildingAmountTitle" IS 'Apjoma rādītāja nosaukums inženierbūvei.';

COMMENT ON COLUMN vzd.nivkis_building_amount."BuildingAmountQuantity" IS 'Apjoms.';

COMMENT ON COLUMN vzd.nivkis_building_amount."MeasureKindName" IS 'Mērvienības koda nosaukums.';

COMMENT ON COLUMN vzd.nivkis_building_amount."BuildingKindId" IS 'Tipa kods.';

COMMENT ON COLUMN vzd.nivkis_building_amount.date_created IS 'Izveidošanas datums. Atbilst datu kopā norādītajam datējumam.';

COMMENT ON COLUMN vzd.nivkis_building_amount.date_deleted IS 'Dzēšanas datums. Atbilst vecākajā datu kopā, kurā vairs nav objekta ar šādiem atribūtiem, norādītajam datējumam.';

GRANT SELECT, INSERT, UPDATE
  ON TABLE vzd.nivkis_building_amount
  TO scheduler;

GRANT SELECT, UPDATE
  ON SEQUENCE vzd.nivkis_building_amount_id_seq
  TO scheduler;

--nivkis_building_improvement (labiekārtojumu informācija).
DROP TABLE IF EXISTS vzd.nivkis_building_improvement;

CREATE TABLE vzd.nivkis_building_improvement (
  id SERIAL PRIMARY KEY
  ,"BuildingCadastreNr" VARCHAR(14) NOT NULL
  ,"ImprovementDate" DATE
  ,"ImprovementTypeName" TEXT
  ,"ImprovementDetectionForm" TEXT
  ,"ImprovementQuantity" TEXT
  ,date_created DATE NOT NULL
  ,date_deleted DATE NULL
  );

COMMENT ON TABLE vzd.nivkis_building_improvement IS 'Nekustamā īpašuma valsts kadastra informācijas sistēmas atvērtie teksta dati par būvju labiekārtojumiem.';

COMMENT ON COLUMN vzd.nivkis_building_improvement.id IS 'ID.';

COMMENT ON COLUMN vzd.nivkis_building_improvement."BuildingCadastreNr" IS 'Būves kadastra apzīmējums.';

COMMENT ON COLUMN vzd.nivkis_building_improvement."ImprovementDate" IS 'Labiekārtojumu datums.';

COMMENT ON COLUMN vzd.nivkis_building_improvement."ImprovementTypeName" IS 'Labiekārtojuma veids.';

COMMENT ON COLUMN vzd.nivkis_building_improvement."ImprovementDetectionForm" IS 'Labiekārtojuma noteikšanas veids.';

COMMENT ON COLUMN vzd.nivkis_building_improvement."ImprovementQuantity" IS 'Labiekārtojuma apjoms.';

COMMENT ON COLUMN vzd.nivkis_building_improvement.date_created IS 'Izveidošanas datums. Atbilst datu kopā norādītajam datējumam.';

COMMENT ON COLUMN vzd.nivkis_building_improvement.date_deleted IS 'Dzēšanas datums. Atbilst vecākajā datu kopā, kurā vairs nav objekta ar šādiem atribūtiem, norādītajam datējumam.';

GRANT SELECT, INSERT, UPDATE
  ON TABLE vzd.nivkis_building_improvement
  TO scheduler;

GRANT SELECT, UPDATE
  ON SEQUENCE vzd.nivkis_building_improvement_id_seq
  TO scheduler;

--nivkis_premisegroup.
DROP TABLE IF EXISTS vzd.nivkis_premisegroup;

CREATE TABLE vzd.nivkis_premisegroup (
  id SERIAL PRIMARY KEY
  ,"PremiseGroupCadastreNr" VARCHAR(17) NOT NULL
  ,"BuildingCadastreNr" VARCHAR(14) NOT NULL
  ,"PremiseGroupName" TEXT NOT NULL
  ,"PremiseGroupUseKindId" SMALLINT NOT NULL
  ,"PremiseGroupBuildingFloor" SMALLINT NOT NULL
  ,"PremiseGroupPremiseCount" SMALLINT NOT NULL
  ,"PremiseGroupArea" DECIMAL(7, 1)
  ,"PremiseGroupSurveyDate" DATE NOT NULL
  ,"PremiseGroupAcceptionYears" SMALLINT[]
  ,"NotForLandBook" BOOLEAN
  ,date_created DATE NOT NULL
  ,date_deleted DATE
  );

COMMENT ON TABLE vzd.nivkis_premisegroup IS 'Nekustamā īpašuma valsts kadastra informācijas sistēmas atvērtie teksta dati par telpu grupām.';

COMMENT ON COLUMN vzd.nivkis_premisegroup.id IS 'ID.';

COMMENT ON COLUMN vzd.nivkis_premisegroup."PremiseGroupCadastreNr" IS 'Telpu grupas kadastra apzīmējums.';

COMMENT ON COLUMN vzd.nivkis_premisegroup."BuildingCadastreNr" IS 'Būves kadastra apzīmējums.';

COMMENT ON COLUMN vzd.nivkis_premisegroup."PremiseGroupName" IS 'Telpu grupas nosaukums.';

COMMENT ON COLUMN vzd.nivkis_premisegroup."PremiseGroupUseKindId" IS 'Telpu grupas lietošanas veida kods.';

COMMENT ON COLUMN vzd.nivkis_premisegroup."PremiseGroupBuildingFloor" IS 'Piesaistes stāvs.';

COMMENT ON COLUMN vzd.nivkis_premisegroup."PremiseGroupPremiseCount" IS 'Telpu skaits telpu grupā.';

COMMENT ON COLUMN vzd.nivkis_premisegroup."PremiseGroupArea" IS 'Kopējā platība, m².';

COMMENT ON COLUMN vzd.nivkis_premisegroup."PremiseGroupSurveyDate" IS 'Kadastrālās uzmērīšanas datums.';

COMMENT ON COLUMN vzd.nivkis_premisegroup."PremiseGroupAcceptionYears" IS 'Telpu grupas ekspluatācijā pieņemšanas gadi.';

COMMENT ON COLUMN vzd.nivkis_premisegroup."NotForLandBook" IS 'Pazīme, ka dati nav izmantojami ierakstīšanai zemesgrāmatā.';

COMMENT ON COLUMN vzd.nivkis_premisegroup.date_created IS 'Izveidošanas datums. Atbilst datu kopā norādītajam datējumam.';

COMMENT ON COLUMN vzd.nivkis_premisegroup.date_deleted IS 'Dzēšanas datums. Atbilst vecākajā datu kopā, kurā vairs nav objekta ar šādiem atribūtiem, norādītajam datējumam.';

GRANT SELECT, INSERT, UPDATE
  ON TABLE vzd.nivkis_premisegroup
  TO scheduler;

GRANT SELECT, UPDATE
  ON SEQUENCE vzd.nivkis_premisegroup_id_seq
  TO scheduler;

--PremiseGroupUseKind klasifikators.
DROP TABLE IF EXISTS vzd.nivkis_premisegroup_usekind;

CREATE TABLE vzd.nivkis_premisegroup_usekind (
  "PremiseGroupUseKindId" SMALLINT NOT NULL PRIMARY KEY
  ,"PremiseGroupUseKindName" TEXT NOT NULL
  );

COMMENT ON TABLE vzd.nivkis_premisegroup_usekind IS 'Telpu grupas lietošanas veidu klasifikators Nekustamā īpašuma valsts kadastra informācijas sistēmas atvērtajos teksta datos.';

COMMENT ON COLUMN vzd.nivkis_premisegroup_usekind."PremiseGroupUseKindId" IS 'Kods.';

COMMENT ON COLUMN vzd.nivkis_premisegroup_usekind."PremiseGroupUseKindName" IS 'Nosaukums.';

GRANT SELECT, INSERT, UPDATE
  ON TABLE vzd.nivkis_premisegroup_usekind
  TO scheduler;

ALTER TABLE vzd.nivkis_premisegroup ADD CONSTRAINT "nivkis_premisegroup_fk_PremiseGroupUseKindId" FOREIGN KEY ("PremiseGroupUseKindId") REFERENCES vzd.nivkis_premisegroup_usekind ("PremiseGroupUseKindId");

--nivkis_address.
DROP TABLE IF EXISTS vzd.nivkis_address;

CREATE TABLE vzd.nivkis_address (
  id SERIAL PRIMARY KEY
  ,"ObjectCadastreNr" VARCHAR(17) NOT NULL
  ,"ARCode" INT NOT NULL
  ,date_created DATE NOT NULL
  ,date_deleted DATE NULL
  );

COMMENT ON TABLE vzd.nivkis_address IS 'Nekustamā īpašuma valsts kadastra informācijas sistēmas atvērtie teksta dati par kadastra objektiem reģistrētajām adresēm.';

COMMENT ON COLUMN vzd.nivkis_address.id IS 'ID.';

COMMENT ON COLUMN vzd.nivkis_address."ObjectCadastreNr" IS 'Objekta kadastra apzīmējums.';

COMMENT ON COLUMN vzd.nivkis_address."ARCode" IS 'Adresācijas objekta kods.';

COMMENT ON COLUMN vzd.nivkis_address.date_created IS 'Izveidošanas datums. Atbilst datu kopā norādītajam datējumam.';

COMMENT ON COLUMN vzd.nivkis_address.date_deleted IS 'Dzēšanas datums. Atbilst vecākajā datu kopā, kurā vairs nav objekta ar šādiem atribūtiem, norādītajam datējumam.';

GRANT SELECT, INSERT, UPDATE, DELETE
  ON TABLE vzd.nivkis_address
  TO scheduler;

GRANT SELECT, UPDATE
  ON SEQUENCE vzd.nivkis_address_id_seq
  TO scheduler;

--nivkis_encumbrance.
DROP TABLE IF EXISTS vzd.nivkis_encumbrance;

CREATE TABLE vzd.nivkis_encumbrance (
  id SERIAL PRIMARY KEY
  ,"ObjectCadastreNr" VARCHAR(15) NOT NULL
  ,"EncumbranceKindId" BIGINT NOT NULL
  ,"EncumbranceNr" SMALLINT
  ,"EncumbranceEstablishDate" DATE
  ,"EncumbranceArea" DECIMAL(9, 4)
  ,"EncumbranceMeasure" TEXT
  ,date_created DATE NOT NULL
  ,date_deleted DATE
  );

COMMENT ON TABLE vzd.nivkis_encumbrance IS 'Nekustamā īpašuma valsts kadastra informācijas sistēmas atvērtie teksta dati par kadastra objektiem reģistrētajiem apgrūtinājumiem.';

COMMENT ON COLUMN vzd.nivkis_encumbrance.id IS 'ID.';

COMMENT ON COLUMN vzd.nivkis_encumbrance."ObjectCadastreNr" IS 'Objekta kadastra apzīmējums.';

COMMENT ON COLUMN vzd.nivkis_encumbrance."EncumbranceKindId" IS 'Apgrūtinājuma kods.';

COMMENT ON COLUMN vzd.nivkis_encumbrance."EncumbranceNr" IS 'Apgrūtinājuma kārtas Nr. zemes vienībā.';

COMMENT ON COLUMN vzd.nivkis_encumbrance."EncumbranceEstablishDate" IS 'Apgrūtinājuma noteikšanas datums.';

COMMENT ON COLUMN vzd.nivkis_encumbrance."EncumbranceArea" IS 'Apgrūtinājuma piekritīgā platība zemes vienībā vai zemes vienības daļā.';

COMMENT ON COLUMN vzd.nivkis_encumbrance."EncumbranceMeasure" IS 'Apgrūtinājuma piekritīgās platības zemes vienībā vai zemes vienības daļā mērvienība.';

COMMENT ON COLUMN vzd.nivkis_encumbrance.date_created IS 'Izveidošanas datums. Atbilst datu kopā norādītajam datējumam.';

COMMENT ON COLUMN vzd.nivkis_encumbrance.date_deleted IS 'Dzēšanas datums. Atbilst vecākajā datu kopā, kurā vairs nav objekta ar šādiem atribūtiem, norādītajam datējumam.';

GRANT SELECT, INSERT, UPDATE
  ON TABLE vzd.nivkis_encumbrance
  TO scheduler;

GRANT SELECT, UPDATE
  ON SEQUENCE vzd.nivkis_encumbrance_id_seq
  TO scheduler;

--EncumbranceKind klasifikators.
DROP TABLE IF EXISTS vzd.nivkis_encumbrance_usekind;

CREATE TABLE vzd.nivkis_encumbrance_usekind (
  "EncumbranceKindId" BIGINT NOT NULL PRIMARY KEY
  ,"EncumbranceKindName" TEXT NOT NULL
  );

COMMENT ON TABLE vzd.nivkis_encumbrance_usekind IS 'Apgrūtinājumu klasifikators Nekustamā īpašuma valsts kadastra informācijas sistēmas atvērtajos teksta datos.';

COMMENT ON COLUMN vzd.nivkis_encumbrance_usekind."EncumbranceKindId" IS 'Kods.';

COMMENT ON COLUMN vzd.nivkis_encumbrance_usekind."EncumbranceKindName" IS 'Nosaukums.';

GRANT SELECT, INSERT, UPDATE
  ON TABLE vzd.nivkis_encumbrance_usekind
  TO scheduler;

ALTER TABLE vzd.nivkis_encumbrance ADD CONSTRAINT "nivkis_encumbrance_fk_EncumbranceKindId" FOREIGN KEY ("EncumbranceKindId") REFERENCES vzd.nivkis_encumbrance_usekind ("EncumbranceKindId");

--nivkis_mark.
DROP TABLE IF EXISTS vzd.nivkis_mark;

CREATE TABLE vzd.nivkis_mark (
  id SERIAL PRIMARY KEY
  ,"ObjectCadastreNr" VARCHAR(15) NOT NULL
  ,"ObjectType" SMALLINT NOT NULL
  ,"MarkType" TEXT NOT NULL
  ,"MarkDate" DATE
  ,"MarkArea" INT
  ,date_created DATE NOT NULL
  ,date_deleted DATE
  );

COMMENT ON TABLE vzd.nivkis_mark IS 'Nekustamā īpašuma valsts kadastra informācijas sistēmas atvērtie teksta dati par kadastra objektiem reģistrētajām atzīmēm.';

COMMENT ON COLUMN vzd.nivkis_mark.id IS 'ID.';

COMMENT ON COLUMN vzd.nivkis_mark."ObjectCadastreNr" IS 'Objekta kadastra apzīmējums.';

COMMENT ON COLUMN vzd.nivkis_mark."ObjectType" IS 'Kadastra objekta tipa kods.';

COMMENT ON COLUMN vzd.nivkis_mark."MarkType" IS 'Atzīmes tipa kods.';

COMMENT ON COLUMN vzd.nivkis_mark."MarkDate" IS 'Datums, kurā uzlikta atzīme.';

COMMENT ON COLUMN vzd.nivkis_mark."MarkArea" IS 'Atzīmes platība, m².';

COMMENT ON COLUMN vzd.nivkis_mark.date_created IS 'Izveidošanas datums. Atbilst datu kopā norādītajam datējumam.';

COMMENT ON COLUMN vzd.nivkis_mark.date_deleted IS 'Dzēšanas datums. Atbilst vecākajā datu kopā, kurā vairs nav objekta ar šādiem atribūtiem, norādītajam datējumam.';

GRANT SELECT, INSERT, UPDATE
  ON TABLE vzd.nivkis_mark
  TO scheduler;

GRANT SELECT, UPDATE
  ON SEQUENCE vzd.nivkis_mark_id_seq
  TO scheduler;

--ObjectType klasifikators.
DROP TABLE IF EXISTS vzd.nivkis_objecttype;

CREATE TABLE vzd.nivkis_objecttype (
  id SERIAL PRIMARY KEY
  ,"ObjectType" TEXT
  );

COMMENT ON TABLE vzd.nivkis_objecttype IS 'Kadastra objekta tipu klasifikators Nekustamā īpašuma valsts kadastra informācijas sistēmas atvērtajos teksta datos.';

COMMENT ON COLUMN vzd.nivkis_objecttype.id IS 'Kods.';

COMMENT ON COLUMN vzd.nivkis_objecttype."ObjectType" IS 'Nosaukums.';

GRANT SELECT, INSERT, UPDATE
  ON TABLE vzd.nivkis_objecttype
  TO scheduler;

GRANT SELECT, UPDATE
  ON SEQUENCE vzd.nivkis_objecttype_id_seq
  TO scheduler;

ALTER TABLE vzd.nivkis_mark ADD CONSTRAINT "nivkis_mark_fk_ObjectType" FOREIGN KEY ("ObjectType") REFERENCES vzd.nivkis_objecttype (id);

--MarkType klasifikators.
DROP TABLE IF EXISTS vzd.nivkis_mark_marktype;

CREATE TABLE vzd.nivkis_mark_marktype (
  "MarkType" TEXT NOT NULL PRIMARY KEY
  ,"MarkDescription" TEXT NOT NULL
  );

COMMENT ON TABLE vzd.nivkis_mark_marktype IS 'Atzīmes tipu klasifikators Nekustamā īpašuma valsts kadastra informācijas sistēmas atvērtajos teksta datos.';

COMMENT ON COLUMN vzd.nivkis_mark_marktype."MarkType" IS 'Kods.';

COMMENT ON COLUMN vzd.nivkis_mark_marktype."MarkDescription" IS 'Nosaukums.';

GRANT SELECT, INSERT, UPDATE
  ON TABLE vzd.nivkis_mark_marktype
  TO scheduler;

ALTER TABLE vzd.nivkis_mark ADD CONSTRAINT "nivkis_mark_fk_MarkType" FOREIGN KEY ("MarkType") REFERENCES vzd.nivkis_mark_marktype ("MarkType");

--nivkis_valuation_property.
DROP TABLE IF EXISTS vzd.nivkis_valuation_property;

CREATE TABLE vzd.nivkis_valuation_property (
  id SERIAL PRIMARY KEY
  ,"ObjectCadastreNr" VARCHAR(11) NOT NULL
  ,"Valuation" INT
  ,"ValuationDate" DATE
  ,"CadastralValue" INT
  ,"CadastralValueDate" DATE
  ,date_created DATE NOT NULL
  ,date_deleted DATE
  );

COMMENT ON TABLE vzd.nivkis_valuation_property IS 'Nekustamā īpašuma valsts kadastra informācijas sistēmas atvērtie teksta dati par nekustamo īpašumu novērtējumiem un kadastrālajām vērtībām.';

COMMENT ON COLUMN vzd.nivkis_valuation_property.id IS 'ID.';

COMMENT ON COLUMN vzd.nivkis_valuation_property."ObjectCadastreNr" IS 'Objekta kadastra apzīmējums.';

COMMENT ON COLUMN vzd.nivkis_valuation_property."Valuation" IS 'Novērtējums kadastrā, €.';

COMMENT ON COLUMN vzd.nivkis_valuation_property."ValuationDate" IS 'Novērtējuma kadastrā noteikšanas datums.';

COMMENT ON COLUMN vzd.nivkis_valuation_property."CadastralValue" IS 'Kadastrālā vērtība, €.';

COMMENT ON COLUMN vzd.nivkis_valuation_property."CadastralValueDate" IS 'Kadastrālās vērtības noteikšanas datums.';

COMMENT ON COLUMN vzd.nivkis_valuation_property.date_created IS 'Izveidošanas datums. Atbilst datu kopā norādītajam datējumam.';

COMMENT ON COLUMN vzd.nivkis_valuation_property.date_deleted IS 'Dzēšanas datums. Atbilst vecākajā datu kopā, kurā vairs nav objekta ar šādiem atribūtiem, norādītajam datējumam.';

GRANT SELECT, INSERT, UPDATE
  ON TABLE vzd.nivkis_valuation_property
  TO scheduler;

GRANT SELECT, UPDATE
  ON SEQUENCE vzd.nivkis_valuation_property_id_seq
  TO scheduler;

--nivkis_valuation_object.
DROP TABLE IF EXISTS vzd.nivkis_valuation_object;

CREATE TABLE vzd.nivkis_valuation_object (
  id SERIAL PRIMARY KEY
  ,"ObjectCadastreNr" VARCHAR(17) NOT NULL
  ,"CadastralValue" INT
  ,"CadastralValueDate" DATE
  ,"ForestValue" INT
  ,"ForestValueDate" DATE
  ,date_created DATE NOT NULL
  ,date_deleted DATE
  );

COMMENT ON TABLE vzd.nivkis_valuation_object IS 'Nekustamā īpašuma valsts kadastra informācijas sistēmas atvērtie teksta dati par zemes vienību, zemes vienību daļu, būvju un telpu grupu kadastrālajām vērtībām.';

COMMENT ON COLUMN vzd.nivkis_valuation_object.id IS 'ID.';

COMMENT ON COLUMN vzd.nivkis_valuation_object."ObjectCadastreNr" IS 'Objekta kadastra apzīmējums.';

COMMENT ON COLUMN vzd.nivkis_valuation_object."CadastralValue" IS 'Kadastrālā vērtība, €.';

COMMENT ON COLUMN vzd.nivkis_valuation_object."CadastralValueDate" IS 'Kadastrālās vērtības noteikšanas datums.';

COMMENT ON COLUMN vzd.nivkis_valuation_object."ForestValue" IS 'Mežaudzes vērtība, €.';

COMMENT ON COLUMN vzd.nivkis_valuation_object."ForestValueDate" IS 'VMD datu sagatavošanas datums.';

COMMENT ON COLUMN vzd.nivkis_valuation_object.date_created IS 'Izveidošanas datums. Atbilst datu kopā norādītajam datējumam.';

COMMENT ON COLUMN vzd.nivkis_valuation_object.date_deleted IS 'Dzēšanas datums. Atbilst vecākajā datu kopā, kurā vairs nav objekta ar šādiem atribūtiem, norādītajam datējumam.';

GRANT SELECT, INSERT, UPDATE
  ON TABLE vzd.nivkis_valuation_object
  TO scheduler;

GRANT SELECT, UPDATE
  ON SEQUENCE vzd.nivkis_valuation_object_id_seq
  TO scheduler;