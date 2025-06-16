CREATE OR REPLACE PROCEDURE vzd.adreses_his_ekas_split(
	)
LANGUAGE 'plpgsql'

AS $BODY$BEGIN

--Pagaidu tabula ar labotiem sākuma datumiem, lai tie atbilstu adreses pieraksta, nevis adresācijas objekta izveides sākuma datumam.
CREATE TEMPORARY TABLE adreses_his_dat_sak AS
SELECT id
  ,adr_cd
  ,adr_cd_his
  ,tips_cd
  ,std
  ,COALESCE(LAG(dat_beig) OVER (
      PARTITION BY adr_cd ORDER BY dat_beig
        ,dat_mod
      ) + 1, dat_sak) dat_sak
  ,dat_mod
  ,dat_beig
FROM vzd.adreses_his;

--Labo ierakstus, kuriem pasta indekss norādīts bez prefiksa "LV-".
UPDATE adreses_his_dat_sak
SET std = LEFT(std, LENGTH(std) - 4) || 'LV-' || RIGHT(std, 4)
WHERE std NOT LIKE '%, LV-%'
  AND RIGHT(std, 4) ~ '^[0-9]*$';

--Pagaidu tabula ar hierarhiski augstākajiem adresācijas objektiem.
CREATE TEMPORARY TABLE adreses_his_upper AS
SELECT tips_cd
  ,std
  ,NULL::DATE dat_sak
  ,NULL::DATE dat_beig
FROM vzd.adreses_his
WHERE tips_cd NOT IN (
    109
    ,108
    ,107
    )

UNION

SELECT tips_cd
  ,std
  ,NULL::DATE dat_sak
  ,NULL::DATE dat_beig
FROM vzd.adreses
WHERE tips_cd NOT IN (
    109
    ,108
    ,107
    )
  AND (
    statuss NOT LIKE 'ERR'
    OR tips_cd = 106
    );

--Ciemiem un pilsētām ar vienādu pierakstu pievieno sākuma un beigu datumu. Visiem ierakstiem datumus neizmanto, jo tie var nesakrist ar hierarhiski zemākajiem adresācijas objektiem. Kļūdainu hierarhiski zemāko adresācijas objektu sākuma datumu dēļ vecākā ieraksta sākuma datumu pieņem tik senu, lai tas iekļautu visus ierakstus.
UPDATE adreses_his_upper
SET dat_sak = '1918-11-18'
  ,dat_beig = '2021-06-30'
WHERE std LIKE 'Mārupe, Mārupes nov.'
  AND tips_cd = 106;

UPDATE adreses_his_upper
SET dat_sak = '2022-07-01'
WHERE std LIKE 'Mārupe, Mārupes nov.'
  AND tips_cd = 104;

UPDATE adreses_his_upper
SET dat_sak = '1918-11-18'
  ,dat_beig = '2021-06-30'
WHERE std LIKE 'Ādaži, Ādažu nov.'
  AND tips_cd = 106;

UPDATE adreses_his_upper
SET dat_sak = '2022-07-01'
WHERE std LIKE 'Ādaži, Ādažu nov.'
  AND tips_cd = 104;

--Pievieno trūkstošos ierakstus.
INSERT INTO adreses_his_upper (
  tips_cd
  ,std
  )
VALUES (
  105
  ,'Aizkraukles pag., Aizkraukles raj.'
  )
  ,(
  105
  ,'Amatas pag., Cēsu raj.'
  )
  ,(
  105
  ,'Ciblas pag., Ludzas raj.'
  )
  ,(
  105
  ,'Kandavas pag., Tukuma raj.'
  )
  ,(
  105
  ,'Krāslavas pag., Krāslavas raj.'
  )
  ,(
  105
  ,'Preiļu pag., Preiļu raj.'
  )
  ,(
  105
  ,'Tērvetes pag., Dobeles raj.'
  )
  ,(
  106
  ,'Aizkraukle, Aizkraukles pag., Aizkraukles raj.'
  )
  ,(
  106
  ,'Aizkraukles muiža, Aizkraukles pag., Aizkraukles raj.'
  )
  ,(
  106
  ,'Aizpuri, Aizkraukles pag., Aizkraukles raj.'
  )
  ,(
  106
  ,'Anspoki, Preiļu pag., Preiļu raj.'
  )
  ,(
  106
  ,'Babri, Preiļu pag., Preiļu raj.'
  )
  ,(
  106
  ,'Balalaiki, Ciblas pag., Ludzas raj.'
  )
  ,(
  106
  ,'Barisi, Ciblas pag., Ludzas raj.'
  )
  ,(
  106
  ,'Beči, Preiļu pag., Preiļu raj.'
  )
  ,(
  106
  ,'Briškas, Preiļu pag., Preiļu raj.'
  )
  ,(
  106
  ,'Buki, Preiļu pag., Preiļu raj.'
  )
  ,(
  106
  ,'Cibla, Ciblas pag., Ludzas raj.'
  )
  ,(
  106
  ,'Cimoškas, Krāslavas pag., Krāslavas raj.'
  )
  ,(
  106
  ,'Ciši, Preiļu pag., Preiļu raj.'
  )
  ,(
  106
  ,'Dambīši, Preiļu pag., Preiļu raj.'
  )
  ,(
  106
  ,'Dzeņkalns, Preiļu pag., Preiļu raj.'
  )
  ,(
  106
  ,'Dzervaniški, Preiļu pag., Preiļu raj.'
  )
  ,(
  106
  ,'Eversmuiža, Ciblas pag., Ludzas raj.'
  )
  ,(
  106
  ,'Ezerkalns, Krāslavas pag., Krāslavas raj.'
  )
  ,(
  106
  ,'Felicianova, Ciblas pag., Ludzas raj.'
  )
  ,(
  106
  ,'Gavarčiki, Preiļu pag., Preiļu raj.'
  )
  ,(
  106
  ,'Greči, Ciblas pag., Ludzas raj.'
  )
  ,(
  106
  ,'Gribuški, Preiļu pag., Preiļu raj.'
  )
  ,(
  106
  ,'Ģikši, Amatas pag., Cēsu raj.'
  )
  ,(
  106
  ,'Ivdrīši, Preiļu pag., Preiļu raj.'
  )
  ,(
  106
  ,'Jaunsaimnieki, Preiļu pag., Preiļu raj.'
  )
  ,(
  106
  ,'Jermaki, Preiļu pag., Preiļu raj.'
  )
  ,(
  106
  ,'Jurāni, Ciblas pag., Ludzas raj.'
  )
  ,(
  106
  ,'Kondrati, Ciblas pag., Ludzas raj.'
  )
  ,(
  106
  ,'Korsikova, Preiļu pag., Preiļu raj.'
  )
  ,(
  106
  ,'Kozlovski, Ciblas pag., Ludzas raj.'
  )
  ,(
  106
  ,'Krapiški, Preiļu pag., Preiļu raj.'
  )
  ,(
  106
  ,'Krejāni, Preiļu pag., Preiļu raj.'
  )
  ,(
  106
  ,'Kroņauce, Tērvetes pag., Dobeles raj.'
  )
  ,(
  106
  ,'Kumbuļi'
  )
  ,(
  106
  ,'Lielie Leiči, Preiļu pag., Preiļu raj.'
  )
  ,(
  106
  ,'Lielie Mūrnieki, Preiļu pag., Preiļu raj.'
  )
  ,(
  106
  ,'Lielie Pupāji, Preiļu pag., Preiļu raj.'
  )
  ,(
  106
  ,'Lielie Trukšāni, Ciblas pag., Ludzas raj.'
  )
  ,(
  106
  ,'Lielie Urči, Preiļu pag., Preiļu raj.'
  )
  ,(
  106
  ,'Liepas, Kandavas pag., Tukuma raj.'
  )
  ,(
  106
  ,'Litavnieki, Preiļu pag., Preiļu raj.'
  )
  ,(
  106
  ,'Līči, Preiļu pag., Preiļu raj.'
  )
  ,(
  106
  ,'Maļinovka, Preiļu pag., Preiļu raj.'
  )
  ,(
  106
  ,'Mazie Gavari, Preiļu pag., Preiļu raj.'
  )
  ,(
  106
  ,'Mazie Leiči, Preiļu pag., Preiļu raj.'
  )
  ,(
  106
  ,'Mazie Mūrnieki, Preiļu pag., Preiļu raj.'
  )
  ,(
  106
  ,'Mazie Pupāji, Preiļu pag., Preiļu raj.'
  )
  ,(
  106
  ,'Meža Kocki, Ciblas pag., Ludzas raj.'
  )
  ,(
  106
  ,'Mjaiši, Ciblas pag., Ludzas raj.'
  )
  ,(
  106
  ,'Morozovka, Ciblas pag., Ludzas raj.'
  )
  ,(
  106
  ,'Moskvina, Preiļu pag., Preiļu raj.'
  )
  ,(
  106
  ,'Nīcgale'
  )
  ,(
  106
  ,'Noviki, Preiļu pag., Preiļu raj.'
  )
  ,(
  106
  ,'Otrie Bluzmi, Preiļu pag., Preiļu raj.'
  )
  ,(
  106
  ,'Ozupiene, Ciblas pag., Ludzas raj.'
  )
  ,(
  106
  ,'Papardes, Aizkraukles pag., Aizkraukles raj.'
  )
  ,(
  106
  ,'Pastari, Krāslavas pag., Krāslavas raj.'
  )
  ,(
  106
  ,'Pelši, Preiļu pag., Preiļu raj.'
  )
  ,(
  106
  ,'Pirmie Bluzmi, Preiļu pag., Preiļu raj.'
  )
  ,(
  106
  ,'Placinski, Preiļu pag., Preiļu raj.'
  )
  ,(
  106
  ,'Plivdas, Preiļu pag., Preiļu raj.'
  )
  ,(
  106
  ,'Polockieši, Preiļu pag., Preiļu raj.'
  )
  ,(
  106
  ,'Rubeņi, Preiļu pag., Preiļu raj.'
  )
  ,(
  106
  ,'Rumpīši, Preiļu pag., Preiļu raj.'
  )
  ,(
  106
  ,'Runči, Preiļu pag., Preiļu raj.'
  )
  ,(
  106
  ,'Rūmene, Kandavas pag., Tukuma raj.'
  )
  ,(
  106
  ,'Sanauža, Preiļu pag., Preiļu raj.'
  )
  ,(
  106
  ,'Seiļi, Preiļu pag., Preiļu raj.'
  )
  ,(
  106
  ,'Skrini, Ciblas pag., Ludzas raj.'
  )
  ,(
  106
  ,'Sondori, Preiļu pag., Preiļu raj.'
  )
  ,(
  106
  ,'Stocinova, Ciblas pag., Ludzas raj.'
  )
  ,(
  106
  ,'Šoldri, Preiļu pag., Preiļu raj.'
  )
  ,(
  106
  ,'Tērvete, Tērvetes pag., Dobeles raj.'
  )
  ,(
  106
  ,'Tridņa, Ciblas pag., Ludzas raj.'
  )
  ,(
  106
  ,'Tumova, Ciblas pag., Ludzas raj.'
  )
  ,(
  106
  ,'Upenieki, Preiļu pag., Preiļu raj.'
  )
  ,(
  106
  ,'Vacumnieki, Ciblas pag., Ludzas raj.'
  )
  ,(
  106
  ,'Vaivodi, Preiļu pag., Preiļu raj.'
  )
  ,(
  106
  ,'Vilcāni, Preiļu pag., Preiļu raj.'
  )
  ,(
  106
  ,'Višķi'
  )
  ,(
  106
  ,'Voloji, Ciblas pag., Ludzas raj.'
  )
  ,(
  106
  ,'Zeltiņi, Ciblas pag., Ludzas raj.'
  );

