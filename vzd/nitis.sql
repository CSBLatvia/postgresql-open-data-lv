CREATE OR REPLACE PROCEDURE vzd.nitis(
	)
LANGUAGE 'plpgsql'

AS $BODY$BEGIN

--ZV.
---nitis_zv.
CREATE TEMPORARY TABLE nitis_zv_min_year AS
SELECT MIN(SUBSTRING(filename, strpos(filename, '.') - 4, 4)::SMALLINT) gads
  ,dar__juma_id::INT darijuma_id
FROM vzd.zv
GROUP BY dar__juma_id;

INSERT INTO vzd.nitis_zv (
  gads
  ,darijuma_id
  ,darijuma_datums
  ,kadastra_nr
  ,adrese
  ,atvk
  ,darijuma_summa
  ,zemes_skaititajs
  ,zemes_saucejs
  ,apbuveta
  ,kopplatiba
  --,lauksaimniecibas_zeme
  ,aramzeme
  ,auglu_darzi
  ,plavas
  ,ganibas
  ,melioreta_liz
  ,mezi
  ,krumaji
  ,purvi
  ,zem_udeniem
  ,zem_dikiem
  ,zem_ekam_un_pagalmiem
  ,zem_celiem
  ,pareja_zeme
  )
WITH d
AS (
  SELECT at_kods
    ,COUNT(*) cnt
  FROM csp.atvk_2022_parejas_tabula
  GROUP BY at_kods
  )
  ,e
AS (
  SELECT b.*
  FROM d
  INNER JOIN csp.atvk_2022_parejas_tabula b ON d.at_kods = b.at_kods
  WHERE d.cnt = 1
  )
  ,m
AS (
  SELECT dar__juma_id
    ,MIN(filename) filename
  FROM vzd.zv
  GROUP BY dar__juma_id
  )
  ,x
AS (
  SELECT DISTINCT dar__juma_id
    ,zemes_da__as__skait__t__js_
    ,zemes_da__as__sauc__js_
  FROM vzd.zv
  )
  ,y
AS (
  SELECT dar__juma_id darijuma_id
  FROM x
  GROUP BY dar__juma_id
  HAVING COUNT(*) > 1
  ) --Darījumi, kuros zemes vienībām ir dažādas daļas.
SELECT DISTINCT SUBSTRING(a.filename, strpos(a.filename, '.') - 4, 4)::SMALLINT
  ,a.dar__juma_id::INT
  ,to_date(dar__juma_datums, 'dd.mm.yyy')::DATE
  ,__pa__uma_kadastra_numurs
  ,adreses_pieraksts
  ,CASE 
    WHEN b.code IS NOT NULL
      THEN b.code
    WHEN c.code IS NOT NULL
      THEN c.code
    WHEN c2.code IS NOT NULL
      THEN c2.code
    WHEN e.tv2022_kods IS NOT NULL
      THEN e.tv2022_kods
    ELSE NULL
    END
  ,REPLACE(dar__juma_summa__eur, ',', '.')::DECIMAL(10, 2)
  ,CASE 
    WHEN y.darijuma_id IS NOT NULL
      THEN NULL
    ELSE zemes_da__as__skait__t__js_::BIGINT
    END
  ,CASE 
    WHEN y.darijuma_id IS NOT NULL
      THEN NULL
    ELSE zemes_da__as__sauc__js_::BIGINT
    END
  ,vai_zeme_ir_apb__v__ta__0_nav_1_ir_::SMALLINT
  ,CASE 
    WHEN p__rdot___zemes_kopplat__ba__m2 LIKE 'NULL'
      THEN NULL
    ELSE REPLACE(p__rdot___zemes_kopplat__ba__m2, ',', '.')::DECIMAL(10, 2)
    END
  /*,CASE 
    WHEN p__rdot___lauksaimniec__bas_zemes_plat__ba__m2 LIKE 'NULL'
      THEN NULL
    ELSE REPLACE(p__rdot___lauksaimniec__bas_zemes_plat__ba__m2, ',', '.')::DECIMAL(10, 2)
    END*/
  ,CASE 
    WHEN p__rdot___aramzemes_plat__ba__m2 LIKE 'NULL'
      THEN NULL
    ELSE REPLACE(p__rdot___aramzemes_plat__ba__m2, ',', '.')::DECIMAL(10, 2)
    END
  ,CASE 
    WHEN p__rdot___aug__u_d__rzu_plat__ba__m2 LIKE 'NULL'
      THEN NULL
    ELSE REPLACE(p__rdot___aug__u_d__rzu_plat__ba__m2, ',', '.')::DECIMAL(10, 2)
    END
  ,CASE 
    WHEN p__rdot___p__avu_plat__ba__m2 LIKE 'NULL'
      THEN NULL
    ELSE REPLACE(p__rdot___p__avu_plat__ba__m2, ',', '.')::DECIMAL(10, 2)
    END
  ,CASE 
    WHEN p__rdot___gan__bu_plat__ba__m2 LIKE 'NULL'
      THEN NULL
    ELSE REPLACE(p__rdot___gan__bu_plat__ba__m2, ',', '.')::DECIMAL(10, 2)
    END
  ,CASE 
    WHEN p__rdot___melior__t__s_liz_plat__ba__m2 LIKE 'NULL'
      THEN NULL
    ELSE REPLACE(p__rdot___melior__t__s_liz_plat__ba__m2, ',', '.')::DECIMAL(10, 2)
    END
  ,CASE 
    WHEN p__rdot___me__u_zemes_plat__ba__m2 LIKE 'NULL'
      THEN NULL
    ELSE REPLACE(p__rdot___me__u_zemes_plat__ba__m2, ',', '.')::DECIMAL(10, 2)
    END
  ,CASE 
    WHEN p__rdot___kr__m__ju_plat__ba__m2 LIKE 'NULL'
      THEN NULL
    ELSE REPLACE(p__rdot___kr__m__ju_plat__ba__m2, ',', '.')::DECIMAL(10, 2)
    END
  ,CASE 
    WHEN p__rdot___purvu_plat__ba__m2 LIKE 'NULL'
      THEN NULL
    ELSE REPLACE(p__rdot___purvu_plat__ba__m2, ',', '.')::DECIMAL(10, 2)
    END
  ,CASE 
    WHEN p__rdot___zemes_zem___de__iem_plat__ba__m2 LIKE 'NULL'
      THEN NULL
    ELSE REPLACE(p__rdot___zemes_zem___de__iem_plat__ba__m2, ',', '.')::DECIMAL(10, 2)
    END
  ,CASE 
    WHEN p__rdot___zemes_zem_d____iem_plat__ba__m2 LIKE 'NULL'
      THEN NULL
    ELSE REPLACE(p__rdot___zemes_zem_d____iem_plat__ba__m2, ',', '.')::DECIMAL(10, 2)
    END
  ,CASE 
    WHEN p__rdot___zemes_zem___k__m_un_pagalmiem_plat__ba__m2 LIKE 'NULL'
      THEN NULL
    ELSE REPLACE(p__rdot___zemes_zem___k__m_un_pagalmiem_plat__ba__m2, ',', '.')::DECIMAL(10, 2)
    END
  ,CASE 
    WHEN p__rdot___zemes_zem_ce__iem_plat__ba__m2 LIKE 'NULL'
      THEN NULL
    ELSE REPLACE(p__rdot___zemes_zem_ce__iem_plat__ba__m2, ',', '.')::DECIMAL(10, 2)
    END
  ,CASE 
    WHEN p__rdot___p__r__j__s_zemes_plat__ba__m2 LIKE 'NULL'
      THEN NULL
    ELSE REPLACE(p__rdot___p__r__j__s_zemes_plat__ba__m2, ',', '.')::DECIMAL(10, 2)
    END
