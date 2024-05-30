# Skripti atvērto datu par Latviju importēšanai un uzturēšanai PostgreSQL

Repozitorijā apkopoti Centrālajā statistikas pārvaldē veidoti un izmantoti skripti dažādu Latvijas iestāžu publicēto atvērto datu lejupielādei un importēšanai PostgreSQL datubāzē, uzkrājot to vēsturi.

Importēto datu struktūra atšķiras no iestāžu publicētajiem datiem - tā ir vairāk normalizēta, taču ne pilnībā, mēģinot rast balansu starp normalizāciju un lietošanas ērtumu, arīdzan nav iekļautas kolonnas, kas satur datus, ko iespējams atvasināt no citām kolonnām. Atsevišķos gadījumos veidotas arī papildu tabulas un skati ar lietošanai ērtāku datu strutūru.

Skripti veidoti izpildīšanai Linux operētājsistēmās, taču ar nelielām izmaiņām tos iespējams lietot arī citās, tai skaitā Windows.

Bash skripti veidoti, lai ar cron varētu ieplānot to automātisku izpildi. Piemēram, lai izsauktu Adrešu registra datu automātisku atjaunošanu katru darbdienas rītu plkst. 8.20, Crontab pievienojams ieraksts `20 08 * * 1-5 /path/to/aw_csv.sh` (`/path/to/` vietā jānorādā pilns ceļš uz datni). Crontab rediģē ar komandu `crontab -e`. Jāņem vērā, ka skriptiem jābūt izpildāmiem, ko piemēra gadījumā iespējams īstenot ar komandu `chmod +x /path/to/aw_csv.sh`. Izpildes laika pieraksta noteikšanai iespējams izmantot https://crontab.guru/. Lai cron darbi tiktu izpildīti pēc vietējā laika, nevis saskaņotā pasaules laika (UTC): `sudo systemctl edit cron.service`

Pievieno rindu: `TZ=Europe/Riga`

`sudo systemctl restart cron`

