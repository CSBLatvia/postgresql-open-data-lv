CREATE OR REPLACE PROCEDURE mvr.mvr_proc(
	)
LANGUAGE 'plpgsql'

AS $BODY$BEGIN

--Poligoni, kas vairāk neeksistē vai kuriem veiktas izmaiņas kopš pēdējās atjaunināšanas.
UPDATE mvr.mvr_imported
SET date_deleted = CURRENT_DATE
FROM mvr.mvr_imported u
LEFT JOIN mvr.mvr s ON u.objectid = s.id::INT
  AND u.kadastrs = s.kadastrs
  AND COALESCE(u.gtf, 0) = COALESCE(s.gtf, 0)
  AND u.kvart = s.kvart::SMALLINT
  AND u.nog = s.nog::SMALLINT
  AND COALESCE(u.anog, 0) = COALESCE(s.anog::SMALLINT, 0)
  AND u.nog_plat = s.nog_plat
  AND COALESCE(u.expl_mezs, 0) = COALESCE(s.expl_mezs, 0)
  AND COALESCE(u.expl_celi, 0) = COALESCE(s.expl_celi, 0)
  AND COALESCE(u.expl_gravji, 0) = COALESCE(s.expl_gravj, 0)
  AND u.zkat = s.zkat::SMALLINT
  AND COALESCE(u.mt, 0) = COALESCE(s.mt::SMALLINT, 0)
  AND COALESCE(u.izc, 0) = COALESCE(s.izc::SMALLINT, 0)
  AND COALESCE(u.s10, 0) = COALESCE(s.s10::SMALLINT, 0)
  AND COALESCE(u.a10, 0) = COALESCE(s.a10, 0)
  AND COALESCE(u.h10, 0) = COALESCE(s.h10, 0)
  AND COALESCE(u.d10, 0) = COALESCE(s.d10, 0)
  AND COALESCE(u.g10, 0) = COALESCE(s.g10, 0)
  AND COALESCE(u.n10, 0) = COALESCE(s.n10, 0)
  AND COALESCE(u.bv10, 0) = COALESCE(s.bv10::SMALLINT, 0)
  AND COALESCE(u.ba10, 0) = COALESCE(s.ba10::SMALLINT, 0)
  AND COALESCE(u.s11, 0) = COALESCE(s.s11::SMALLINT, 0)
  AND COALESCE(u.a11, 0) = COALESCE(s.a11, 0)
  AND COALESCE(u.h11, 0) = COALESCE(s.h11, 0)
  AND COALESCE(u.d11, 0) = COALESCE(s.d11, 0)
  AND COALESCE(u.g11, 0) = COALESCE(s.g11, 0)
  AND COALESCE(u.n11, 0) = COALESCE(s.n11, 0)
  AND COALESCE(u.bv11, 0) = COALESCE(s.bv11::SMALLINT, 0)
  AND COALESCE(u.ba11, 0) = COALESCE(s.ba11::SMALLINT, 0)
  AND COALESCE(u.s12, 0) = COALESCE(s.s12::SMALLINT, 0)
  AND COALESCE(u.a12, 0) = COALESCE(s.a12, 0)
  AND COALESCE(u.h12, 0) = COALESCE(s.h12, 0)
  AND COALESCE(u.d12, 0) = COALESCE(s.d12, 0)
  AND COALESCE(u.g12, 0) = COALESCE(s.g12, 0)
  AND COALESCE(u.n12, 0) = COALESCE(s.n12, 0)
  AND COALESCE(u.bv12, 0) = COALESCE(s.bv12::SMALLINT, 0)
  AND COALESCE(u.ba12, 0) = COALESCE(s.ba12::SMALLINT, 0)
  AND COALESCE(u.s13, 0) = COALESCE(s.s13::SMALLINT, 0)
  AND COALESCE(u.a13, 0) = COALESCE(s.a13, 0)
  AND COALESCE(u.h13, 0) = COALESCE(s.h13, 0)
  AND COALESCE(u.d13, 0) = COALESCE(s.d13, 0)
  AND COALESCE(u.g13, 0) = COALESCE(s.g13, 0)
  AND COALESCE(u.n13, 0) = COALESCE(s.n13, 0)
  AND COALESCE(u.bv13, 0) = COALESCE(s.bv13::SMALLINT, 0)
  AND COALESCE(u.ba13, 0) = COALESCE(s.ba13::SMALLINT, 0)
  AND COALESCE(u.s14, 0) = COALESCE(s.s14::SMALLINT, 0)
  AND COALESCE(u.a14, 0) = COALESCE(s.a14, 0)
  AND COALESCE(u.h14, 0) = COALESCE(s.h14, 0)
  AND COALESCE(u.d14, 0) = COALESCE(s.d14, 0)
  AND COALESCE(u.g14, 0) = COALESCE(s.g14, 0)
  AND COALESCE(u.n14, 0) = COALESCE(s.n14, 0)
  AND COALESCE(u.bv14, 0) = COALESCE(s.bv14::SMALLINT, 0)
  AND COALESCE(u.ba14, 0) = COALESCE(s.ba14::SMALLINT, 0)
  AND COALESCE(u.jakopj, 0) = COALESCE(s.jakopj, 0)
  AND COALESCE(u.jaatjauno, 0) = COALESCE(s.jaatjauno, 0)
  AND COALESCE(u.p_darbv, 0) = COALESCE(s.p_darbv::SMALLINT, 0)
  AND COALESCE(u.p_darbg, 0) = COALESCE(s.p_darbg, 0)
  AND COALESCE(u.p_cirp, 0) = COALESCE(s.p_cirp::SMALLINT, 0)
  AND COALESCE(u.p_cirg, 0) = COALESCE(s.p_cirg, 0)
  AND COALESCE(u.atj_gads, 0) = COALESCE(s.atj_gads, 0)
  AND u.saimn_d_ierob = s.saimn_d_ie
  AND COALESCE(u.plant_audze, true) = COALESCE(s.plant_audz::BOOLEAN, true)
  AND u.forestry_c = s.forestry_c::SMALLINT
  AND u.vmd_headfo = s.vmd_headfo
  AND ST_Equals(ST_Multi(u.geom), s.geom)