FROM vzd.zv a
INNER JOIN m ON a.filename = m.filename
  AND a.dar__juma_id = m.dar__juma_id
INNER JOIN nitis_zv_min_year my ON SUBSTRING(a.filename, strpos(a.filename, '.') - 4, 4)::SMALLINT = my.gads
  AND a.dar__juma_id::INT = my.darijuma_id
LEFT JOIN (
  SELECT *
  FROM csp.atu_nuts_codes
  WHERE validity_period_end LIKE ''
    AND level = '3'
  ) b ON a.pils__ta = b.name
LEFT JOIN (
  SELECT *
  FROM csp.atu_nuts_codes
  WHERE validity_period_end LIKE ''
    AND level = '3'
  ) c ON a.pagasts = REPLACE(c.name, 'pagasts', 'pag.')
  AND a.novads = REPLACE(c.name, 'novads', 'nov.')
LEFT JOIN (
  SELECT *
  FROM csp.atu_nuts_codes
  WHERE validity_period_end LIKE ''
    AND level = '3'
  ) c2 ON a.pagasts = REPLACE(c2.name, 'pagasts', 'pag.')
LEFT JOIN e ON a.novads = REPLACE(e.at_nosaukums, 'novads', 'nov.')
LEFT JOIN y ON a.dar__juma_id = y.darijuma_id
LEFT JOIN (
  SELECT DISTINCT darijuma_id
  FROM vzd.nitis_zv
  ) f ON a.dar__juma_id::INT = f.darijuma_id
WHERE f.darijuma_id IS NULL;

---nitis_zv_nilm.
INSERT INTO vzd.nitis_zv_nilm (
  darijuma_id
  ,kods
  ,platiba
  )
SELECT DISTINCT a.dar__juma_id::INT darijuma_id
  ,LPAD(SPLIT_PART(UNNEST(STRING_TO_ARRAY(REPLACE(a.n__lm_kodi_saraksts_, ' ', ''), ',')), '(', 1), 4, '0000') kods
  ,REPLACE(SPLIT_PART(UNNEST(STRING_TO_ARRAY(REPLACE(a.n__lm_kodi_saraksts_, ' ', ''), ',')), '(', 2), ')', '')::INT platiba
FROM vzd.zv a
LEFT JOIN (
  SELECT DISTINCT darijuma_id
  FROM vzd.nitis_zv_nilm
  ) f ON a.dar__juma_id::INT = f.darijuma_id
WHERE f.darijuma_id IS NULL
  AND a.n__lm_kodi_saraksts_ NOT LIKE 'NULL'
ORDER BY a.dar__juma_id::INT;

---nitis_zv_kad_apz.
INSERT INTO vzd.nitis_zv_kad_apz (
  darijuma_id
  ,kad_apz
  )
SELECT DISTINCT a.dar__juma_id::INT
  ,UNNEST(STRING_TO_ARRAY(REPLACE(a.zemes_vien__bu_kadastra_apz__m__jumu_saraksts__viena_dar__juma_, ' ', ''), ',')) kad_apz
FROM vzd.zv a
LEFT JOIN (
  SELECT DISTINCT darijuma_id
  FROM vzd.nitis_zv_kad_apz
  ) f ON a.dar__juma_id::INT = f.darijuma_id
WHERE f.darijuma_id IS NULL
ORDER BY a.dar__juma_id::INT;

--ZVB.
CREATE TEMPORARY TABLE nitis_zvb_min_year AS
SELECT MIN(SUBSTRING(filename, strpos(filename, '.') - 4, 4)::SMALLINT) gads
  ,dar__juma_id::INT darijuma_id
FROM vzd.zvb
GROUP BY dar__juma_id;

---nitis_zvb.
INSERT INTO vzd.nitis_zvb (
  gads
  ,darijuma_id
  ,darijuma_datums
  ,objekts
  ,kadastra_nr
  ,adrese
  ,atvk
  ,darijuma_summa
  ,zemes_skaititajs
  ,zemes_saucejs
  ,kopplatiba
  --,lauksaimniecibas_zeme
  ,aramzeme
  ,auglu_darzi
  ,plavas
  ,ganibas
  ,melioreta_liz
  ,mezi
  ,krumaji
  ,purvi
  ,zem_udeniem
  ,zem_dikiem
  ,zem_ekam_un_pagalmiem
  ,zem_celiem
  ,pareja_zeme
  )
WITH m
AS (
  SELECT dar__juma_id
    ,MIN(filename) filename
  FROM vzd.zv
  GROUP BY dar__juma_id
  )
  ,d
AS (
  SELECT at_kods
    ,COUNT(*) cnt
  FROM csp.atvk_2022_parejas_tabula
  GROUP BY at_kods
  )
  ,e
AS (
  SELECT b.*
  FROM d
  INNER JOIN csp.atvk_2022_parejas_tabula b ON d.at_kods = b.at_kods
  WHERE d.cnt = 1
  )