--Izņēmuma gadījums ar komatu mājas nosaukumā.
INSERT INTO vzd.adreses_his_ekas_split (
  id
  ,nosaukums
  ,ciems
  ,novads
  ,rajons
  )
SELECT a.id
  ,LEFT(a.std, STRPOS(a.std, ', Baltezers') - 1)
  ,'Baltezers'
  ,'Garkalnes nov.'
  ,'Rīgas raj.'
FROM adreses_his_dat_sak a
LEFT JOIN vzd.adreses_his_ekas_split x ON a.id = x.id
WHERE a.std LIKE '"%,%", Baltezers, Garkalnes nov., Rīgas raj.%'
  AND a.tips_cd = 108
  AND x.id IS NULL;

--Māju nosaukumi (pēdiņās).
WITH x
AS (
  SELECT DISTINCT a.id
    ,LEFT(a.std, STRPOS(a.std, '", ')) nosaukums
    ,NULL iela
    ,CASE 
      WHEN b.tips_cd = 106
        THEN REPLACE(LEFT(b.std, COALESCE(NULLIF(STRPOS(b.std, ','), 0), LENGTH(b.std))), ',', '')
      ELSE NULL
      END ciems
    ,CASE 
      WHEN b.tips_cd = 104
        THEN REPLACE(LEFT(b.std, COALESCE(NULLIF(STRPOS(b.std, ','), 0), LENGTH(b.std))), ',', '')
      WHEN c.tips_cd = 104
        THEN REPLACE(LEFT(c.std, COALESCE(NULLIF(STRPOS(c.std, ','), 0), LENGTH(c.std))), ',', '')
      WHEN f.nosaukums IS NOT NULL
        THEN f.nosaukums
      ELSE NULL
      END pilseta
    ,CASE 
      WHEN b.tips_cd = 105
        THEN REPLACE(LEFT(b.std, COALESCE(NULLIF(STRPOS(b.std, ','), 0), LENGTH(b.std))), ',', '')
      WHEN c.tips_cd = 105
        THEN REPLACE(LEFT(c.std, COALESCE(NULLIF(STRPOS(c.std, ','), 0), LENGTH(c.std))), ',', '')
      ELSE NULL
      END pagasts
    ,CASE 
      WHEN b.tips_cd = 113
        THEN REPLACE(LEFT(b.std, COALESCE(NULLIF(STRPOS(b.std, ','), 0), LENGTH(b.std))), ',', '')
      WHEN c.tips_cd = 113
        THEN REPLACE(LEFT(c.std, COALESCE(NULLIF(STRPOS(c.std, ','), 0), LENGTH(c.std))), ',', '')
      WHEN d.tips_cd = 113
        THEN REPLACE(LEFT(d.std, COALESCE(NULLIF(STRPOS(d.std, ','), 0), LENGTH(d.std))), ',', '')
      ELSE NULL
      END novads
    ,CASE 
      WHEN c.tips_cd = 102
        THEN REPLACE(LEFT(c.std, COALESCE(NULLIF(STRPOS(c.std, ','), 0), LENGTH(c.std))), ',', '')
      WHEN d.tips_cd = 102
        THEN REPLACE(LEFT(d.std, COALESCE(NULLIF(STRPOS(d.std, ','), 0), LENGTH(d.std))), ',', '')
      WHEN e.tips_cd = 102
        THEN REPLACE(LEFT(e.std, COALESCE(NULLIF(STRPOS(e.std, ','), 0), LENGTH(e.std))), ',', '')
      ELSE NULL
      END rajons
  FROM adreses_his_dat_sak a
  LEFT JOIN adreses_his_upper b ON RIGHT(LEFT(a.std, COALESCE(NULLIF(STRPOS(a.std, 'LV-') - 3, - 3), LENGTH(a.std))), LENGTH(LEFT(a.std, COALESCE(NULLIF(STRPOS(a.std, 'LV-') - 3, - 3), LENGTH(a.std)))) - STRPOS(a.std, '", ') - 2) = b.std
    AND (
      a.dat_sak >= b.dat_sak
      OR b.dat_sak IS NULL
      )
    AND (
      a.dat_beig <= b.dat_beig
      OR b.dat_beig IS NULL
      ) --Piesaistot hierarhiski augstāku objektu, neņem vērā pasta indeksu.
  LEFT JOIN adreses_his_upper c ON RIGHT(b.std, LENGTH(b.std) - STRPOS(b.std, ',') - 1) = c.std
  LEFT JOIN adreses_his_upper d ON RIGHT(c.std, LENGTH(c.std) - STRPOS(c.std, ',') - 1) = d.std
  LEFT JOIN adreses_his_upper e ON RIGHT(d.std, LENGTH(d.std) - STRPOS(d.std, ',') - 1) = e.std
  LEFT JOIN (
    SELECT DISTINCT nosaukums
    FROM vzd.adreses
    WHERE tips_cd = 104
    ) f ON RIGHT(LEFT(a.std, COALESCE(NULLIF(STRPOS(a.std, 'LV-') - 3, - 3), LENGTH(a.std))), LENGTH(LEFT(a.std, COALESCE(NULLIF(STRPOS(a.std, 'LV-') - 3, - 3), LENGTH(a.std)))) - STRPOS(a.std, ',') - 1) = f.nosaukums --Tikai pilsētu nosaukumi gadījumiem, kad to nav laukā std (ir tikai kopā ar hierarhiski augstākiem objektiem).
  LEFT JOIN vzd.adreses_his_ekas_split x ON a.id = x.id
  WHERE a.tips_cd = 108
    AND a.std LIKE '"%", %'
    AND x.id IS NULL
  )
  ,x2