WHERE s.fid IS NULL
  AND mvr.mvr_imported.date_deleted IS NULL
  AND mvr.mvr_imported.id = u.id;

--Jauni poligoni vai mainīti atribūti.
INSERT INTO mvr.mvr_imported (
  objectid
  ,kadastrs
  ,gtf
  ,kvart
  ,nog
  ,anog
  ,nog_plat
  ,expl_mezs
  ,expl_celi
  ,expl_gravji
  ,zkat
  ,mt
  ,izc
  ,s10
  ,a10
  ,h10
  ,d10
  ,g10
  ,n10
  ,bv10
  ,ba10
  ,s11
  ,a11
  ,h11
  ,d11
  ,g11
  ,n11
  ,bv11
  ,ba11
  ,s12
  ,a12
  ,h12
  ,d12
  ,g12
  ,n12
  ,bv12
  ,ba12
  ,s13
  ,a13
  ,h13
  ,d13
  ,g13
  ,n13
  ,bv13
  ,ba13
  ,s14
  ,a14
  ,h14
  ,d14
  ,g14
  ,n14
  ,bv14
  ,ba14
  ,jakopj
  ,jaatjauno
  ,p_darbv
  ,p_darbg
  ,p_cirp
  ,p_cirg
  ,atj_gads
  ,saimn_d_ierob
  ,plant_audze
  ,forestry_c
  ,vmd_headfo
  ,geom
  ,date_created
  )