SELECT DISTINCT SUBSTRING(a.filename, strpos(a.filename, '.') - 4, 4)::SMALLINT
  ,a.dar__juma_id::INT
  ,to_date(dar__juma_datums, 'dd.mm.yyy')::DATE
  ,k.id
  ,__pa__uma_kadastra_numurs
  ,adreses_pieraksts
  ,CASE 
    WHEN b.code IS NOT NULL
      THEN b.code
    WHEN c.code IS NOT NULL
      THEN c.code
    WHEN c2.code IS NOT NULL
      THEN c2.code
    WHEN e.tv2022_kods IS NOT NULL
      THEN e.tv2022_kods
    ELSE NULL
    END
  ,REPLACE(dar__juma_summa__eur, ',', '.')::DECIMAL(10, 2)
  ,CASE 
    WHEN zemes_da__as__skait__t__js_ LIKE 'NULL'
      THEN NULL
    ELSE zemes_da__as__skait__t__js_::BIGINT
    END
  ,CASE 
    WHEN zemes_da__as__sauc__js_ LIKE 'NULL'
      THEN NULL
    ELSE zemes_da__as__sauc__js_::BIGINT
    END
  ,CASE 
    WHEN p__rdot___zemes_kopplat__ba__m2 LIKE 'NULL'
      THEN NULL
    ELSE REPLACE(p__rdot___zemes_kopplat__ba__m2, ',', '.')::DECIMAL(10, 2)
    END
  /*,CASE 
    WHEN p__rdot___lauksaimniec__bas_zemes_plat__ba__m2 LIKE 'NULL'
      THEN NULL
    ELSE REPLACE(p__rdot___lauksaimniec__bas_zemes_plat__ba__m2, ',', '.')::DECIMAL(10, 2)
    END*/
  ,CASE 
    WHEN p__rdot___aramzemes_plat__ba__m2 LIKE 'NULL'
      THEN NULL
    ELSE REPLACE(p__rdot___aramzemes_plat__ba__m2, ',', '.')::DECIMAL(10, 2)
    END
  ,CASE 
    WHEN p__rdot___aug__u_d__rzu_plat__ba__m2 LIKE 'NULL'
      THEN NULL
    ELSE REPLACE(p__rdot___aug__u_d__rzu_plat__ba__m2, ',', '.')::DECIMAL(10, 2)
    END
  ,CASE 
    WHEN p__rdot___p__avu_plat__ba__m2 LIKE 'NULL'
      THEN NULL
    ELSE REPLACE(p__rdot___p__avu_plat__ba__m2, ',', '.')::DECIMAL(10, 2)
    END
  ,CASE 
    WHEN p__rdot___gan__bu_plat__ba__m2 LIKE 'NULL'
      THEN NULL
    ELSE REPLACE(p__rdot___gan__bu_plat__ba__m2, ',', '.')::DECIMAL(10, 2)
    END
  ,CASE 
    WHEN p__rdot___melior__t__s_liz_plat__ba__m2 LIKE 'NULL'
      THEN NULL
    ELSE REPLACE(p__rdot___melior__t__s_liz_plat__ba__m2, ',', '.')::DECIMAL(10, 2)
    END
  ,CASE 
    WHEN p__rdot___me__u_zemes_plat__ba__m2 LIKE 'NULL'
      THEN NULL
    ELSE REPLACE(p__rdot___me__u_zemes_plat__ba__m2, ',', '.')::DECIMAL(10, 2)
    END
  ,CASE 
    WHEN p__rdot___kr__m__ju_plat__ba__m2 LIKE 'NULL'
      THEN NULL
    ELSE REPLACE(p__rdot___kr__m__ju_plat__ba__m2, ',', '.')::DECIMAL(10, 2)
    END
  ,CASE 
    WHEN p__rdot___purvu_plat__ba__m2 LIKE 'NULL'
      THEN NULL
    ELSE REPLACE(p__rdot___purvu_plat__ba__m2, ',', '.')::DECIMAL(10, 2)
    END
  ,CASE 
    WHEN p__rdot___zemes_zem___de__iem_plat__ba__m2 LIKE 'NULL'
      THEN NULL
    ELSE REPLACE(p__rdot___zemes_zem___de__iem_plat__ba__m2, ',', '.')::DECIMAL(10, 2)
    END
  ,CASE 
    WHEN p__rdot___zemes_zem_d____iem_plat__ba__m2 LIKE 'NULL'
      THEN NULL
    ELSE REPLACE(p__rdot___zemes_zem_d____iem_plat__ba__m2, ',', '.')::DECIMAL(10, 2)
    END
  ,CASE 
    WHEN p__rdot___zemes_zem___k__m_un_pagalmiem_plat__ba__m2 LIKE 'NULL'
      THEN NULL
    ELSE REPLACE(p__rdot___zemes_zem___k__m_un_pagalmiem_plat__ba__m2, ',', '.')::DECIMAL(10, 2)
    END
  ,CASE 
    WHEN p__rdot___zemes_zem_ce__iem_plat__ba__m2 LIKE 'NULL'
      THEN NULL
    ELSE REPLACE(p__rdot___zemes_zem_ce__iem_plat__ba__m2, ',', '.')::DECIMAL(10, 2)
    END
  ,CASE 
    WHEN p__rdot___p__r__j__s_zemes_plat__ba__m2 LIKE 'NULL'
      THEN NULL
    ELSE REPLACE(p__rdot___p__r__j__s_zemes_plat__ba__m2, ',', '.')::DECIMAL(10, 2)
    END
FROM vzd.zvb a
INNER JOIN m ON a.filename = m.filename
  AND a.dar__juma_id = m.dar__juma_id
INNER JOIN nitis_zvb_min_year my ON SUBSTRING(a.filename, strpos(a.filename, '.') - 4, 4)::SMALLINT = my.gads
  AND a.dar__juma_id::INT = my.darijuma_id
INNER JOIN vzd.nitis_k_objekti k ON a.objekts = k.nosaukums
LEFT JOIN (
  SELECT *
  FROM csp.atu_nuts_codes
  WHERE validity_period_end LIKE ''
    AND level = '3'
  ) b ON a.pils__ta = b.name