AS (
  SELECT id
  FROM x
  GROUP BY id
  HAVING COUNT(*) = 1
  )
INSERT INTO vzd.adreses_his_ekas_split
SELECT x.*
FROM x
INNER JOIN x2 ON x.id = x2.id;

--Izņēmuma gadījumi ar ielām un nestandarta kļūdainu adreses pierakstu.
INSERT INTO vzd.adreses_his_ekas_split (
  id
  ,nosaukums
  ,iela
  ,ciems
  ,pagasts
  ,rajons
  )
SELECT a.id
  ,LEFT(a.std, STRPOS(a.std, ', ') - 1)
  ,'Ziemeļu iela'
  ,'Vārzas'
  ,'Skultes pag.'
  ,'Limbažu raj.'
FROM vzd.adreses_his a
LEFT JOIN vzd.adreses_his_ekas_split x ON a.id = x.id
WHERE std LIKE '%, Ziemeļu iela, Vārzas, Skultes pag., Limbažu raj.%'
  AND x.id IS NULL
  AND a.tips_cd = 108;

INSERT INTO vzd.adreses_his_ekas_split (
  id
  ,nosaukums
  ,iela
  ,pilseta
  ,rajons
  )
SELECT a.id
  ,SUBSTRING(a.std, LENGTH(LEFT(a.std, STRPOS(a.std, ' iela') + 4)) + 2, STRPOS(a.std, ', Kuldīga') - LENGTH(LEFT(a.std, STRPOS(a.std, ' iela') + 4)) - 2)
  ,LEFT(a.std, STRPOS(a.std, ' iela') + 4)
  ,'Kuldīga'
  ,'Kuldīgas raj.'
FROM adreses_his_dat_sak a
LEFT JOIN vzd.adreses_his_ekas_split x ON a.id = x.id
WHERE std LIKE '%iela%,%, Kuldīga, Kuldīgas raj.%'
  AND x.id IS NULL
  AND a.tips_cd = 108;

INSERT INTO vzd.adreses_his_ekas_split (
  id
  ,nosaukums
  ,iela
  ,pilseta
  )
SELECT a.id
  ,SUBSTRING(a.std, LENGTH('Klusā iela ') + 1, STRPOS(a.std, ', Daugavpils') - LENGTH('Klusā iela ') - 1)
  ,'Klusā iela'
  ,'Daugavpils'
FROM adreses_his_dat_sak a
LEFT JOIN vzd.adreses_his_ekas_split x ON a.id = x.id
WHERE std LIKE 'Klusā iela%,%, Daugavpils%'
  AND x.id IS NULL
  AND a.tips_cd = 108;

INSERT INTO vzd.adreses_his_ekas_split (
  id
  ,nosaukums
  ,iela
  ,ciems
  ,pagasts
  ,novads
  )
SELECT a.id
  ,SUBSTRING(a.std, LENGTH(LEFT(a.std, STRPOS(a.std, ' iela') + 4)) + 2, STRPOS(a.std, ', Saulstari') - LENGTH(LEFT(a.std, STRPOS(a.std, ' iela') + 4)) - 2)
  ,LEFT(a.std, STRPOS(a.std, ' iela') + 4)
  ,'Saulstari, Ķekava'
  ,'Ķekavas pag.'
  ,'Ķekavas nov.'
FROM adreses_his_dat_sak a
LEFT JOIN vzd.adreses_his_ekas_split x ON a.id = x.id
WHERE std LIKE '%iela%, Saulstari, Ķekava, Ķekavas pag., Ķekavas nov.%'
  AND x.id IS NULL
  AND a.tips_cd = 108;

INSERT INTO vzd.adreses_his_ekas_split (
  id
  ,nosaukums
  ,iela
  ,ciems
  ,pagasts
  ,novads
  )
SELECT a.id
  ,SUBSTRING(a.std, LENGTH(LEFT(a.std, STRPOS(a.std, ' iela') + 4)) + 2, STRPOS(a.std, ', Zilgmes') - LENGTH(LEFT(a.std, STRPOS(a.std, ' iela') + 4)) - 2)
  ,LEFT(a.std, STRPOS(a.std, ' iela') + 4)
  ,'Zilgmes, Ķekava'
  ,'Ķekavas pag.'
  ,'Ķekavas nov.'
FROM adreses_his_dat_sak a
LEFT JOIN vzd.adreses_his_ekas_split x ON a.id = x.id
WHERE std LIKE '%iela%, Zilgmes, Ķekava, Ķekavas pag., Ķekavas nov.%'
  AND x.id IS NULL
  AND a.tips_cd = 108;

INSERT INTO vzd.adreses_his_ekas_split (
  id
  ,nosaukums
  ,iela
  ,ciems
  ,pagasts
  ,rajons
  )
SELECT a.id
  ,SUBSTRING(a.std, LENGTH(LEFT(a.std, STRPOS(a.std, ' iela') + 4)) + 2, STRPOS(a.std, ', Saulstari') - LENGTH(LEFT(a.std, STRPOS(a.std, ' iela') + 4)) - 2)
  ,LEFT(a.std, STRPOS(a.std, ' iela') + 4)
  ,'Saulstari, Ķekava'
  ,'Ķekavas pag.'
  ,'Rīgas raj.'
FROM adreses_his_dat_sak a
LEFT JOIN vzd.adreses_his_ekas_split x ON a.id = x.id
WHERE std LIKE '%iela%, Saulstari, Ķekava, Ķekavas pag., Rīgas raj.%'
  AND x.id IS NULL
  AND a.tips_cd = 108;

INSERT INTO vzd.adreses_his_ekas_split (
  id
  ,nosaukums
  ,iela
  ,ciems
  ,pagasts
  ,rajons
  )
SELECT a.id
  ,SUBSTRING(a.std, LENGTH(LEFT(a.std, STRPOS(a.std, ' iela') + 4)) + 2, STRPOS(a.std, ', Zilgmes') - LENGTH(LEFT(a.std, STRPOS(a.std, ' iela') + 4)) - 2)
  ,LEFT(a.std, STRPOS(a.std, ' iela') + 4)
  ,'Zilgmes, Ķekava'
  ,'Ķekavas pag.'
  ,'Rīgas raj.'
FROM adreses_his_dat_sak a
LEFT JOIN vzd.adreses_his_ekas_split x ON a.id = x.id
WHERE std LIKE '%iela%, Zilgmes, Ķekava, Ķekavas pag., Rīgas raj.%'
  AND x.id IS NULL
  AND a.tips_cd = 108;

--Ar ielām.
WITH n (nosaukums)
AS (
  VALUES ('aleja')
    ,('apvedceļš')
    ,('bulvāris')
    ,('ceļš')
    ,('ciemats')
    ,('dambis')
    ,('gatve')
    ,('gāte')
    ,('iela')
    ,('krastmala')
    ,('laukums')
    ,('līnija')
    ,('maģistrāle')
    ,('mols')
    ,('perons')
    ,('prospekts')
    ,('sala')
    ,('skvērs')
    ,('stacija')
    ,('sēta')
    ,('šoseja')
    ,('šķērsiela')
    ,('šķērslīnija')
    ,('grava')
    ,('dārzs')
    ,('stūris')
    ,('parks')
    ,('tirgus')
    ,('piekraste')
    ,('valnis')
    ,('taka')
  )
  ,x