SELECT s.id::INT --Aizstāj ar NULL 11-07-2022 datiem.
  ,s.kadastrs
  ,CASE 
    WHEN s.gtf = '0'
      THEN NULL
    ELSE s.gtf
    END
  ,s.kvart::SMALLINT
  ,s.nog::SMALLINT
  ,CASE 
    WHEN s.anog = '0'
      THEN NULL
    ELSE s.anog::SMALLINT
    END
  ,s.nog_plat
  ,CASE 
    WHEN s.expl_mezs = '0'
      THEN NULL
    ELSE s.expl_mezs
    END
  ,CASE 
    WHEN s.expl_celi = '0'
      THEN NULL
    ELSE s.expl_celi
    END
  ,CASE 
    WHEN s.expl_gravj = '0'
      THEN NULL
    ELSE s.expl_gravj
    END
  ,s.zkat::SMALLINT
  ,CASE 
    WHEN s.mt = '0'
      THEN NULL
    ELSE s.mt::SMALLINT
    END
  ,CASE 
    WHEN s.izc = '0'
      THEN NULL
    ELSE s.izc::SMALLINT
    END
  ,CASE 
    WHEN s.s10 = '0'
      THEN NULL
    ELSE s.s10::SMALLINT
    END
  ,CASE 
    WHEN s.a10 = '0'
      THEN NULL
    ELSE s.a10
    END
  ,CASE 
    WHEN s.h10 = '0'
      THEN NULL
    ELSE s.h10
    END
  ,CASE 
    WHEN s.d10 = '0'
      THEN NULL
    ELSE s.d10
    END
  ,CASE 
    WHEN s.g10 = '0'
      THEN NULL
    ELSE s.g10
    END
  ,CASE 
    WHEN s.n10 = '0'
      THEN NULL
    ELSE s.n10
    END
  ,CASE 
    WHEN s.bv10 = '0'
      THEN NULL
    ELSE s.bv10::SMALLINT
    END
  ,CASE 
    WHEN s.ba10 = '0'
      THEN NULL
    ELSE s.ba10::SMALLINT
    END
  ,CASE 
    WHEN s.s11 = '0'
      THEN NULL
    ELSE s.s11::SMALLINT
    END
  ,CASE 
    WHEN s.a11 = '0'
      THEN NULL
    ELSE s.a11
    END
  ,CASE 
    WHEN s.h11 = '0'
      THEN NULL
    ELSE s.h11
    END
  ,CASE 
    WHEN s.d11 = '0'
      THEN NULL
    ELSE s.d11
    END
  ,CASE 
    WHEN s.g11 = '0'
      THEN NULL
    ELSE s.g11
    END
  ,CASE 
    WHEN s.n11 = '0'
      THEN NULL
    ELSE s.n11
    END
  ,CASE 
    WHEN s.bv11 = '0'
      THEN NULL
    ELSE s.bv11::SMALLINT
    END
  ,CASE 
    WHEN s.ba11 = '0'
      THEN NULL
    ELSE s.ba11::SMALLINT
    END
  ,CASE 
    WHEN s.s12 = '0'
      THEN NULL
    ELSE s.s12::SMALLINT
    END
  ,CASE 
    WHEN s.a12 = '0'
      THEN NULL
    ELSE s.a12
    END
  ,CASE 
    WHEN s.h12 = '0'
      THEN NULL
    ELSE s.h12
    END
  ,CASE 
    WHEN s.d12 = '0'
      THEN NULL
    ELSE s.d12
    END
  ,CASE 
    WHEN s.g12 = '0'
      THEN NULL
    ELSE s.g12
    END
  ,CASE 
    WHEN s.n12 = '0'
      THEN NULL
    ELSE s.n12
    END
  ,CASE 
    WHEN s.bv12 = '0'
      THEN NULL
    ELSE s.bv12::SMALLINT
    END
  ,CASE 
    WHEN s.ba12 = '0'
      THEN NULL
    ELSE s.ba12::SMALLINT
    END
  ,CASE 
    WHEN s.s13 = '0'
      THEN NULL
    ELSE s.s13::SMALLINT
    END
  ,CASE 
    WHEN s.a13 = '0'
      THEN NULL
    ELSE s.a13
    END
  ,CASE 
    WHEN s.h13 = '0'
      THEN NULL
    ELSE s.h13
    END
  ,CASE 
    WHEN s.d13 = '0'
      THEN NULL
    ELSE s.d13
    END
  ,CASE 
    WHEN s.g13 = '0'
      THEN NULL
    ELSE s.g13
    END
  ,CASE 
    WHEN s.n13 = '0'
      THEN NULL
    ELSE s.n13
    END
  ,CASE 
    WHEN s.bv13 = '0'
      THEN NULL
    ELSE s.bv13::SMALLINT
    END
  ,CASE 
    WHEN s.ba13 = '0'
      THEN NULL
    ELSE s.ba13::SMALLINT
    END
  ,CASE 
    WHEN s.s14 = '0'
      THEN NULL
    ELSE s.s14::SMALLINT
    END
  ,CASE 
    WHEN s.a14 = '0'
      THEN NULL
    ELSE s.a14
    END
  ,CASE 
    WHEN s.h14 = '0'
      THEN NULL
    ELSE s.h14
    END
  ,CASE 
    WHEN s.d14 = '0'
      THEN NULL
    ELSE s.d14
    END
  ,CASE 
    WHEN s.g14 = '0'
      THEN NULL
    ELSE s.g14
    END
  ,CASE 
    WHEN s.n14 = '0'
      THEN NULL
    ELSE s.n14
    END
  ,CASE 
    WHEN s.bv14 = '0'
      THEN NULL
    ELSE s.bv14::SMALLINT
    END
  ,CASE 
    WHEN s.ba14 = '0'
      THEN NULL
    ELSE s.ba14::SMALLINT
    END
  ,CASE 
    WHEN s.jakopj = '0'
      THEN NULL
    ELSE s.jakopj
    END
  ,CASE 
    WHEN s.jaatjauno = '0'
      THEN NULL
    ELSE s.jaatjauno
    END
  ,CASE 
    WHEN s.p_darbv = '0'
      THEN NULL
    ELSE s.p_darbv::SMALLINT
    END
  ,CASE 
    WHEN s.p_darbg = '0'
      THEN NULL
    ELSE s.p_darbg
    END
  ,CASE 
    WHEN s.p_cirp = '0'
      THEN NULL
    ELSE s.p_cirp::SMALLINT
    END
  ,CASE 
    WHEN s.p_cirg = '0'
      THEN NULL
    ELSE s.p_cirg
    END
  ,CASE 
    WHEN s.atj_gads = '0'
      THEN NULL
    ELSE s.atj_gads
    END
  ,s.saimn_d_ie
  ,CASE 
    WHEN s.plant_audz = '0'
      THEN NULL
    ELSE s.plant_audz::BOOLEAN
    END
  ,s.forestry_c::SMALLINT --Aizstāj ar NULL 11-07-2022 datiem.
  ,s.vmd_headfo --Aizstāj ar NULL 11-07-2022 datiem.
  ,ST_Multi(s.geom)
  ,CURRENT_DATE