LEFT JOIN (
  SELECT *
  FROM csp.atu_nuts_codes
  WHERE validity_period_end LIKE ''
    AND level = '3'
  ) c ON a.pagasts = REPLACE(c.name, 'pagasts', 'pag.')
  AND a.novads = REPLACE(c.name, 'novads', 'nov.')
LEFT JOIN (
  SELECT *
  FROM csp.atu_nuts_codes
  WHERE validity_period_end LIKE ''
    AND level = '3'
  ) c2 ON a.pagasts = REPLACE(c2.name, 'pagasts', 'pag.')
LEFT JOIN e ON a.novads = REPLACE(e.at_nosaukums, 'novads', 'nov.')
LEFT JOIN (
  SELECT DISTINCT darijuma_id
  FROM vzd.nitis_zvb
  ) f ON a.dar__juma_id::INT = f.darijuma_id
WHERE f.darijuma_id IS NULL
  AND a.objekts NOT IN (
    'Inženierbūves'
    ,'Ēkas'
    ,'Ēkas un inženierbūves'
    );

---nitis_zv_nilm.
INSERT INTO vzd.nitis_zv_nilm (
  darijuma_id
  ,kods
  ,platiba
  )
SELECT DISTINCT a.dar__juma_id::INT darijuma_id
  ,LPAD(SPLIT_PART(UNNEST(STRING_TO_ARRAY(REPLACE(a.n__lm_kodi_saraksts_, ' ', ''), ',')), '(', 1), 4, '0000') kods
  ,REPLACE(SPLIT_PART(UNNEST(STRING_TO_ARRAY(REPLACE(a.n__lm_kodi_saraksts_, ' ', ''), ',')), '(', 2), ')', '')::INT platiba
FROM vzd.zvb a
LEFT JOIN (
  SELECT DISTINCT darijuma_id
  FROM vzd.nitis_zv_nilm
  ) f ON a.dar__juma_id::INT = f.darijuma_id
WHERE f.darijuma_id IS NULL
  AND a.n__lm_kodi_saraksts_ NOT LIKE 'NULL'
ORDER BY a.dar__juma_id::INT;

---nitis_zv_kad_apz.
INSERT INTO vzd.nitis_zv_kad_apz (
  darijuma_id
  ,kad_apz
  )
SELECT DISTINCT a.dar__juma_id::INT
  ,UNNEST(STRING_TO_ARRAY(REPLACE(a.zemes_vien__bu_kadastra_apz__m__jumu_saraksts__viena_dar__juma_, ' ', ''), ',')) kad_apz
FROM vzd.zvb a
LEFT JOIN (
  SELECT DISTINCT darijuma_id
  FROM vzd.nitis_zv_kad_apz
  ) f ON a.dar__juma_id::INT = f.darijuma_id
WHERE f.darijuma_id IS NULL
  AND a.zemes_vien__bu_kadastra_apz__m__jumu_saraksts__viena_dar__juma_ NOT LIKE 'NULL'
ORDER BY a.dar__juma_id::INT;

---nitis_b.
INSERT INTO vzd.nitis_b (
  gads
  ,darijuma_id
  ,darijuma_datums
  ,objekts
  ,kadastra_nr
  ,adrese
  ,atvk
  ,darijuma_summa
  )
WITH m
AS (
  SELECT dar__juma_id
    ,MIN(filename) filename
  FROM vzd.zv
  GROUP BY dar__juma_id
  )
  ,d
AS (
  SELECT at_kods
    ,COUNT(*) cnt
  FROM csp.atvk_2022_parejas_tabula
  GROUP BY at_kods
  )
  ,e
AS (
  SELECT b.*
  FROM d
  INNER JOIN csp.atvk_2022_parejas_tabula b ON d.at_kods = b.at_kods
  WHERE d.cnt = 1
  )
SELECT DISTINCT SUBSTRING(a.filename, strpos(a.filename, '.') - 4, 4)::SMALLINT
  ,a.dar__juma_id::INT
  ,to_date(dar__juma_datums, 'dd.mm.yyy')::DATE
  ,k.id
  ,__pa__uma_kadastra_numurs
  ,adreses_pieraksts
  ,CASE 
    WHEN b.code IS NOT NULL
      THEN b.code
    WHEN c.code IS NOT NULL
      THEN c.code
    WHEN c2.code IS NOT NULL
      THEN c2.code
    WHEN e.tv2022_kods IS NOT NULL
      THEN e.tv2022_kods
    ELSE NULL
    END
  ,REPLACE(dar__juma_summa__eur, ',', '.')::DECIMAL(10, 2)
FROM vzd.zvb a
INNER JOIN m ON a.filename = m.filename
  AND a.dar__juma_id = m.dar__juma_id
INNER JOIN nitis_zvb_min_year my ON SUBSTRING(a.filename, strpos(a.filename, '.') - 4, 4)::SMALLINT = my.gads
  AND a.dar__juma_id::INT = my.darijuma_id
INNER JOIN vzd.nitis_k_objekti k ON a.objekts = k.nosaukums
LEFT JOIN (
  SELECT *
  FROM csp.atu_nuts_codes
  WHERE validity_period_end LIKE ''
    AND level = '3'
  ) b ON a.pils__ta = b.name
LEFT JOIN (
  SELECT *
  FROM csp.atu_nuts_codes
  WHERE validity_period_end LIKE ''
    AND level = '3'
  ) c ON a.pagasts = REPLACE(c.name, 'pagasts', 'pag.')
  AND a.novads = REPLACE(c.name, 'novads', 'nov.')
LEFT JOIN (
  SELECT *
  FROM csp.atu_nuts_codes
  WHERE validity_period_end LIKE ''
    AND level = '3'
  ) c2 ON a.pagasts = REPLACE(c2.name, 'pagasts', 'pag.')
LEFT JOIN e ON a.novads = REPLACE(e.at_nosaukums, 'novads', 'nov.')
LEFT JOIN (
  SELECT DISTINCT darijuma_id
  FROM vzd.nitis_b
  ) f ON a.dar__juma_id::INT = f.darijuma_id
WHERE f.darijuma_id IS NULL
  AND a.objekts IN (
    'Inženierbūves'
    ,'Ēkas'
    ,'Ēkas un inženierbūves'
    );