Nepieciešamā programmatūra:
* PostgreSQL ar paplašinājumiem PostGIS un [PostgreSQL OGR Foreign Data Wrapper](https://github.com/pramsey/pgsql-ogr-fdw),
* wget,
* [jq](https://stedolan.github.io/jq/).

Sākotnējā iestatīšana:

1. PostgreSQL:
   * [roles.sql](roles.sql) - izveido lomas un lietotājus (`password` vietā jānorāda lietotāja parole). Atkarībā no konfigurācijas tie jāpievieno arī konfigurācijas datnē [pg_hba.conf](https://www.postgresql.org/docs/current/auth-pg-hba-conf.html). Lietotāji editor un basic_user nav obligāti, bet tiek izmantoti turpmākajos skriptos.
   * izveido datubāzi (skriptos lietota `spatial`), tajā izpilda [spatial.sql](spatial.sql), kas pievieno paplašinājumus un nosaka pieejas tiesības.
   * [public.sql](public.sql) - nosaka public shēmas pieejas tiesības.

2. Izveido direktoriju datu failu glabāšanai (`DIRECTORY` norāda saknes direktoriju, kurā tā tiks izveidota, šeit un turpmāk pieņemta lietotāja mājas direktorija; jaunizveidotajai direktorijai jābūt lasāmai no PostgreSQL):

   ```sh
   export DIRECTORY=$HOME
   cd $DIRECTORY
   mkdir data
   ```

## Centrālā statistikas pārvalde (CSP)

Ietvertas tās datu kopas, kas nepieciešamas datu apstrādei no citiem avotiem.

Sākotnējā iestatīšana:

PostgreSQL izveido csp shēmu un nosaka pieejas tiesības, izpildot [csp.sql](csp/csp.sql).

### Administratīvo teritoriju, teritoriālo vienību un statistisko (NUTS 3) reģionu klasifikators

Sākotnējā iestatīšana:

1. Izveido direktoriju lejupielādēto datu glabāšanai (`DIRECTORY` norāda saknes direktoriju, kurā tā tiks izveidota):

   ```sh
   export DIRECTORY=$HOME/data
   cd $DIRECTORY
   mkdir csp
   ```

2. Izpilda bash skriptu [csp.sh](csp/csp.sh) (lejupielādē datus).
3. PostgreSQL izveido ārējo datu avotu, izpildot [ogr_fdw_csv_csp.sql](csp/ogr_fdw_csv_csp.sql) (`/home/user` vietā jānorāda saknes direktorija).

## Valsts zemes dienests (VZD)

Dati publicēti [Latvijas atvērto datu portālā](https://data.gov.lv/dati/lv/dataset?organization=valsts-zemes-dienests).

Sākotnējā iestatīšana:

PostgreSQL izveido vzd shēmu un nosaka pieejas tiesības, izpildot [vzd.sql](vzd/vzd.sql).

### Teritoriālās vienības un ciemi

Sākotnējā iestatīšana:

1. Izveido direktoriju lejupielādēto datu glabāšanai (`DIRECTORY` norāda saknes direktoriju, kurā tā tiks izveidota):

   ```sh
   export DIRECTORY=$HOME/data
   cd $DIRECTORY
   mkdir aw_shp
   ```

2. Izpilda bash skriptu [aw_shp.sh](vzd/aw_shp.sh) bez PostgreSQL procedūrām (lejupielādē datus).
3. PostgreSQL izveido ārējo datu avotu, izpildot [ogr_fdw_aw_shp.sql](vzd/ogr_fdw_aw_shp.sql) (`/home/user` vietā jānorāda saknes direktorija).
4. PostgreSQL izveido tabulu ciemu datu uzkrāšanai, izpildot [vzd_init.sql](vzd/vzd_init.sql).


* [vzd_teritorialas_vienibas.sql](vzd/vzd_teritorialas_vienibas.sql) - procedūra, kas apvieno vienā tabulā visas aktuālās teritoriālās vienības un pievieno atbilstošos administratīvo teritoriju un statistisko reģionu kodus un nosaukumus.
* [vzd_ciemi_proc.sql](vzd/vzd_ciemi_proc.sql) - procedūra kumulatīvai ciemu robežu uzkrāšanai.
* [aw_shp.sh](vzd/aw_shp.sh) - bash skripts, kas lejupielādē administratīvo teritoriju, teritoriālo vienību un ciemu robežas un izsauc procedūras [vzd.teritorialas_vienibas()](vzd/vzd_teritorialas_vienibas.sql) un [vzd.ciemi_proc()](vzd/vzd_ciemi_proc.sql) (aiz `PGPASSWORD` jānorāda lietotāja scheduler parole).

### Valsts adrešu reģistra informācijas sistēma (VARIS)

Sākotnējā iestatīšana:

1. PostgreSQL izveido shēmu un tabulas, kurās importēt datus, izpildot [aw_csv.sql](vzd/aw_csv.sql) ([PostgreSQL OGR Foreign Data Wrapper](https://github.com/pramsey/pgsql-ogr-fdw) netiek izmantots, jo nesaglabā dubultpēdiņas teksta laukos).
2. Izveido direktoriju lejupielādēto dzēsto ēku adrešu koordinātu glabāšanai (`DIRECTORY` norāda saknes direktoriju, kurā tā tiks izveidota):

   ```sh
   export DIRECTORY=$HOME/data
   cd $DIRECTORY
   mkdir aw_del
   ```

3. Izpilda bash skriptu [aw_del.sh](vzd/aw_del.sh), kas lejupielādē dzēsto ēku adrešu koordinātas (`/home/user` vietā jānorāda saknes direktorija).
4. PostgreSQL izveido ārējo datu avotu, izpildot [ogr_fdw_aw_del.sql](vzd/ogr_fdw_aw_del.sql) (`/home/user` vietā jānorāda saknes direktorija).
5. PostgreSQL izveido tabulas datu uzkrāšanai, izpildot [adreses_init.sql](vzd/adreses_init.sql).

* [adreses.sql](vzd/adreses.sql) - procedūra datu atjaunošanai.
* [adreses_his_ekas_split.sql](vzd/adreses_his_ekas_split.sql) - procedūra, kas sadala pa laukiem adrešu vēsturiskos pierakstus.
* [aw_csv.sh](vzd/aw_csv.sh) - bash skripts, kas lejupielādē VARIS datus, importē tabulas shēmā aw_csv un izsauc procedūras [vzd.adreses()](vzd/adreses.sql) un [vzd.adreses_his_ekas_split()](vzd/adreses_his_ekas_split.sql) (aiz `PGPASSWORD` jānorāda lietotāja scheduler parole).

### Pasta indeksu teritorijas

[postal_codes.sql](vzd/postal_codes.sql) - aprēķina pasta indeksu teritorijas, izmantojot Voronoja diagrammas (`yyyymmdd` jānorāda teritoriālo vienību robežu datums, `dd.mm.yyyy.` - VARIS datu datums).

### Nekustamā īpašuma valsts kadastra informācijas sistēma (NĪVKIS)

Sākotnējā iestatīšana:

1. Izpilda bash skriptus [kk_shp.sh](vzd/kk_shp.sh) un [pre_reg_buildings.sh](vzd/pre_reg_buildings.sh) bez PostgreSQL procedūrām (lejupielādē datus).
2. PostgreSQL izveido ārējo datu avotus, izpildot [ogr_fdw_kk_shp.sql](vzd/ogr_fdw_kk_shp.sql) un [ogr_fdw_pre_reg_buildings.sql](vzd/ogr_fdw_pre_reg_buildings.sql) (`/home/user` vietā jānorāda saknes direktorija).
3. PostgreSQL izveido tabulas kadastra telpisko datu uzkrāšanai, izpildot [nivkis_init.sql](vzd/nivkis_init.sql).
4. Izveido direktoriju lejupielādēto teksta datu glabāšanai (`DIRECTORY` norāda saknes direktoriju, kurā tā tiks izveidota):

   ```sh
   export DIRECTORY=$HOME/data
   cd $DIRECTORY
   mkdir nivkis_txt
   ```

5. PostgreSQL izveido tabulas kadastra teksta datu uzkrāšanai, izpildot [nivkis_txt_init.sql](vzd/nivkis_txt_init.sql).

* [nivkis_proc.sql](vzd/nivkis_proc.sql) - procedūra kumulatīvai ēku un inženierbūvju, zemes vienību un zemes vienību daļu robežu, kā arī apgrūtinājumu ceļa servitūtu teritoriju uzkrāšanai.
* [kk_shp.sh](vzd/kk_shp.sh) - bash skripts, kas lejupielādē telpiskos datus, apvieno _shapefile_ (tikai ēkas, inženierbūves, zemes vienības, zemes vienību daļas un apgrūtinājumu ceļa servitūtu teritorijas) un izsauc procedūru [vzd.nivkis()](vzd/nivkis_proc.sql) (aiz `PGPASSWORD` jānorāda lietotāja scheduler parole).
* [nivkis_property_proc.sql](vzd/nivkis_property_proc.sql) - procedūra kumulatīvai datu uzkrāšanai par nekustamajiem īpašumiem.
* [nivkis_ownership_proc.sql](vzd/nivkis_ownership_proc.sql) - procedūra kumulatīvai datu uzkrāšanai par personu īpašumtiesībām.
* [nivkis_parcel_proc.sql](vzd/nivkis_parcel_proc.sql) - procedūra kumulatīvai datu uzkrāšanai par zemes vienības raksturojošajiem datiem.
* [nivkis_parcelpart_proc.sql](vzd/nivkis_parcelpart_proc.sql) - procedūra kumulatīvai datu uzkrāšanai par zemes vienību daļas raksturojošajiem datiem.
* [nivkis_building_proc.sql](vzd/nivkis_building_proc.sql) - procedūra kumulatīvai datu uzkrāšanai par būves raksturojošajiem datiem.
* [nivkis_premisegroup_proc.sql](vzd/nivkis_premisegroup_proc.sql) - procedūra kumulatīvai datu uzkrāšanai par telpu grupas raksturojošajiem datiem.
* [nivkis_address_proc.sql](vzd/nivkis_address_proc.sql) - procedūra kumulatīvai datu uzkrāšanai par kadastra objektiem reģistrētajām adresēm.
* [nivkis_encumbrance_proc.sql](vzd/nivkis_encumbrance_proc.sql) - procedūra kumulatīvai datu uzkrāšanai par kadastra objektiem reģistrētajiem apgrūtinājumiem.
* [nivkis_mark_proc.sql](vzd/nivkis_mark_proc.sql) - procedūra kumulatīvai datu uzkrāšanai par kadastra objektiem reģistrētajām atzīmēm.
* [nivkis_valuation_proc.sql](vzd/nivkis_valuation_proc.sql) - procedūra kumulatīvai datu uzkrāšanai par kadastra objektu novērtējumiem un kadastrālajām vērtībām.
* [nivkis_ekas_rekviziti.sql](vzd/nivkis_ekas_rekviziti.sql) - materializētais skats ar aktuālajām ēku ģeometrijām un daļu teksta datu, t.sk. adresēm.
* [nivkis_txt.sh](vzd/nivkis_txt.sh) - bash skripts, kas lejupielādē teksta datus, importē pagaidu PostgreSQL tabulās un izsauc procedūras (aiz `PGPASSWORD` jānorāda lietotāja scheduler parole).
* [nivkis_building_pre_reg_proc.sql](vzd/nivkis_building_pre_reg_proc.sql) - procedūra pirmsreģistrēto būvju datu atjaunošanai.
* [pre_reg_buildings.sh](vzd/pre_reg_buildings.sh) - bash skripts, kas lejupielādē datus par pirmsreģistrētajām būvēm un izsauc procedūru [vzd.nivkis_building_pre_reg_proc()](vzd/nivkis_building_pre_reg_proc.sql) (aiz `PGPASSWORD` jānorāda lietotāja scheduler parole).

### Nekustamā īpašuma tirgus informācijas sistēma (NĪTIS)

Sākotnējā iestatīšana:

1. Izveido direktoriju lejupielādēto datu glabāšanai (`DIRECTORY` norāda saknes direktoriju, kurā tā tiks izveidota):

   ```sh
   export DIRECTORY=$HOME/data
   cd $DIRECTORY
   mkdir nitis
   ```

2. Izpilda bash skriptu [nitis.sh](vzd/nitis.sh) bez PostgreSQL procedūrām (lejupielādē datus; ja nav instalēts, pirms tam instalē dos2unix).
3. PostgreSQL izveido ārējo datu avotu, izpildot [ogr_fdw_csv_nitis.sql](vzd/ogr_fdw_csv_nitis.sql) (`/home/user` vietā jānorāda saknes direktorija).
4. PostgreSQL izveido tabulas datu uzkrāšanai, izpildot [nitis_init.sql](vzd/nitis_init.sql).

* [nitis.sql](vzd/nitis.sql) - procedūra datu atjaunošanai.
* [nitis_geom.sql](vzd/nitis_geom.sql) - procedūra, kas pievieno trūkstošo ģeometriju no NĪVKIS datiem.
* [nitis.sh](vzd/nitis.sh) - bash skripts, kas lejupielādē datus un izsauc procedūras [vzd.nitis()](vzd/nitis.sql) un [vzd.nitis_geom()](vzd/nitis_geom.sql) (aiz `PGPASSWORD` jānorāda lietotāja scheduler parole).

## Lauku atbalsta dienests (LAD)

Sākotnējā iestatīšana:

PostgreSQL izveido lad shēmu un nosaka pieejas tiesības, izpildot [lad.sql](lad/lad.sql).

### Lauku reģistrs

Dati publicēti [WFS pakalpju veidā](https://www.lad.gov.lv/lv/lauku-registra-dati).

Sākotnējā iestatīšana:

1. PostgreSQL izveido ārējos datu avotus, izpildot [ogr_fdw_wfs_lad.sql](lad/ogr_fdw_wfs_lad.sql).
2. PostgreSQL izveido tabulas datu uzkrāšanai, izpildot [lad_init.sql](lad/lad_init.sql).

* [lad_field_blocks.sql](lad/lad_field_blocks.sql) - procedūra kumulatīvai lauku bloku datu uzkrāšanai.
* [lad_fields.sql](lad/lad_fields.sql) - procedūra kumulatīvai lauku datu uzkrāšanai.
* [lad.sh](lad.sh) - bash skripts, kas izsauc procedūras [lad.field_blocks_proc()](lad/lad_field_blocks.sql) un [lad.fields_proc()](lad/lad_fields.sql) (aiz `PGPASSWORD` jānorāda lietotāja scheduler parole).

## Valsts meža dienests (VMD)

Sākotnējā iestatīšana:

PostgreSQL izveido mvr shēmu un nosaka pieejas tiesības, izpildot [mvr.sql](mvr/mvr.sql).

### Meža valsts reģistrs

Dati publicēti [Latvijas atvērto datu portālā](https://data.gov.lv/dati/lv/dataset/meza-valsts-registra-meza-dati).

[Kodu klasifikatori](https://www.vmd.gov.lv/lv/meza-valsts-registra-meza-inventarizacijas-failu-struktura) aktuālajiem kodiem.

Sākotnējā iestatīšana:

1. Izpilda bash skriptu [mvr.sh](mvr/mvr.sh) bez PostgreSQL procedūras (lejupielādē datus; ja nav instalēts, pirms tam instalē 7za).
2. PostgreSQL izveido ārējo datu avotu, izpildot [ogr_fdw_mvr.sql](mvr/ogr_fdw_mvr.sql) (`/home/user` vietā jānorāda saknes direktorija).
3. PostgreSQL izveido tabulas datu uzkrāšanai, izpildot [mvr_init.sql](mvr/mvr_init.sql).

* [mvr_proc.sql](mvr/mvr_proc.sql) - procedūra kumulatīvai datu uzkrāšanai.
* [mvr.sh](mvr.sh) - bash skripts, kas izsauc procedūru [mvr.mvr_proc()](mvr/mvr_proc.sql) (aiz `PGPASSWORD` jānorāda lietotāja scheduler parole). Pēc datu atjaunošanas tabulā mvr.mvr_imported jāizlabo vērtības kolonnās date_created un date_deleted uz Latvijas atvērto datu portālā norādītajām:

  ```sql
  UPDATE mvr.mvr_imported
  SET date_created = 'yyyy-mm-dd' --Latvijas atvērto datu portālā norādītais datums.
  WHERE date_created = 'yyyy-mm-dd'; --Datu atjaunošanas skripta izpildes datums.

  UPDATE mvr.mvr_imported
  SET date_deleted = 'yyyy-mm-dd' --Latvijas atvērto datu portālā norādītais datums.
  WHERE date_deleted = 'yyyy-mm-dd'; --Datu atjaunošanas skripta izpildes datums.
  ```