AS (
  SELECT DISTINCT a.id
    ,STRPOS(LOWER(a.std), ' ' || n.nosaukums || ' ') n_pos
    ,SUBSTRING(a.std, STRPOS(LOWER(a.std), ' ' || n.nosaukums || ' ') + LENGTH(n.nosaukums) + 2, STRPOS(a.std, ', ') - STRPOS(LOWER(a.std), ' ' || n.nosaukums || ' ') - LENGTH(n.nosaukums) - 2) nosaukums
    ,LEFT(a.std, STRPOS(LOWER(a.std), ' ' || n.nosaukums || ' ') + LENGTH(n.nosaukums)) iela
    ,CASE 
      WHEN b.tips_cd = 106
        THEN REPLACE(LEFT(b.std, COALESCE(NULLIF(STRPOS(b.std, ','), 0), LENGTH(b.std))), ',', '')
      ELSE NULL
      END ciems
    ,CASE 
      WHEN b.tips_cd = 104
        THEN REPLACE(LEFT(b.std, COALESCE(NULLIF(STRPOS(b.std, ','), 0), LENGTH(b.std))), ',', '')
      WHEN c.tips_cd = 104
        THEN REPLACE(LEFT(c.std, COALESCE(NULLIF(STRPOS(c.std, ','), 0), LENGTH(c.std))), ',', '')
      WHEN f.nosaukums IS NOT NULL
        THEN f.nosaukums
      ELSE NULL
      END pilseta
    ,CASE 
      WHEN b.tips_cd = 105
        THEN REPLACE(LEFT(b.std, COALESCE(NULLIF(STRPOS(b.std, ','), 0), LENGTH(b.std))), ',', '')
      WHEN c.tips_cd = 105
        THEN REPLACE(LEFT(c.std, COALESCE(NULLIF(STRPOS(c.std, ','), 0), LENGTH(c.std))), ',', '')
      ELSE NULL
      END pagasts
    ,CASE 
      WHEN b.tips_cd = 113
        THEN REPLACE(LEFT(b.std, COALESCE(NULLIF(STRPOS(b.std, ','), 0), LENGTH(b.std))), ',', '')
      WHEN c.tips_cd = 113
        THEN REPLACE(LEFT(c.std, COALESCE(NULLIF(STRPOS(c.std, ','), 0), LENGTH(c.std))), ',', '')
      WHEN d.tips_cd = 113
        THEN REPLACE(LEFT(d.std, COALESCE(NULLIF(STRPOS(d.std, ','), 0), LENGTH(d.std))), ',', '')
      ELSE NULL
      END novads
    ,CASE 
      WHEN c.tips_cd = 102
        THEN REPLACE(LEFT(c.std, COALESCE(NULLIF(STRPOS(c.std, ','), 0), LENGTH(c.std))), ',', '')
      WHEN d.tips_cd = 102
        THEN REPLACE(LEFT(d.std, COALESCE(NULLIF(STRPOS(d.std, ','), 0), LENGTH(d.std))), ',', '')
      WHEN e.tips_cd = 102
        THEN REPLACE(LEFT(e.std, COALESCE(NULLIF(STRPOS(e.std, ','), 0), LENGTH(e.std))), ',', '')
      ELSE NULL
      END rajons
  FROM adreses_his_dat_sak a
  LEFT JOIN adreses_his_upper b ON RIGHT(LEFT(a.std, COALESCE(NULLIF(STRPOS(a.std, 'LV-') - 3, - 3), LENGTH(a.std))), LENGTH(LEFT(a.std, COALESCE(NULLIF(STRPOS(a.std, 'LV-') - 3, - 3), LENGTH(a.std)))) - STRPOS(a.std, ', ') - 1) = b.std
    AND (
      a.dat_sak >= b.dat_sak
      OR b.dat_sak IS NULL
      )
    AND (
      a.dat_beig <= b.dat_beig
      OR b.dat_beig IS NULL
      ) --Piesaistot hierarhiski augstāku objektu, neņem vērā pasta indeksu.
  LEFT JOIN adreses_his_upper c ON RIGHT(b.std, LENGTH(b.std) - STRPOS(b.std, ',') - 1) = c.std
  LEFT JOIN adreses_his_upper d ON RIGHT(c.std, LENGTH(c.std) - STRPOS(c.std, ',') - 1) = d.std
  LEFT JOIN adreses_his_upper e ON RIGHT(d.std, LENGTH(d.std) - STRPOS(d.std, ',') - 1) = e.std
  LEFT JOIN (
    SELECT DISTINCT nosaukums
    FROM vzd.adreses
    WHERE tips_cd = 104
    ) f ON RIGHT(LEFT(a.std, COALESCE(NULLIF(STRPOS(a.std, 'LV-') - 3, - 3), LENGTH(a.std))), LENGTH(LEFT(a.std, COALESCE(NULLIF(STRPOS(a.std, 'LV-') - 3, - 3), LENGTH(a.std)))) - STRPOS(a.std, ',') - 1) = f.nosaukums --Tikai pilsētu nosaukumi gadījumiem, kad to nav laukā std (ir tikai kopā ar hierarhiski augstākiem objektiem).
  CROSS JOIN n
  LEFT JOIN vzd.adreses_his_ekas_split x ON a.id = x.id
  WHERE a.tips_cd = 108
    AND a.std ILIKE '% ' || n.nosaukums || ' %'
    AND (
      b.std NOT ILIKE '% ' || n.nosaukums || ' %'
      OR b.std IS NULL
      )
    AND a.std NOT LIKE '"%", %'
    AND x.id IS NULL
  )
  ,x2
AS (
  SELECT id
    ,MIN(n_pos) n_pos
  FROM x
  GROUP BY id
  )
  ,x3
AS (
  SELECT x.id
    ,x.nosaukums
    ,x.iela
    ,x.ciems
    ,x.pilseta
    ,x.pagasts
    ,x.novads
    ,x.rajons
  FROM x
  INNER JOIN x2 ON x.id = x2.id
    AND x.n_pos = x2.n_pos
  )
  ,x4
AS (
  SELECT id
  FROM x3
  GROUP BY id
  HAVING COUNT(*) = 1
  )
INSERT INTO vzd.adreses_his_ekas_split
SELECT x3.*
FROM x3
INNER JOIN x4 ON x3.id = x4.id;