--TG.
---nitis_tg.
CREATE TEMPORARY TABLE IF NOT EXISTS nitis_tg_tmp (
  id serial PRIMARY KEY
  ,gads SMALLINT NOT NULL
  ,darijuma_id INT NOT NULL
  ,darijuma_datums DATE NOT NULL
  ,objekts INT NOT NULL
  ,kadastra_nr VARCHAR(11) NOT NULL
  ,adrese TEXT NOT NULL
  ,atvk VARCHAR(7) NULL
  ,darijuma_summa DECIMAL(10, 2) NOT NULL
  ,zemes_skaititajs BIGINT NULL
  ,zemes_saucejs BIGINT NULL
  ,zemes_kopplatiba DECIMAL(10, 2) NULL
  ,buves_kad_apz TEXT[] NOT NULL
  );

INSERT INTO nitis_tg_tmp (
  gads
  ,darijuma_id
  ,darijuma_datums
  ,objekts
  ,kadastra_nr
  ,adrese
  ,atvk
  ,darijuma_summa
  ,zemes_skaititajs
  ,zemes_saucejs
  ,zemes_kopplatiba
  ,buves_kad_apz
  )
WITH d AS (
    SELECT at_kods
      ,COUNT(*) cnt
    FROM csp.atvk_2022_parejas_tabula
    GROUP BY at_kods
    )
  ,e AS (
    SELECT b.*
    FROM d
    INNER JOIN csp.atvk_2022_parejas_tabula b ON d.at_kods = b.at_kods
    WHERE d.cnt = 1
    )
SELECT DISTINCT SUBSTRING(filename, strpos(filename, '.') - 4, 4)::SMALLINT
  ,dar__juma_id::INT
  ,to_date(dar__juma_datums, 'dd.mm.yyy')::DATE
  ,k.id
  ,__pa__uma_kadastra_numurs
  ,adreses_pieraksts
  ,CASE 
    WHEN b.code IS NOT NULL
      THEN b.code
    WHEN c.code IS NOT NULL
      THEN c.code
    WHEN c2.code IS NOT NULL
      THEN c2.code
    WHEN e.tv2022_kods IS NOT NULL
      THEN e.tv2022_kods
    ELSE NULL
    END
  ,REPLACE(dar__juma_summa__eur, ',', '.')::DECIMAL(10, 2)
  ,CASE 
    WHEN zemes_da__as_skait__t__js_ LIKE 'NULL'
      THEN NULL
    ELSE zemes_da__as_skait__t__js_::BIGINT
    END
  ,CASE 
    WHEN zemes_da__as_sauc__js_ LIKE 'NULL'
      THEN NULL
    ELSE REPLACE(zemes_da__as_sauc__js_, ',', '.')::DECIMAL(38, 0)::BIGINT
    END
  ,CASE 
    WHEN p__rdot___zemes_kopplat__ba__m2 LIKE 'NULL'
      THEN NULL
    ELSE REPLACE(p__rdot___zemes_kopplat__ba__m2, ',', '.')::DECIMAL(10, 2)
    END
  ,STRING_TO_ARRAY(b__ves_kadastra_apz__m__jumu_saraksts__viena_dar__juma_ietvaros, ', ')
FROM vzd.tg a
INNER JOIN vzd.nitis_k_objekti k ON a.objekts = k.nosaukums
LEFT JOIN (
  SELECT *
  FROM csp.atu_nuts_codes
  WHERE validity_period_end LIKE ''
    AND level = '3'
  ) b ON a.pils__ta = b.name
LEFT JOIN (
  SELECT *
  FROM csp.atu_nuts_codes
  WHERE validity_period_end LIKE ''
    AND level = '3'
  ) c ON a.pagasts = REPLACE(c.name, 'pagasts', 'pag.')
  AND a.novads = REPLACE(c.name, 'novads', 'nov.')
LEFT JOIN (
  SELECT *
  FROM csp.atu_nuts_codes
  WHERE validity_period_end LIKE ''
    AND level = '3'
  ) c2 ON a.pagasts = REPLACE(c2.name, 'pagasts', 'pag.')
LEFT JOIN e ON a.novads = REPLACE(e.at_nosaukums, 'novads', 'nov.')
LEFT JOIN (
  SELECT DISTINCT darijuma_id
  FROM vzd.nitis_tg
  ) f ON a.dar__juma_id::INT = f.darijuma_id
WHERE f.darijuma_id IS NULL;

WITH c
AS (
  SELECT MIN(gads) gads
    ,darijuma_id
  FROM nitis_tg_tmp
  GROUP BY darijuma_id
  )
DELETE
FROM nitis_tg_tmp
USING nitis_tg_tmp a
LEFT JOIN c ON a.gads = c.gads
  AND a.darijuma_id = c.darijuma_id
WHERE nitis_tg_tmp.id = a.id
  AND c.darijuma_id IS NULL;

WITH c
AS (
  SELECT id
    ,LPAD(UNNEST(buves_kad_apz), 14, '00000000000000') buves_kad_apz
  FROM nitis_tg_tmp
  )
INSERT INTO vzd.nitis_tg (
  gads
  ,darijuma_id
  ,darijuma_datums
  ,objekts
  ,kadastra_nr
  ,adrese
  ,atvk
  ,darijuma_summa
  ,zemes_skaititajs
  ,zemes_saucejs
  ,zemes_kopplatiba
  ,buves_kad_apz
  )
SELECT gads
  ,darijuma_id
  ,darijuma_datums
  ,objekts
  ,kadastra_nr
  ,adrese
  ,atvk
  ,darijuma_summa
  ,zemes_skaititajs
  ,zemes_saucejs
  ,zemes_kopplatiba
  ,ARRAY_AGG(c.buves_kad_apz) buves_kad_apz
FROM nitis_tg_tmp a
INNER JOIN c ON a.id = c.id
GROUP BY gads
  ,darijuma_id
  ,darijuma_datums
  ,objekts
  ,kadastra_nr
  ,adrese
  ,atvk
  ,darijuma_summa
  ,zemes_skaititajs
  ,zemes_saucejs
  ,zemes_kopplatiba;

---nitis_zv_kad_apz.
INSERT INTO vzd.nitis_zv_kad_apz (
  darijuma_id
  ,kad_apz
  )
SELECT DISTINCT dar__juma_id::INT
  ,UNNEST(STRING_TO_ARRAY(REPLACE(zemes_vien__bu_kadastra_apz__m__jumi_saraksts___viena_dar__juma, ' ', ''), ',')) kad_apz