FROM mvr.mvr s
LEFT OUTER JOIN mvr.mvr_imported u ON s.id::INT = u.objectid
  AND s.kadastrs = u.kadastrs
  AND COALESCE(s.gtf, 0) = COALESCE(u.gtf, 0)
  AND s.kvart::SMALLINT = u.kvart
  AND s.nog::SMALLINT = u.nog
  AND COALESCE(s.anog::SMALLINT, 0) = COALESCE(u.anog, 0)
  AND s.nog_plat = u.nog_plat
  AND COALESCE(s.expl_mezs, 0) = COALESCE(u.expl_mezs, 0)
  AND COALESCE(s.expl_celi, 0) = COALESCE(u.expl_celi, 0)
  AND COALESCE(s.expl_gravj, 0) = COALESCE(u.expl_gravji, 0)
  AND s.zkat::SMALLINT = u.zkat
  AND COALESCE(s.mt::SMALLINT, 0) = COALESCE(u.mt, 0)
  AND COALESCE(s.izc::SMALLINT, 0) = COALESCE(u.izc, 0)
  AND COALESCE(s.s10::SMALLINT, 0) = COALESCE(u.s10, 0)
  AND COALESCE(s.a10, 0) = COALESCE(u.a10, 0)
  AND COALESCE(s.h10, 0) = COALESCE(u.h10, 0)
  AND COALESCE(s.d10, 0) = COALESCE(u.d10, 0)
  AND COALESCE(s.g10, 0) = COALESCE(u.g10, 0)
  AND COALESCE(s.n10, 0) = COALESCE(u.n10, 0)
  AND COALESCE(s.bv10::SMALLINT, 0) = COALESCE(u.bv10, 0)
  AND COALESCE(s.ba10::SMALLINT, 0) = COALESCE(u.ba10, 0)
  AND COALESCE(s.s11::SMALLINT, 0) = COALESCE(u.s11, 0)
  AND COALESCE(s.a11, 0) = COALESCE(u.a11, 0)
  AND COALESCE(s.h11, 0) = COALESCE(u.h11, 0)
  AND COALESCE(s.d11, 0) = COALESCE(u.d11, 0)
  AND COALESCE(s.g11, 0) = COALESCE(u.g11, 0)
  AND COALESCE(s.n11, 0) = COALESCE(u.n11, 0)
  AND COALESCE(s.bv11::SMALLINT, 0) = COALESCE(u.bv11, 0)
  AND COALESCE(s.ba11::SMALLINT, 0) = COALESCE(u.ba11, 0)
  AND COALESCE(s.s12::SMALLINT, 0) = COALESCE(u.s12, 0)
  AND COALESCE(s.a12, 0) = COALESCE(u.a12, 0)
  AND COALESCE(s.h12, 0) = COALESCE(u.h12, 0)
  AND COALESCE(s.d12, 0) = COALESCE(u.d12, 0)
  AND COALESCE(s.g12, 0) = COALESCE(u.g12, 0)
  AND COALESCE(s.n12, 0) = COALESCE(u.n12, 0)
  AND COALESCE(s.bv12::SMALLINT, 0) = COALESCE(u.bv12, 0)
  AND COALESCE(s.ba12::SMALLINT, 0) = COALESCE(u.ba12, 0)
  AND COALESCE(s.s13::SMALLINT, 0) = COALESCE(u.s13, 0)
  AND COALESCE(s.a13, 0) = COALESCE(u.a13, 0)
  AND COALESCE(s.h13, 0) = COALESCE(u.h13, 0)
  AND COALESCE(s.d13, 0) = COALESCE(u.d13, 0)
  AND COALESCE(s.g13, 0) = COALESCE(u.g13, 0)
  AND COALESCE(s.n13, 0) = COALESCE(u.n13, 0)
  AND COALESCE(s.bv13::SMALLINT, 0) = COALESCE(u.bv13, 0)
  AND COALESCE(s.ba13::SMALLINT, 0) = COALESCE(u.ba13, 0)
  AND COALESCE(s.s14::SMALLINT, 0) = COALESCE(u.s14, 0)
  AND COALESCE(s.a14, 0) = COALESCE(u.a14, 0)
  AND COALESCE(s.h14, 0) = COALESCE(u.h14, 0)
  AND COALESCE(s.d14, 0) = COALESCE(u.d14, 0)
  AND COALESCE(s.g14, 0) = COALESCE(u.g14, 0)
  AND COALESCE(s.n14, 0) = COALESCE(u.n14, 0)
  AND COALESCE(s.bv14::SMALLINT, 0) = COALESCE(u.bv14, 0)
  AND COALESCE(s.ba14::SMALLINT, 0) = COALESCE(u.ba14, 0)
  AND COALESCE(s.jakopj, 0) = COALESCE(u.jakopj, 0)
  AND COALESCE(s.jaatjauno, 0) = COALESCE(u.jaatjauno, 0)
  AND COALESCE(s.p_darbv::SMALLINT, 0) = COALESCE(u.p_darbv, 0)
  AND COALESCE(s.p_darbg, 0) = COALESCE(u.p_darbg, 0)
  AND COALESCE(s.p_cirp::SMALLINT, 0) = COALESCE(u.p_cirp, 0)
  AND COALESCE(s.p_cirg, 0) = COALESCE(u.p_cirg, 0)
  AND COALESCE(s.atj_gads, 0) = COALESCE(u.atj_gads, 0)
  AND s.saimn_d_ie = u.saimn_d_ierob
  AND COALESCE(s.plant_audz::BOOLEAN, true) = COALESCE(u.plant_audze, true)
  AND s.forestry_c::SMALLINT = u.forestry_c
  AND s.vmd_headfo = u.vmd_headfo
  AND ST_Equals(ST_Multi(s.geom), u.geom)
  AND (
    u.date_deleted = CURRENT_DATE
    OR u.date_deleted IS NULL
    )
WHERE u.id IS NULL
ORDER BY s.id;

END;
$BODY$;

REVOKE ALL ON PROCEDURE mvr.mvr_proc() FROM PUBLIC;

GRANT EXECUTE ON PROCEDURE mvr.mvr_proc() TO scheduler;