--Ielas bez nomenklatūras vārdiem.
WITH x
AS (
  SELECT DISTINCT a.id
    ,SUBSTRING(a.std, STRPOS(a.std, (REGEXP_MATCHES(a.std, ' \d+')) [1]) + 1, STRPOS(a.std, ', ') - STRPOS(a.std, (REGEXP_MATCHES(a.std, ' \d+')) [1]) - 1) nosaukums
    ,LEFT(a.std, STRPOS(a.std, (REGEXP_MATCHES(a.std, ' \d+')) [1]) - 1) iela
    ,CASE 
      WHEN b.tips_cd = 106
        THEN REPLACE(LEFT(b.std, COALESCE(NULLIF(STRPOS(b.std, ','), 0), LENGTH(b.std))), ',', '')
      ELSE NULL
      END ciems
    ,CASE 
      WHEN b.tips_cd = 104
        THEN REPLACE(LEFT(b.std, COALESCE(NULLIF(STRPOS(b.std, ','), 0), LENGTH(b.std))), ',', '')
      WHEN c.tips_cd = 104
        THEN REPLACE(LEFT(c.std, COALESCE(NULLIF(STRPOS(c.std, ','), 0), LENGTH(c.std))), ',', '')
      WHEN f.nosaukums IS NOT NULL
        THEN f.nosaukums
      ELSE NULL
      END pilseta
    ,CASE 
      WHEN b.tips_cd = 105
        THEN REPLACE(LEFT(b.std, COALESCE(NULLIF(STRPOS(b.std, ','), 0), LENGTH(b.std))), ',', '')
      WHEN c.tips_cd = 105
        THEN REPLACE(LEFT(c.std, COALESCE(NULLIF(STRPOS(c.std, ','), 0), LENGTH(c.std))), ',', '')
      ELSE NULL
      END pagasts
    ,CASE 
      WHEN b.tips_cd = 113
        THEN REPLACE(LEFT(b.std, COALESCE(NULLIF(STRPOS(b.std, ','), 0), LENGTH(b.std))), ',', '')
      WHEN c.tips_cd = 113
        THEN REPLACE(LEFT(c.std, COALESCE(NULLIF(STRPOS(c.std, ','), 0), LENGTH(c.std))), ',', '')
      WHEN d.tips_cd = 113
        THEN REPLACE(LEFT(d.std, COALESCE(NULLIF(STRPOS(d.std, ','), 0), LENGTH(d.std))), ',', '')
      ELSE NULL
      END novads
    ,CASE 
      WHEN c.tips_cd = 102
        THEN REPLACE(LEFT(c.std, COALESCE(NULLIF(STRPOS(c.std, ','), 0), LENGTH(c.std))), ',', '')
      WHEN d.tips_cd = 102
        THEN REPLACE(LEFT(d.std, COALESCE(NULLIF(STRPOS(d.std, ','), 0), LENGTH(d.std))), ',', '')
      WHEN e.tips_cd = 102
        THEN REPLACE(LEFT(e.std, COALESCE(NULLIF(STRPOS(e.std, ','), 0), LENGTH(e.std))), ',', '')
      ELSE NULL
      END rajons
  FROM adreses_his_dat_sak a
  LEFT JOIN adreses_his_upper b ON RIGHT(LEFT(a.std, COALESCE(NULLIF(STRPOS(a.std, 'LV-') - 3, - 3), LENGTH(a.std))), LENGTH(LEFT(a.std, COALESCE(NULLIF(STRPOS(a.std, 'LV-') - 3, - 3), LENGTH(a.std)))) - STRPOS(a.std, ', ') - 1) = b.std
  AND (
    a.dat_sak >= b.dat_sak
    OR b.dat_sak IS NULL
    )
  AND (
    a.dat_beig <= b.dat_beig
    OR b.dat_beig IS NULL
    ) --Piesaistot hierarhiski augstāku objektu, neņem vērā pasta indeksu.
  LEFT JOIN adreses_his_upper c ON RIGHT(b.std, LENGTH(b.std) - STRPOS(b.std, ',') - 1) = c.std
  LEFT JOIN adreses_his_upper d ON RIGHT(c.std, LENGTH(c.std) - STRPOS(c.std, ',') - 1) = d.std
  LEFT JOIN adreses_his_upper e ON RIGHT(d.std, LENGTH(d.std) - STRPOS(d.std, ',') - 1) = e.std
  LEFT JOIN (
    SELECT DISTINCT nosaukums
    FROM vzd.adreses
    WHERE tips_cd = 104
    ) f ON RIGHT(LEFT(a.std, COALESCE(NULLIF(STRPOS(a.std, 'LV-') - 3, - 3), LENGTH(a.std))), LENGTH(LEFT(a.std, COALESCE(NULLIF(STRPOS(a.std, 'LV-') - 3, - 3), LENGTH(a.std)))) - STRPOS(a.std, ',') - 1) = f.nosaukums --Tikai pilsētu nosaukumi gadījumiem, kad to nav laukā std (ir tikai kopā ar hierarhiski augstākiem objektiem).
  LEFT JOIN vzd.adreses_his_ekas_split x ON a.id = x.id
  WHERE a.tips_cd = 108
    AND x.id IS NULL
  )
  ,x2
AS (
  SELECT id
  FROM x
  GROUP BY id
  HAVING COUNT(*) = 1
  )
INSERT INTO vzd.adreses_his_ekas_split
SELECT x.*
FROM x
INNER JOIN x2 ON x.id = x2.id;

--Izņēmuma gadījumi, kad ielām bez nomenklatūras vārdiem ir mājvārdi, nevis numuri.
INSERT INTO vzd.adreses_his_ekas_split (
  id
  ,nosaukums
  ,iela
  ,ciems
  ,pagasts
  ,rajons
  )
SELECT a.id
  ,SUBSTRING(a.std, LENGTH('Iela uz attīrīšanas iekārtām ') + 1, STRPOS(a.std, ',') - LENGTH('Iela uz attīrīšanas iekārtām ') - 1)
  ,'Iela uz attīrīšanas iekārtām'
  ,'Renda'
  ,'Rendas pag.'
  ,'Kuldīgas raj.'
FROM adreses_his_dat_sak a
LEFT JOIN vzd.adreses_his_ekas_split x ON a.id = x.id
WHERE std LIKE 'Iela uz attīrīšanas iekārtām %, Renda, Rendas pag., Kuldīgas raj.%'
  AND x.id IS NULL
  AND a.tips_cd = 108;

INSERT INTO vzd.adreses_his_ekas_split (
  id
  ,nosaukums
  ,iela
  ,pilseta
  )
SELECT a.id
  ,SUBSTRING(a.std, LENGTH('Vakarbuļļi ') + 1, STRPOS(a.std, ',') - LENGTH('Vakarbuļļi ') - 1)
  ,'Vakarbuļļi'
  ,'Rīga'
FROM adreses_his_dat_sak a
LEFT JOIN vzd.adreses_his_ekas_split x ON a.id = x.id
WHERE std LIKE 'Vakarbuļļi %, Rīga%'
  AND x.id IS NULL
  AND a.tips_cd = 108;

--Dzēš atstarpes sākumā un beigās un aizstāj vairākas sekojošas atstarpes ar vienu.
UPDATE vzd.adreses_his_ekas_split
SET nosaukums = TRIM(regexp_replace(nosaukums, '\s+', ' ', 'g'));

UPDATE vzd.adreses_his_ekas_split
SET iela = TRIM(regexp_replace(iela, '\s+', ' ', 'g'));

UPDATE vzd.adreses_his_ekas_split
SET ciems = TRIM(regexp_replace(ciems, '\s+', ' ', 'g'));

UPDATE vzd.adreses_his_ekas_split
SET pilseta = TRIM(regexp_replace(pilseta, '\s+', ' ', 'g'));

UPDATE vzd.adreses_his_ekas_split
SET pagasts = TRIM(regexp_replace(pagasts, '\s+', ' ', 'g'));

UPDATE vzd.adreses_his_ekas_split
SET novads = TRIM(regexp_replace(novads, '\s+', ' ', 'g'));

UPDATE vzd.adreses_his_ekas_split
SET rajons = TRIM(regexp_replace(rajons, '\s+', ' ', 'g'));

/*
--Pārbauda, vai nav nesadalītu ierakstu.
SELECT *
FROM vzd.adreses_his a
LEFT JOIN vzd.adreses_his_ekas_split b ON a.id = b.id
WHERE a.tips_cd = 108
  AND b.id IS NULL;
*/

/*
--Pārbauda, vai nav nepiekārtotu hierarhiski augstāku objektu.
SELECT a.*
  ,b.std
FROM vzd.adreses_his_ekas_split a
INNER JOIN vzd.adreses_his b ON a.id = b.id
WHERE --ciems IS NULL AND
  pilseta IS NULL
  AND pagasts IS NULL
  AND novads IS NULL
  AND rajons IS NULL
ORDER BY b.std;
*/