FROM vzd.tg a
LEFT JOIN vzd.nitis_zv_kad_apz b ON a.dar__juma_id::INT = b.darijuma_id
WHERE zemes_vien__bu_kadastra_apz__m__jumi_saraksts___viena_dar__juma NOT LIKE 'NULL'
  AND b.darijuma_id IS NULL
ORDER BY dar__juma_id::INT;

---Labo pierakstu.
UPDATE vzd.nitis_zv_kad_apz
SET kad_apz = LPAD(kad_apz, 11, '00000000000')
WHERE LENGTH(kad_apz) < 11;

---nitis_zv_nilm.
INSERT INTO vzd.nitis_zv_nilm (
  darijuma_id
  ,kods
  ,platiba
  )
SELECT DISTINCT dar__juma_id::INT darijuma_id
  ,LPAD(SPLIT_PART(UNNEST(STRING_TO_ARRAY(REPLACE(n__lm_kodi_saraksts_, ' ', ''), ',')), '(', 1), 4, '0000') kods
  ,REPLACE(SPLIT_PART(UNNEST(STRING_TO_ARRAY(REPLACE(n__lm_kodi_saraksts_, ' ', ''), ',')), '(', 2), ')', '')::INT platiba
FROM vzd.tg a
LEFT JOIN vzd.nitis_zv_nilm b ON a.dar__juma_id::INT = b.darijuma_id
WHERE n__lm_kodi_saraksts_ NOT LIKE 'NULL'
  AND b.darijuma_id IS NULL
ORDER BY dar__juma_id::INT;

--B_KAD_APZ.
CREATE TEMPORARY TABLE IF NOT EXISTS nitis_b_kad_apz_tmp (
  id serial PRIMARY KEY
  ,darijuma_id INT NOT NULL
  ,kad_apz VARCHAR(14) NOT NULL
  ,skaititajs BIGINT NULL
  ,saucejs BIGINT NULL
  ,liet_veids SMALLINT NULL
  ,stavi SMALLINT NULL
  ,apbuves_laukums DECIMAL(7, 1) NULL
  ,kopplatiba DECIMAL(7, 1) NULL
  ,buvtilpums INT NULL
  ,ekspl_gads SMALLINT[] NULL
  ,arsienas TEXT[] NULL
  ,nolietojums SMALLINT NULL
  );

----zvb.
INSERT INTO nitis_b_kad_apz_tmp (
  darijuma_id
  ,kad_apz
  ,skaititajs
  ,saucejs
  ,liet_veids
  ,stavi
  ,apbuves_laukums
  ,kopplatiba
  ,buvtilpums
  ,ekspl_gads
  ,arsienas
  ,nolietojums
  )
SELECT a.dar__juma_id::INT
  ,a.b__ves_kadastra_apz__m__jums
  ,CASE 
    WHEN a.b__ves_da__as__skait__t__js LIKE 'NULL'
      THEN NULL
    ELSE a.b__ves_da__as__skait__t__js::BIGINT
    END
  ,CASE 
    WHEN a.b__ves_da__as__sauc__js LIKE 'NULL'
      THEN NULL
    ELSE REPLACE(a.b__ves_da__as__sauc__js, ',', '.')::DECIMAL(38, 0)::BIGINT
    END
  ,CASE 
    WHEN a.b__ves_lieto__anas_veida_kods LIKE 'NULL'
      THEN NULL
    ELSE a.b__ves_lieto__anas_veida_kods::SMALLINT
    END
  ,CASE 
    WHEN a.b__ves_virszemes_st__vu_skaits LIKE 'NULL'
      THEN NULL
    ELSE a.b__ves_virszemes_st__vu_skaits::SMALLINT
    END
  ,CASE 
    WHEN a.b__ves_apb__ves_laukums__m2 LIKE 'NULL'
      THEN NULL
    ELSE REPLACE(a.b__ves_apb__ves_laukums__m2, ',', '.')::DECIMAL(7, 1)
    END
  ,CASE 
    WHEN a.b__ves_kopplat__ba__m2 LIKE 'NULL'
      THEN NULL
    ELSE REPLACE(a.b__ves_kopplat__ba__m2, ',', '.')::DECIMAL(7, 1)
    END
  ,CASE 
    WHEN a.b__ves_b__vtilpums__m3 LIKE 'NULL'
      THEN NULL
    ELSE a.b__ves_b__vtilpums__m3::INT
    END
  ,CASE 
    WHEN a.b__ves_ekspluat__cijas_uzs__k__anas_gads LIKE 'NULL'
      THEN NULL
    ELSE STRING_TO_ARRAY(REPLACE(a.b__ves_ekspluat__cijas_uzs__k__anas_gads, ' ', ''), ',')::SMALLINT []
    END
  ,CASE 
    WHEN a.b__ves___rsienu_materi__la_nosaukums LIKE 'NULL'
      THEN NULL
    WHEN a.b__ves___rsienu_materi__la_nosaukums LIKE '% - %'
      THEN REGEXP_SPLIT_TO_ARRAY(a.b__ves___rsienu_materi__la_nosaukums, ', [0-9]')
    ELSE REGEXP_SPLIT_TO_ARRAY(a.b__ves___rsienu_materi__la_nosaukums, ', ')
    END
  ,CASE 
    WHEN a.b__ves_fiziskais_nolietojums___ LIKE 'NULL'
      THEN NULL
    ELSE a.b__ves_fiziskais_nolietojums___::SMALLINT
    END
FROM vzd.zvb a
LEFT JOIN (
  SELECT DISTINCT darijuma_id
  FROM vzd.nitis_b_kad_apz
  ) f ON a.dar__juma_id::INT = f.darijuma_id
WHERE f.darijuma_id IS NULL;

----tg.
INSERT INTO nitis_b_kad_apz_tmp (
  darijuma_id
  ,kad_apz
  ,skaititajs
  ,saucejs
  ,liet_veids
  ,stavi
  ,apbuves_laukums
  ,kopplatiba
  ,buvtilpums
  ,ekspl_gads
  ,arsienas
  ,nolietojums
  )
SELECT DISTINCT a.dar__juma_id::INT
  ,a.b__ves_kadastra_apz__m__jums
  ,a.b__ves_da__as_skait__t__js_::BIGINT
  ,REPLACE(a.b__ves_da__as_sauc__js_, ',', '.')::DECIMAL(38, 0)::BIGINT
  ,CASE 
    WHEN a.b__ves_lieto__anas_veida_kods LIKE 'NULL'
      THEN NULL
    ELSE a.b__ves_lieto__anas_veida_kods::SMALLINT
    END
  ,CASE 
    WHEN a.b__ves_virszemes_st__vu_skaits LIKE 'NULL'
      THEN NULL
    ELSE a.b__ves_virszemes_st__vu_skaits::SMALLINT
    END
  ,CASE 
    WHEN a.b__ves_apb__ves_laukums__m2 LIKE 'NULL'
      THEN NULL
    ELSE REPLACE(a.b__ves_apb__ves_laukums__m2, ',', '.')::DECIMAL(7, 1)
    END
  ,CASE 
    WHEN a.b__ves_kopplat__ba__m2 LIKE 'NULL'
      THEN NULL
    ELSE REPLACE(a.b__ves_kopplat__ba__m2, ',', '.')::DECIMAL(7, 1)
    END
  ,CASE 
    WHEN a.b__ves_b__vtilpums__m3 LIKE 'NULL'
      THEN NULL
    ELSE a.b__ves_b__vtilpums__m3::INT
    END
  ,CASE 
    WHEN a.b__ves_ekspluat__cijas_uzs__k__anas_gads LIKE 'NULL'
      THEN NULL
    ELSE STRING_TO_ARRAY(REPLACE(a.b__ves_ekspluat__cijas_uzs__k__anas_gads, ' ', ''), ',')::SMALLINT []
    END
  ,CASE 
    WHEN a.b__ves___rsienu_materi__la_nosaukums LIKE 'NULL'
      THEN NULL
    WHEN a.b__ves___rsienu_materi__la_nosaukums LIKE '% - %'
      THEN REGEXP_SPLIT_TO_ARRAY(a.b__ves___rsienu_materi__la_nosaukums, ', [0-9]')
    ELSE REGEXP_SPLIT_TO_ARRAY(a.b__ves___rsienu_materi__la_nosaukums, ', ')
    END
  ,CASE 
    WHEN a.b__ves_fiziskais_nolietojums___ LIKE 'NULL'
      THEN NULL
    ELSE a.b__ves_fiziskais_nolietojums___::SMALLINT
    END
FROM vzd.tg a
LEFT JOIN (
  SELECT DISTINCT darijuma_id
  FROM vzd.nitis_b_kad_apz
  ) f ON a.dar__juma_id::INT = f.darijuma_id
WHERE f.darijuma_id IS NULL;

UPDATE nitis_b_kad_apz_tmp
SET liet_veids = NULL
WHERE liet_veids = 0;

---Dzēš kļūdainus ierakstus kolonnā ekspl_gads.
WITH a
AS (
  SELECT DISTINCT id
    ,UNNEST(ekspl_gads) ekspl_gads
  FROM nitis_b_kad_apz_tmp
  )
  ,b
AS (
  SELECT id
    ,ARRAY_AGG(ekspl_gads) ekspl_gads
  FROM a
  WHERE ekspl_gads < 1600
  GROUP BY id
  )
UPDATE nitis_b_kad_apz_tmp
SET ekspl_gads = ARRAY(SELECT UNNEST(nitis_b_kad_apz_tmp.ekspl_gads)
                       EXCEPT
                         SELECT UNNEST(b.ekspl_gads))
FROM b
WHERE nitis_b_kad_apz_tmp.id = b.id;

---Aizstāj ārsienu materiālu tikai ar kodu.
----Norādīts kods un nosaukums.
WITH a
AS (
  SELECT darijuma_id
    ,kad_apz
    ,skaititajs
    ,saucejs
    ,liet_veids
    ,stavi
    ,apbuves_laukums
    ,kopplatiba
    ,buvtilpums
    ,ekspl_gads
    ,SPLIT_PART(UNNEST(arsienas), ' - ', 2) arsienas
    ,nolietojums
  FROM nitis_b_kad_apz_tmp
  WHERE arsienas::TEXT LIKE '% - %'
  )
INSERT INTO vzd.nitis_b_kad_apz (
  darijuma_id
  ,kad_apz
  ,skaititajs
  ,saucejs
  ,liet_veids
  ,stavi
  ,apbuves_laukums
  ,kopplatiba
  ,buvtilpums
  ,ekspl_gads
  ,arsienas
  ,nolietojums
  )
SELECT darijuma_id
  ,kad_apz
  ,skaititajs
  ,saucejs
  ,liet_veids
  ,stavi
  ,apbuves_laukums
  ,kopplatiba
  ,buvtilpums
  ,ekspl_gads
  ,ARRAY_AGG(m.kods)::SMALLINT []
  ,nolietojums
FROM a
INNER JOIN vzd.nitis_k_materiali m ON a.arsienas = m.nosaukums
GROUP BY darijuma_id
  ,kad_apz
  ,skaititajs
  ,saucejs
  ,liet_veids
  ,stavi
  ,apbuves_laukums
  ,kopplatiba
  ,buvtilpums
  ,ekspl_gads
  ,nolietojums;

----Norādīts nosaukums.
WITH a
AS (
  SELECT darijuma_id
    ,kad_apz
    ,skaititajs
    ,saucejs
    ,liet_veids
    ,stavi
    ,apbuves_laukums
    ,kopplatiba
    ,buvtilpums
    ,ekspl_gads
    ,UNNEST(arsienas) arsienas
    ,nolietojums
  FROM nitis_b_kad_apz_tmp
  WHERE arsienas::TEXT !~ '[0-9]'
  )
INSERT INTO vzd.nitis_b_kad_apz (
  darijuma_id
  ,kad_apz
  ,skaititajs
  ,saucejs
  ,liet_veids
  ,stavi
  ,apbuves_laukums
  ,kopplatiba
  ,buvtilpums
  ,ekspl_gads
  ,arsienas
  ,nolietojums
  )
SELECT darijuma_id
  ,kad_apz
  ,skaititajs
  ,saucejs
  ,liet_veids
  ,stavi
  ,apbuves_laukums
  ,kopplatiba
  ,buvtilpums
  ,ekspl_gads
  ,ARRAY_AGG(m.kods)::SMALLINT []
  ,nolietojums