/*
--Pārbauda, vai sadalītie ieraksti apvienojot sakrīt ar sākotnējo pilno pierakstu.
SELECT *
FROM vzd.adreses_his_ekas_split a
INNER JOIN vzd.adreses_his b ON a.id = b.id
WHERE nosaukums || ', ' || ciems || ', ' || pagasts || ', ' || rajons NOT LIKE left(b.std, LENGTH(b.std) - 9)
  AND nosaukums IS NOT NULL
  AND iela IS NULL
  AND ciems IS NOT NULL
  AND pilseta IS NULL
  AND pagasts IS NOT NULL
  AND novads IS NULL
  AND rajons IS NOT NULL
  AND b.std LIKE '%, LV-%'

UNION

SELECT *
FROM vzd.adreses_his_ekas_split a
INNER JOIN vzd.adreses_his b ON a.id = b.id
WHERE nosaukums || ', ' || ciems || ', ' || pagasts || ', ' || rajons NOT LIKE b.std
  AND nosaukums IS NOT NULL
  AND iela IS NULL
  AND ciems IS NOT NULL
  AND pilseta IS NULL
  AND pagasts IS NOT NULL
  AND novads IS NULL
  AND rajons IS NOT NULL
  AND b.std NOT LIKE '%, LV-%'

UNION

SELECT *
FROM vzd.adreses_his_ekas_split a
INNER JOIN vzd.adreses_his b ON a.id = b.id
WHERE nosaukums || ', ' || ciems || ', ' || pagasts || ', ' || novads || ', ' || rajons NOT LIKE left(b.std, LENGTH(b.std) - 9)
  AND nosaukums IS NOT NULL
  AND iela IS NULL
  AND ciems IS NOT NULL
  AND pilseta IS NULL
  AND pagasts IS NOT NULL
  AND novads IS NOT NULL
  AND rajons IS NOT NULL
  AND b.std LIKE '%, LV-%'

UNION

SELECT *
FROM vzd.adreses_his_ekas_split a
INNER JOIN vzd.adreses_his b ON a.id = b.id
WHERE nosaukums || ', ' || ciems || ', ' || pagasts || ', ' || novads || ', ' || rajons NOT LIKE b.std
  AND nosaukums IS NOT NULL
  AND iela IS NULL
  AND ciems IS NOT NULL
  AND pilseta IS NULL
  AND pagasts IS NOT NULL
  AND novads IS NOT NULL
  AND rajons IS NOT NULL
  AND b.std NOT LIKE '%, LV-%'

UNION

SELECT *
FROM vzd.adreses_his_ekas_split a
INNER JOIN vzd.adreses_his b ON a.id = b.id
WHERE nosaukums || ', ' || ciems || ', ' || pagasts || ', ' || novads NOT LIKE left(b.std, LENGTH(b.std) - 9)
  AND nosaukums IS NOT NULL
  AND iela IS NULL
  AND ciems IS NOT NULL
  AND pilseta IS NULL
  AND pagasts IS NOT NULL
  AND novads IS NOT NULL
  AND rajons IS NULL
  AND b.std LIKE '%, LV-%'

UNION

SELECT *
FROM vzd.adreses_his_ekas_split a
INNER JOIN vzd.adreses_his b ON a.id = b.id
WHERE nosaukums || ', ' || ciems || ', ' || pagasts || ', ' || novads NOT LIKE b.std
  AND nosaukums IS NOT NULL
  AND iela IS NULL
  AND ciems IS NOT NULL
  AND pilseta IS NULL
  AND pagasts IS NOT NULL
  AND novads IS NOT NULL
  AND rajons IS NULL
  AND b.std NOT LIKE '%, LV-%'

UNION

SELECT *
FROM vzd.adreses_his_ekas_split a
INNER JOIN vzd.adreses_his b ON a.id = b.id
WHERE nosaukums || ', ' || ciems || ', ' || novads || ', ' || rajons NOT LIKE left(b.std, LENGTH(b.std) - 9)
  AND nosaukums IS NOT NULL
  AND iela IS NULL
  AND ciems IS NOT NULL
  AND pilseta IS NULL
  AND pagasts IS NULL
  AND novads IS NOT NULL
  AND rajons IS NOT NULL
  AND b.std LIKE '%, LV-%'

UNION

SELECT *
FROM vzd.adreses_his_ekas_split a
INNER JOIN vzd.adreses_his b ON a.id = b.id
WHERE nosaukums || ', ' || ciems || ', ' || novads || ', ' || rajons NOT LIKE b.std
  AND nosaukums IS NOT NULL
  AND iela IS NULL
  AND ciems IS NOT NULL
  AND pilseta IS NULL
  AND pagasts IS NULL
  AND novads IS NOT NULL
  AND rajons IS NOT NULL
  AND b.std NOT LIKE '%, LV-%'

UNION

SELECT *
FROM vzd.adreses_his_ekas_split a
INNER JOIN vzd.adreses_his b ON a.id = b.id
WHERE nosaukums || ', ' || ciems || ', ' || novads NOT LIKE left(b.std, LENGTH(b.std) - 9)
  AND nosaukums IS NOT NULL
  AND iela IS NULL
  AND ciems IS NOT NULL
  AND pilseta IS NULL
  AND pagasts IS NULL
  AND novads IS NOT NULL
  AND rajons IS NULL
  AND b.std LIKE '%, LV-%'

UNION

SELECT *
FROM vzd.adreses_his_ekas_split a
INNER JOIN vzd.adreses_his b ON a.id = b.id
WHERE nosaukums || ', ' || ciems || ', ' || novads NOT LIKE b.std
  AND nosaukums IS NOT NULL
  AND iela IS NULL
  AND ciems IS NOT NULL
  AND pilseta IS NULL
  AND pagasts IS NULL
  AND novads IS NOT NULL
  AND rajons IS NULL
  AND b.std NOT LIKE '%, LV-%'

UNION

SELECT *
FROM vzd.adreses_his_ekas_split a
INNER JOIN vzd.adreses_his b ON a.id = b.id
WHERE nosaukums || ', ' || pilseta || ', ' || rajons NOT LIKE left(b.std, LENGTH(b.std) - 9)
  AND nosaukums IS NOT NULL
  AND iela IS NULL
  AND ciems IS NULL
  AND pilseta IS NOT NULL
  AND pagasts IS NULL
  AND novads IS NULL
  AND rajons IS NOT NULL
  AND b.std LIKE '%, LV-%'

UNION

SELECT *
FROM vzd.adreses_his_ekas_split a
INNER JOIN vzd.adreses_his b ON a.id = b.id
WHERE nosaukums || ', ' || pilseta || ', ' || rajons NOT LIKE b.std
  AND nosaukums IS NOT NULL
  AND iela IS NULL
  AND ciems IS NULL
  AND pilseta IS NOT NULL
  AND pagasts IS NULL
  AND novads IS NULL
  AND rajons IS NOT NULL
  AND b.std NOT LIKE '%, LV-%'

UNION

SELECT *
FROM vzd.adreses_his_ekas_split a
INNER JOIN vzd.adreses_his b ON a.id = b.id
WHERE nosaukums || ', ' || pilseta || ', ' || novads || ', ' || rajons NOT LIKE left(b.std, LENGTH(b.std) - 9)
  AND nosaukums IS NOT NULL
  AND iela IS NULL
  AND ciems IS NULL
  AND pilseta IS NOT NULL
  AND pagasts IS NULL
  AND novads IS NOT NULL
  AND rajons IS NOT NULL
  AND b.std LIKE '%, LV-%'

UNION

SELECT *
FROM vzd.adreses_his_ekas_split a
INNER JOIN vzd.adreses_his b ON a.id = b.id
WHERE nosaukums || ', ' || pilseta || ', ' || novads || ', ' || rajons NOT LIKE b.std
  AND nosaukums IS NOT NULL
  AND iela IS NULL
  AND ciems IS NULL
  AND pilseta IS NOT NULL
  AND pagasts IS NULL
  AND novads IS NOT NULL
  AND rajons IS NOT NULL
  AND b.std NOT LIKE '%, LV-%'

UNION

SELECT *
FROM vzd.adreses_his_ekas_split a
INNER JOIN vzd.adreses_his b ON a.id = b.id
WHERE nosaukums || ', ' || pilseta || ', ' || novads NOT LIKE left(b.std, LENGTH(b.std) - 9)
  AND nosaukums IS NOT NULL
  AND iela IS NULL
  AND ciems IS NULL
  AND pilseta IS NOT NULL
  AND pagasts IS NULL
  AND novads IS NOT NULL
  AND rajons IS NULL
  AND b.std LIKE '%, LV-%'

UNION

SELECT *
FROM vzd.adreses_his_ekas_split a
INNER JOIN vzd.adreses_his b ON a.id = b.id
WHERE nosaukums || ', ' || pilseta || ', ' || novads NOT LIKE b.std
  AND nosaukums IS NOT NULL
  AND iela IS NULL
  AND ciems IS NULL
  AND pilseta IS NOT NULL
  AND pagasts IS NULL
  AND novads IS NOT NULL
  AND rajons IS NULL
  AND b.std NOT LIKE '%, LV-%'

UNION

SELECT *
FROM vzd.adreses_his_ekas_split a
INNER JOIN vzd.adreses_his b ON a.id = b.id
WHERE nosaukums || ', ' || pilseta NOT LIKE left(b.std, LENGTH(b.std) - 9)
  AND nosaukums IS NOT NULL
  AND iela IS NULL
  AND ciems IS NULL
  AND pilseta IS NOT NULL
  AND pagasts IS NULL
  AND novads IS NULL
  AND rajons IS NULL
  AND b.std LIKE '%, LV-%'

UNION

SELECT *
FROM vzd.adreses_his_ekas_split a
INNER JOIN vzd.adreses_his b ON a.id = b.id
WHERE nosaukums || ', ' || pilseta NOT LIKE b.std
  AND nosaukums IS NOT NULL
  AND iela IS NULL
  AND ciems IS NULL
  AND pilseta IS NOT NULL
  AND pagasts IS NULL
  AND novads IS NULL
  AND rajons IS NULL
  AND b.std NOT LIKE '%, LV-%'

UNION

SELECT *
FROM vzd.adreses_his_ekas_split a
INNER JOIN vzd.adreses_his b ON a.id = b.id
WHERE nosaukums || ', ' || pagasts || ', ' || rajons NOT LIKE left(b.std, LENGTH(b.std) - 9)
  AND nosaukums IS NOT NULL
  AND iela IS NULL
  AND ciems IS NULL
  AND pilseta IS NULL
  AND pagasts IS NOT NULL
  AND novads IS NULL
  AND rajons IS NOT NULL
  AND b.std LIKE '%, LV-%'

UNION

SELECT *
FROM vzd.adreses_his_ekas_split a
INNER JOIN vzd.adreses_his b ON a.id = b.id
WHERE nosaukums || ', ' || pagasts || ', ' || rajons NOT LIKE b.std
  AND nosaukums IS NOT NULL
  AND iela IS NULL
  AND ciems IS NULL
  AND pilseta IS NULL
  AND pagasts IS NOT NULL
  AND novads IS NULL
  AND rajons IS NOT NULL
  AND b.std NOT LIKE '%, LV-%'

UNION

SELECT *
FROM vzd.adreses_his_ekas_split a
INNER JOIN vzd.adreses_his b ON a.id = b.id
WHERE nosaukums || ', ' || pagasts || ', ' || novads || ', ' || rajons NOT LIKE left(b.std, LENGTH(b.std) - 9)
  AND nosaukums IS NOT NULL
  AND iela IS NULL
  AND ciems IS NULL
  AND pilseta IS NULL
  AND pagasts IS NOT NULL
  AND novads IS NOT NULL
  AND rajons IS NOT NULL
  AND b.std LIKE '%, LV-%'

UNION

SELECT *
FROM vzd.adreses_his_ekas_split a
INNER JOIN vzd.adreses_his b ON a.id = b.id
WHERE nosaukums || ', ' || pagasts || ', ' || novads || ', ' || rajons NOT LIKE b.std
  AND nosaukums IS NOT NULL
  AND iela IS NULL
  AND ciems IS NULL
  AND pilseta IS NULL
  AND pagasts IS NOT NULL
  AND novads IS NOT NULL
  AND rajons IS NOT NULL
  AND b.std NOT LIKE '%, LV-%'

UNION

SELECT *
FROM vzd.adreses_his_ekas_split a
INNER JOIN vzd.adreses_his b ON a.id = b.id
WHERE nosaukums || ', ' || pagasts || ', ' || novads NOT LIKE left(b.std, LENGTH(b.std) - 9)
  AND nosaukums IS NOT NULL
  AND iela IS NULL
  AND ciems IS NULL
  AND pilseta IS NULL
  AND pagasts IS NOT NULL
  AND novads IS NOT NULL
  AND rajons IS NULL
  AND b.std LIKE '%, LV-%'

UNION

SELECT *
FROM vzd.adreses_his_ekas_split a
INNER JOIN vzd.adreses_his b ON a.id = b.id
WHERE nosaukums || ', ' || pagasts || ', ' || novads NOT LIKE b.std
  AND nosaukums IS NOT NULL
  AND iela IS NULL
  AND ciems IS NULL
  AND pilseta IS NULL
  AND pagasts IS NOT NULL
  AND novads IS NOT NULL
  AND rajons IS NULL
  AND b.std NOT LIKE '%, LV-%'

UNION

SELECT *
FROM vzd.adreses_his_ekas_split a
INNER JOIN vzd.adreses_his b ON a.id = b.id
WHERE nosaukums || ', ' || novads || ', ' || rajons NOT LIKE left(b.std, LENGTH(b.std) - 9)
  AND nosaukums IS NOT NULL
  AND iela IS NULL
  AND ciems IS NULL
  AND pilseta IS NULL
  AND pagasts IS NULL
  AND novads IS NOT NULL
  AND rajons IS NOT NULL
  AND b.std LIKE '%, LV-%'

UNION

SELECT *
FROM vzd.adreses_his_ekas_split a
INNER JOIN vzd.adreses_his b ON a.id = b.id
WHERE nosaukums || ', ' || novads || ', ' || rajons NOT LIKE b.std
  AND nosaukums IS NOT NULL
  AND iela IS NULL
  AND ciems IS NULL
  AND pilseta IS NULL
  AND pagasts IS NULL
  AND novads IS NOT NULL
  AND rajons IS NOT NULL
  AND b.std NOT LIKE '%, LV-%'

UNION

SELECT *
FROM vzd.adreses_his_ekas_split a
INNER JOIN vzd.adreses_his b ON a.id = b.id
WHERE nosaukums || ', ' || novads NOT LIKE left(b.std, LENGTH(b.std) - 9)
  AND nosaukums IS NOT NULL
  AND iela IS NULL
  AND ciems IS NULL
  AND pilseta IS NULL
  AND pagasts IS NULL
  AND novads IS NOT NULL
  AND rajons IS NULL
  AND b.std LIKE '%, LV-%'

UNION

SELECT *
FROM vzd.adreses_his_ekas_split a
INNER JOIN vzd.adreses_his b ON a.id = b.id
WHERE nosaukums || ', ' || novads NOT LIKE b.std
  AND nosaukums IS NOT NULL
  AND iela IS NULL
  AND ciems IS NULL
  AND pilseta IS NULL
  AND pagasts IS NULL
  AND novads IS NOT NULL
  AND rajons IS NULL
  AND b.std NOT LIKE '%, LV-%'

UNION

SELECT *
FROM vzd.adreses_his_ekas_split a
INNER JOIN vzd.adreses_his b ON a.id = b.id
WHERE iela || ' ' || nosaukums || ', ' || ciems || ', ' || pagasts || ', ' || rajons NOT LIKE left(b.std, LENGTH(b.std) - 9)
  AND nosaukums IS NOT NULL
  AND iela IS NOT NULL
  AND ciems IS NOT NULL
  AND pilseta IS NULL
  AND pagasts IS NOT NULL
  AND novads IS NULL
  AND rajons IS NOT NULL
  AND b.std LIKE '%, LV-%'

UNION

SELECT *
FROM vzd.adreses_his_ekas_split a
INNER JOIN vzd.adreses_his b ON a.id = b.id
WHERE iela || ' ' || nosaukums || ', ' || ciems || ', ' || pagasts || ', ' || rajons NOT LIKE b.std
  AND nosaukums IS NOT NULL
  AND iela IS NOT NULL
  AND ciems IS NOT NULL
  AND pilseta IS NULL
  AND pagasts IS NOT NULL
  AND novads IS NULL
  AND rajons IS NOT NULL
  AND b.std NOT LIKE '%, LV-%'

UNION

SELECT *
FROM vzd.adreses_his_ekas_split a
INNER JOIN vzd.adreses_his b ON a.id = b.id
WHERE iela || ' ' || nosaukums || ', ' || ciems || ', ' || pagasts || ', ' || novads || ', ' || rajons NOT LIKE left(b.std, LENGTH(b.std) - 9)
  AND nosaukums IS NOT NULL
  AND iela IS NOT NULL
  AND ciems IS NOT NULL
  AND pilseta IS NULL
  AND pagasts IS NOT NULL
  AND novads IS NOT NULL
  AND rajons IS NOT NULL
  AND b.std LIKE '%, LV-%'

UNION

SELECT *
FROM vzd.adreses_his_ekas_split a
INNER JOIN vzd.adreses_his b ON a.id = b.id
WHERE iela || ' ' || nosaukums || ', ' || ciems || ', ' || pagasts || ', ' || novads || ', ' || rajons NOT LIKE b.std
  AND nosaukums IS NOT NULL
  AND iela IS NOT NULL
  AND ciems IS NOT NULL
  AND pilseta IS NULL
  AND pagasts IS NOT NULL
  AND novads IS NOT NULL
  AND rajons IS NOT NULL
  AND b.std NOT LIKE '%, LV-%'

UNION

SELECT *
FROM vzd.adreses_his_ekas_split a
INNER JOIN vzd.adreses_his b ON a.id = b.id
WHERE iela || ' ' || nosaukums || ', ' || ciems || ', ' || pagasts || ', ' || novads NOT LIKE left(b.std, LENGTH(b.std) - 9)
  AND nosaukums IS NOT NULL
  AND iela IS NOT NULL
  AND ciems IS NOT NULL
  AND pilseta IS NULL
  AND pagasts IS NOT NULL
  AND novads IS NOT NULL
  AND rajons IS NULL
  AND b.std LIKE '%, LV-%'

UNION

SELECT *
FROM vzd.adreses_his_ekas_split a
INNER JOIN vzd.adreses_his b ON a.id = b.id
WHERE iela || ' ' || nosaukums || ', ' || ciems || ', ' || pagasts || ', ' || novads NOT LIKE b.std
  AND nosaukums IS NOT NULL
  AND iela IS NOT NULL
  AND ciems IS NOT NULL
  AND pilseta IS NULL
  AND pagasts IS NOT NULL
  AND novads IS NOT NULL
  AND rajons IS NULL
  AND b.std NOT LIKE '%, LV-%'

UNION

SELECT *
FROM vzd.adreses_his_ekas_split a
INNER JOIN vzd.adreses_his b ON a.id = b.id
WHERE iela || ' ' || nosaukums || ', ' || ciems || ', ' || novads || ', ' || rajons NOT LIKE left(b.std, LENGTH(b.std) - 9)
  AND nosaukums IS NOT NULL
  AND iela IS NOT NULL
  AND ciems IS NOT NULL
  AND pilseta IS NULL
  AND pagasts IS NULL
  AND novads IS NOT NULL
  AND rajons IS NOT NULL
  AND b.std LIKE '%, LV-%'

UNION

SELECT *
FROM vzd.adreses_his_ekas_split a
INNER JOIN vzd.adreses_his b ON a.id = b.id
WHERE iela || ' ' || nosaukums || ', ' || ciems || ', ' || novads || ', ' || rajons NOT LIKE b.std
  AND nosaukums IS NOT NULL
  AND iela IS NOT NULL
  AND ciems IS NOT NULL
  AND pilseta IS NULL
  AND pagasts IS NULL
  AND novads IS NOT NULL
  AND rajons IS NOT NULL
  AND b.std NOT LIKE '%, LV-%'

UNION

SELECT *
FROM vzd.adreses_his_ekas_split a
INNER JOIN vzd.adreses_his b ON a.id = b.id
WHERE iela || ' ' || nosaukums || ', ' || ciems || ', ' || novads NOT LIKE left(b.std, LENGTH(b.std) - 9)
  AND nosaukums IS NOT NULL
  AND iela IS NOT NULL
  AND ciems IS NOT NULL
  AND pilseta IS NULL
  AND pagasts IS NULL
  AND novads IS NOT NULL
  AND rajons IS NULL
  AND b.std LIKE '%, LV-%'

UNION

SELECT *
FROM vzd.adreses_his_ekas_split a
INNER JOIN vzd.adreses_his b ON a.id = b.id
WHERE iela || ' ' || nosaukums || ', ' || ciems || ', ' || novads NOT LIKE b.std
  AND nosaukums IS NOT NULL
  AND iela IS NOT NULL
  AND ciems IS NOT NULL
  AND pilseta IS NULL
  AND pagasts IS NULL
  AND novads IS NOT NULL
  AND rajons IS NULL
  AND b.std NOT LIKE '%, LV-%'

UNION

SELECT *
FROM vzd.adreses_his_ekas_split a
INNER JOIN vzd.adreses_his b ON a.id = b.id
WHERE iela || ' ' || nosaukums || ', ' || pilseta || ', ' || rajons NOT LIKE left(b.std, LENGTH(b.std) - 9)
  AND nosaukums IS NOT NULL
  AND iela IS NOT NULL
  AND ciems IS NULL
  AND pilseta IS NOT NULL
  AND pagasts IS NULL
  AND novads IS NULL
  AND rajons IS NOT NULL
  AND b.std LIKE '%, LV-%'

UNION

SELECT *
FROM vzd.adreses_his_ekas_split a
INNER JOIN vzd.adreses_his b ON a.id = b.id
WHERE iela || ' ' || nosaukums || ', ' || pilseta || ', ' || rajons NOT LIKE b.std
  AND nosaukums IS NOT NULL
  AND iela IS NOT NULL
  AND ciems IS NULL
  AND pilseta IS NOT NULL
  AND pagasts IS NULL
  AND novads IS NULL
  AND rajons IS NOT NULL
  AND b.std NOT LIKE '%, LV-%'

UNION

SELECT *
FROM vzd.adreses_his_ekas_split a
INNER JOIN vzd.adreses_his b ON a.id = b.id
WHERE iela || ' ' || nosaukums || ', ' || pilseta || ', ' || novads || ', ' || rajons NOT LIKE left(b.std, LENGTH(b.std) - 9)
  AND nosaukums IS NOT NULL
  AND iela IS NOT NULL
  AND ciems IS NULL
  AND pilseta IS NOT NULL
  AND pagasts IS NULL
  AND novads IS NOT NULL
  AND rajons IS NOT NULL
  AND b.std LIKE '%, LV-%'

UNION

SELECT *
FROM vzd.adreses_his_ekas_split a
INNER JOIN vzd.adreses_his b ON a.id = b.id
WHERE iela || ' ' || nosaukums || ', ' || pilseta || ', ' || novads || ', ' || rajons NOT LIKE b.std
  AND nosaukums IS NOT NULL
  AND iela IS NOT NULL
  AND ciems IS NULL
  AND pilseta IS NOT NULL
  AND pagasts IS NULL
  AND novads IS NOT NULL
  AND rajons IS NOT NULL
  AND b.std NOT LIKE '%, LV-%'

UNION

SELECT *
FROM vzd.adreses_his_ekas_split a
INNER JOIN vzd.adreses_his b ON a.id = b.id
WHERE iela || ' ' || nosaukums || ', ' || pilseta || ', ' || novads NOT LIKE left(b.std, LENGTH(b.std) - 9)
  AND nosaukums IS NOT NULL
  AND iela IS NOT NULL
  AND ciems IS NULL
  AND pilseta IS NOT NULL
  AND pagasts IS NULL
  AND novads IS NOT NULL
  AND rajons IS NULL
  AND b.std LIKE '%, LV-%'

UNION

SELECT *
FROM vzd.adreses_his_ekas_split a
INNER JOIN vzd.adreses_his b ON a.id = b.id
WHERE iela || ' ' || nosaukums || ', ' || pilseta || ', ' || novads NOT LIKE b.std
  AND nosaukums IS NOT NULL
  AND iela IS NOT NULL
  AND ciems IS NULL
  AND pilseta IS NOT NULL
  AND pagasts IS NULL
  AND novads IS NOT NULL
  AND rajons IS NULL
  AND b.std NOT LIKE '%, LV-%'

UNION

SELECT *
FROM vzd.adreses_his_ekas_split a
INNER JOIN vzd.adreses_his b ON a.id = b.id
WHERE iela || ' ' || nosaukums || ', ' || pilseta NOT LIKE left(b.std, LENGTH(b.std) - 9)
  AND nosaukums IS NOT NULL
  AND iela IS NOT NULL
  AND ciems IS NULL
  AND pilseta IS NOT NULL
  AND pagasts IS NULL
  AND novads IS NULL
  AND rajons IS NULL
  AND b.std LIKE '%, LV-%'

UNION

SELECT *
FROM vzd.adreses_his_ekas_split a
INNER JOIN vzd.adreses_his b ON a.id = b.id
WHERE iela || ' ' || nosaukums || ', ' || pilseta NOT LIKE b.std
  AND nosaukums IS NOT NULL
  AND iela IS NOT NULL
  AND ciems IS NULL
  AND pilseta IS NOT NULL
  AND pagasts IS NULL
  AND novads IS NULL
  AND rajons IS NULL
  AND b.std NOT LIKE '%, LV-%';
*/

END;
$BODY$;

GRANT EXECUTE ON PROCEDURE vzd.adreses_his_ekas_split() TO scheduler;