FROM a
INNER JOIN vzd.nitis_k_materiali m ON a.arsienas = m.nosaukums
GROUP BY darijuma_id
  ,kad_apz
  ,skaititajs
  ,saucejs
  ,liet_veids
  ,stavi
  ,apbuves_laukums
  ,kopplatiba
  ,buvtilpums
  ,ekspl_gads
  ,nolietojums;

----Nav norādīts vispār.
INSERT INTO vzd.nitis_b_kad_apz (
  darijuma_id
  ,kad_apz
  ,skaititajs
  ,saucejs
  ,liet_veids
  ,stavi
  ,apbuves_laukums
  ,kopplatiba
  ,buvtilpums
  ,ekspl_gads
  ,arsienas
  ,nolietojums
  )
SELECT darijuma_id
  ,kad_apz
  ,skaititajs
  ,saucejs
  ,liet_veids
  ,stavi
  ,apbuves_laukums
  ,kopplatiba
  ,buvtilpums
  ,ekspl_gads
  ,arsienas::SMALLINT []
  ,nolietojums
FROM nitis_b_kad_apz_tmp
WHERE arsienas IS NULL;

--TG_KAD_APZ.
INSERT INTO vzd.nitis_tg_kad_apz (
  darijuma_id
  ,buves_kad_apz
  ,kad_apz
  ,skaititajs
  ,saucejs
  ,liet_veids
  ,stavs_min
  ,stavs_max
  ,platiba
  ,platiba_dz
  ,telpas
  ,istabas
  )
SELECT DISTINCT a.dar__juma_id::INT
  ,a.b__ves_kadastra_apz__m__jums
  ,a.telpu_grupas_kadastra_apz__m__jums
  ,a.telpu_grupas_da__as_skait__t__js_::BIGINT
  ,a.telpu_grupas_da__as_sauc__js_::BIGINT
  ,a.telpu_grupas_lieto__anas_veida_kods::SMALLINT
  ,CASE 
    WHEN a.telpu_grupas_zem__kais_st__vs LIKE 'NULL'
      THEN NULL
    ELSE a.telpu_grupas_zem__kais_st__vs::SMALLINT
    END
  ,CASE 
    WHEN a.telpu_grupas_augst__kais_st__vs LIKE 'NULL'
      THEN NULL
    ELSE a.telpu_grupas_augst__kais_st__vs::SMALLINT
    END
  ,REPLACE(a.telpu_grupas_plat__ba__m2, ',', '.')::DECIMAL(6, 1)
  ,CASE 
    WHEN a.dz__vok__a_kopplat__ba__m2 LIKE 'NULL'
      OR a.dz__vok__a_kopplat__ba__m2 LIKE '0'
      THEN NULL
    ELSE REPLACE(a.dz__vok__a_kopplat__ba__m2, ',', '.')::DECIMAL(6, 1)
    END
  ,CASE 
    WHEN a.telpu_skaits_telpu_grup__ LIKE 'NULL'
      THEN NULL
    ELSE a.telpu_skaits_telpu_grup__::SMALLINT
    END
  ,CASE 
    WHEN a.istabu_skaits_dz__vokl__ LIKE 'NULL'
      OR a.istabu_skaits_dz__vokl__ LIKE '0'
      THEN NULL
    ELSE a.istabu_skaits_dz__vokl__::SMALLINT
    END
FROM vzd.tg a
LEFT JOIN (
  SELECT DISTINCT darijuma_id
  FROM vzd.nitis_tg_kad_apz
  ) f ON a.dar__juma_id::INT = f.darijuma_id
WHERE f.darijuma_id IS NULL;

--Salabo ATVK, ja no pagasta izdalīta pilsēta.
---nitis_zv.
UPDATE vzd.nitis_zv
SET atvk = '0023200'
WHERE LOWER(adrese) LIKE '%ādaži%'
  AND atvk = '0023401';

UPDATE vzd.nitis_zv
SET atvk = '0025210'
WHERE LOWER(adrese) LIKE '%iecava,%'
  AND atvk = '0025460';

UPDATE vzd.nitis_zv
SET atvk = '0020220'
WHERE LOWER(adrese) LIKE '%koknese,%'
  AND atvk = '0020470';

UPDATE vzd.nitis_zv
SET atvk = '0034220'
WHERE LOWER(adrese) LIKE '%ķekava,%'
  AND atvk = '0034421';

UPDATE vzd.nitis_zv
SET atvk = '0039200'
WHERE LOWER(adrese) LIKE '% mārupe,%'
  AND atvk = '0039411';

---nitis_zvb.
UPDATE vzd.nitis_zvb
SET atvk = '0023200'
WHERE LOWER(adrese) LIKE '%ādaži%'
  AND atvk = '0023401';

UPDATE vzd.nitis_zvb
SET atvk = '0025210'
WHERE LOWER(adrese) LIKE '%iecava,%'
  AND atvk = '0025460';

UPDATE vzd.nitis_zvb
SET atvk = '0020220'
WHERE LOWER(adrese) LIKE '%koknese,%'
  AND atvk = '0020470';

UPDATE vzd.nitis_zvb
SET atvk = '0034220'
WHERE LOWER(adrese) LIKE '%ķekava,%'
  AND atvk = '0034421';

UPDATE vzd.nitis_zvb
SET atvk = '0039200'
WHERE LOWER(adrese) LIKE '% mārupe,%'
  AND atvk = '0039411';

---nitis_b.
UPDATE vzd.nitis_b
SET atvk = '0023200'
WHERE LOWER(adrese) LIKE '%ādaži%'
  AND atvk = '0023401';

UPDATE vzd.nitis_b
SET atvk = '0025210'
WHERE LOWER(adrese) LIKE '%iecava,%'
  AND atvk = '0025460';

UPDATE vzd.nitis_b
SET atvk = '0020220'
WHERE LOWER(adrese) LIKE '%koknese,%'
  AND atvk = '0020470';

UPDATE vzd.nitis_b
SET atvk = '0034220'
WHERE LOWER(adrese) LIKE '%ķekava,%'
  AND atvk = '0034421';

UPDATE vzd.nitis_b
SET atvk = '0039200'
WHERE LOWER(adrese) LIKE '% mārupe,%'
  AND atvk = '0039411';

END;
$BODY$;

GRANT EXECUTE ON PROCEDURE vzd.nitis() TO scheduler;