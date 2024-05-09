--mvr_imported.
DROP TABLE IF EXISTS mvr.mvr_imported;

CREATE TABLE mvr.mvr_imported (
  id serial PRIMARY KEY NOT NULL
  ,objectid INT NOT NULL
  ,kadastrs VARCHAR(11) NOT NULL
  ,gtf SMALLINT
  ,kvart SMALLINT NOT NULL
  ,nog SMALLINT NOT NULL
  ,anog SMALLINT
  ,nog_plat DECIMAL(6, 2) NOT NULL
  ,expl_mezs DECIMAL(6, 2)
  ,expl_celi DECIMAL(5, 2)
  ,expl_gravji DECIMAL(5, 2)
  ,zkat SMALLINT NOT NULL
  ,mt SMALLINT
  ,izc SMALLINT
  ,s10 SMALLINT
  ,a10 SMALLINT
  ,h10 DECIMAL(4, 1)
  ,d10 DECIMAL(5, 1)
  ,g10 SMALLINT
  ,n10 INT
  ,bv10 SMALLINT
  ,ba10 SMALLINT
  ,s11 SMALLINT
  ,a11 SMALLINT
  ,h11 DECIMAL(4, 1)
  ,d11 DECIMAL(5, 1)
  ,g11 SMALLINT
  ,n11 INT
  ,bv11 SMALLINT
  ,ba11 SMALLINT
  ,s12 SMALLINT
  ,a12 SMALLINT
  ,h12 DECIMAL(4, 1)
  ,d12 DECIMAL(5, 1)
  ,g12 SMALLINT
  ,n12 INT
  ,bv12 SMALLINT
  ,ba12 SMALLINT
  ,s13 SMALLINT
  ,a13 SMALLINT
  ,h13 DECIMAL(4, 1)
  ,d13 DECIMAL(5, 1)
  ,g13 SMALLINT
  ,n13 INT
  ,bv13 SMALLINT
  ,ba13 SMALLINT
  ,s14 SMALLINT
  ,a14 SMALLINT
  ,h14 DECIMAL(4, 1)
  ,d14 DECIMAL(5, 1)
  ,g14 SMALLINT
  ,n14 INT
  ,bv14 SMALLINT
  ,ba14 SMALLINT
  ,jakopj SMALLINT
  ,jaatjauno SMALLINT
  ,p_darbv SMALLINT
  ,p_darbg SMALLINT
  ,p_cirp SMALLINT
  ,p_cirg SMALLINT
  ,atj_gads SMALLINT
  ,saimn_d_ierob SMALLINT NOT NULL
  ,plant_audze BOOLEAN
  ,forestry_c SMALLINT NOT NULL
  ,vmd_headfo TEXT NOT NULL
  ,geom geometry(MultiPolygon, 3059)
  ,date_created DATE NOT NULL
  ,date_deleted DATE
  );

CREATE INDEX mvr_imported_geom_idx ON mvr.mvr_imported USING GIST (geom);

COMMENT ON TABLE mvr.mvr_imported IS 'Meža valsts reģistrs';

COMMENT ON COLUMN mvr.mvr_imported.id IS 'ID';

COMMENT ON COLUMN mvr.mvr_imported.objectid IS 'ID reģistrā';

COMMENT ON COLUMN mvr.mvr_imported.kadastrs IS 'Zemes vienības kadastra apzīmējums';

COMMENT ON COLUMN mvr.mvr_imported.gtf IS 'Meža inventarizācijas gads';

COMMENT ON COLUMN mvr.mvr_imported.kvart IS 'Kvartāla Nr.';

COMMENT ON COLUMN mvr.mvr_imported.nog IS 'Nogabala Nr.';

COMMENT ON COLUMN mvr.mvr_imported.anog IS 'Apakšnogabala Nr.';

COMMENT ON COLUMN mvr.mvr_imported.nog_plat IS 'Nogabala platība, ha';

COMMENT ON COLUMN mvr.mvr_imported.expl_mezs IS 'Meža platība nogabalā, ha';

COMMENT ON COLUMN mvr.mvr_imported.expl_celi IS 'Ceļu platība nogabalā, ha';

COMMENT ON COLUMN mvr.mvr_imported.expl_gravji IS 'Meliorācijas kadastrā reģistrēto grāvju platība nogabalā, ha';

COMMENT ON COLUMN mvr.mvr_imported.zkat IS 'Meža zemes veids meža apsaimniekošanā atbilstoši MK 2016. gada 21. jūnija noteikumu Nr. 384 2. pielikumam';

COMMENT ON COLUMN mvr.mvr_imported.mt IS 'Meža tips';

COMMENT ON COLUMN mvr.mvr_imported.izc IS 'Mežaudzes izcelsme (1 – dabiska, 2 – sēta vai stādīta)';

COMMENT ON COLUMN mvr.mvr_imported.s10 IS '1. stāva pirmā koku suga';

COMMENT ON COLUMN mvr.mvr_imported.a10 IS '1. stāva pirmās koku sugas vecums';

COMMENT ON COLUMN mvr.mvr_imported.h10 IS '1. stāva pirmās koku sugas augstums, m';

COMMENT ON COLUMN mvr.mvr_imported.d10 IS '1. stāva pirmās koku sugas diametrs, cm';

COMMENT ON COLUMN mvr.mvr_imported.g10 IS '1. stāva pirmās koku sugas šķērslaukums, m²/ha';

COMMENT ON COLUMN mvr.mvr_imported.n10 IS '1. stāva pirmās koku sugas koku skaits, gab.';

COMMENT ON COLUMN mvr.mvr_imported.bv10 IS '1. stāva pirmās koku sugas bojājuma veids';

COMMENT ON COLUMN mvr.mvr_imported.ba10 IS '1. stāva pirmās koku sugas bojājuma apjoms (% no šķērslaukuma; 1 – līdz 10, 2 – 11-30, 3 – 31-50, 4 – >51)';

COMMENT ON COLUMN mvr.mvr_imported.s11 IS '1. stāva otrā koku suga';

COMMENT ON COLUMN mvr.mvr_imported.a11 IS '1. stāva otrās koku sugas vecums';

COMMENT ON COLUMN mvr.mvr_imported.h11 IS '1. stāva otrās koku sugas augstums, m';

COMMENT ON COLUMN mvr.mvr_imported.d11 IS '1. stāva otrās koku sugas diametrs, cm';

COMMENT ON COLUMN mvr.mvr_imported.g11 IS '1. stāva otrās koku sugas šķērslaukums, m²/ha';

COMMENT ON COLUMN mvr.mvr_imported.n11 IS '1. stāva otrās koku sugas koku skaits, gab.';

COMMENT ON COLUMN mvr.mvr_imported.bv11 IS '1. stāva otrās koku sugas bojājuma veids';

COMMENT ON COLUMN mvr.mvr_imported.ba11 IS '1. stāva otrās koku sugas bojājuma apjoms (% no šķērslaukuma; 1 – līdz 10, 2 – 11-30, 3 – 31-50, 4 – >51)';

COMMENT ON COLUMN mvr.mvr_imported.s12 IS '1. stāva trešā koku suga';

COMMENT ON COLUMN mvr.mvr_imported.a12 IS '1. stāva trešās koku sugas vecums';

COMMENT ON COLUMN mvr.mvr_imported.h12 IS '1. stāva trešās koku sugas augstums, m';

COMMENT ON COLUMN mvr.mvr_imported.d12 IS '1. stāva trešās koku sugas diametrs, cm';

COMMENT ON COLUMN mvr.mvr_imported.g12 IS '1. stāva trešās koku sugas šķērslaukums, m²/ha';

COMMENT ON COLUMN mvr.mvr_imported.n12 IS '1. stāva trešās koku sugas koku skaits, gab.';

COMMENT ON COLUMN mvr.mvr_imported.bv12 IS '1. stāva trešās koku sugas bojājuma veids';

COMMENT ON COLUMN mvr.mvr_imported.ba12 IS '1. stāva trešās koku sugas bojājuma apjoms (% no šķērslaukuma; 1 – līdz 10, 2 – 11-30, 3 – 31-50, 4 – >51)';

COMMENT ON COLUMN mvr.mvr_imported.s13 IS '1. stāva ceturtā koku suga';

COMMENT ON COLUMN mvr.mvr_imported.a13 IS '1. stāva ceturtās koku sugas vecums';

COMMENT ON COLUMN mvr.mvr_imported.h13 IS '1. stāva ceturtās koku sugas augstums, m';

COMMENT ON COLUMN mvr.mvr_imported.d13 IS '1. stāva ceturtās koku sugas diametrs, cm';

COMMENT ON COLUMN mvr.mvr_imported.g13 IS '1. stāva ceturtās koku sugas šķērslaukums, m²/ha';

COMMENT ON COLUMN mvr.mvr_imported.n13 IS '1. stāva ceturtās koku sugas koku skaits, gab.';

COMMENT ON COLUMN mvr.mvr_imported.bv13 IS '1. stāva ceturtās koku sugas bojājuma veids';

COMMENT ON COLUMN mvr.mvr_imported.ba13 IS '1. stāva ceturtās koku sugas bojājuma apjoms (% no šķērslaukuma; 1 – līdz 10, 2 – 11-30, 3 – 31-50, 4 – >51)';

COMMENT ON COLUMN mvr.mvr_imported.s14 IS '1. stāva piektā koku suga';

COMMENT ON COLUMN mvr.mvr_imported.a14 IS '1. stāva piektās koku sugas vecums';

COMMENT ON COLUMN mvr.mvr_imported.h14 IS '1. stāva piektās koku sugas augstums, m';

COMMENT ON COLUMN mvr.mvr_imported.d14 IS '1. stāva piektās koku sugas diametrs, cm';

COMMENT ON COLUMN mvr.mvr_imported.g14 IS '1. stāva piektās koku sugas šķērslaukums, m²/ha';

COMMENT ON COLUMN mvr.mvr_imported.n14 IS '1. stāva piektās koku sugas koku skaits, gab.';

COMMENT ON COLUMN mvr.mvr_imported.bv14 IS '1. stāva piektās koku sugas bojājuma veids';

COMMENT ON COLUMN mvr.mvr_imported.ba14 IS '1. stāva piektās koku sugas bojājuma apjoms (% no šķērslaukuma; 1 – līdz 10, 2 – 11-30, 3 – 31-50, 4 – >51)';

COMMENT ON COLUMN mvr.mvr_imported.jakopj IS 'Jākopj (gads)';

COMMENT ON COLUMN mvr.mvr_imported.jaatjauno IS 'Jāatjauno (gads)';

COMMENT ON COLUMN mvr.mvr_imported.p_darbv IS 'Pēdējais darbības veids';

COMMENT ON COLUMN mvr.mvr_imported.p_darbg IS 'Pēdējais darbības gads';

COMMENT ON COLUMN mvr.mvr_imported.p_cirp IS 'Pēdējais ciršanas paņēmiens';

COMMENT ON COLUMN mvr.mvr_imported.p_cirg IS 'Pēdējais ciršanas gads';

COMMENT ON COLUMN mvr.mvr_imported.atj_gads IS 'Atjaunošanas gads';

COMMENT ON COLUMN mvr.mvr_imported.saimn_d_ierob IS 'Saimnieciskās darbības ierobežojuma veids';

COMMENT ON COLUMN mvr.mvr_imported.plant_audze IS 'Pazīme, ka mežaudze ir plantācija';

COMMENT ON COLUMN mvr.mvr_imported.forestry_c IS 'Mežniecības kods';

COMMENT ON COLUMN mvr.mvr_imported.vmd_headfo IS 'Virsmežniecības nosaukums';

COMMENT ON COLUMN mvr.mvr_imported.geom IS 'Ģeometrija';

COMMENT ON COLUMN mvr.mvr_imported.date_created IS 'Izveidošanas datums. Atbilst datu kopas sagatavošanas datumam Latvijas Atvērto datu portālā.';

COMMENT ON COLUMN mvr.mvr_imported.date_deleted IS 'Dzēšanas datums. Atbilst vecākās datu kopas, kurā vairs nav objekta ar šādiem atribūtiem, t.sk. ģeometriju, sagatavošanas datumam Latvijas Atvērto datu portālā.';

GRANT SELECT, UPDATE, INSERT
  ON TABLE mvr.mvr_imported
  TO scheduler;

GRANT SELECT, UPDATE
  ON SEQUENCE mvr.mvr_imported_id_seq
  TO scheduler;

--zkat.
DROP TABLE IF EXISTS mvr.zkat;

CREATE TABLE mvr.zkat (
  code SMALLINT PRIMARY KEY NOT NULL
  ,name TEXT NOT NULL
  );

COMMENT ON TABLE mvr.zkat IS 'Meža zemes veidi meža apsaimniekošanā atbilstoši MK 2016. gada 21. jūnija noteikumu Nr. 384 2. pielikumam';

COMMENT ON COLUMN mvr.zkat.code IS 'Kods';

COMMENT ON COLUMN mvr.zkat.name IS 'Nosaukums';

INSERT INTO mvr.zkat
VALUES (
  10
  ,'Mežaudze'
  )
  ,(
  12
  ,'Iznīkusi mežaudze'
  )
  ,(
  14
  ,'Izcirtums'
  )
  ,(
  16
  ,'Sēklu ieguves plantācija'
  )
  ,(
  21
  ,'Sūnu purvs'
  )
  ,(
  22
  ,'Zāļu purvs'
  )
  ,(
  23
  ,'Pārejas purvs'
  )
  ,(
  31
  ,'Meža lauce'
  )
  ,(
  32
  ,'Meža dzīvnieku barošanas lauce'
  )
  ,(
  33
  ,'Virsājs'
  )
  ,(
  34
  ,'Smiltājs'
  )
  ,(
  41
  ,'Pārplūstošs klajums'
  )
  ,(
  42
  ,'Bebru applūdinājums'
  )
  ,(
  51
  ,'Autoceļš'
  )
  ,(
  521
  ,'Kvartālstiga'
  )
  ,(
  522
  ,'Mineralizēta josla'
  )
  ,(
  523
  ,'Dabiska brauktuve'
  )
  ,(
  531
  ,'Meliorācijas kadastrā nereģistrēts grāvis'
  )
  ,(
  532
  ,'Meliorācijas kadastrā reģistrēts grāvis'
  )
  ,(
  542
  ,'Rekultivācijas zeme'
  )
  ,(
  543
  ,'Kokmateriālu krautuves vieta'
  )
  ,(
  544
  ,'Rekreācijas platība'
  );

ALTER TABLE mvr.mvr_imported ADD CONSTRAINT mvr_imported_fk_zkat FOREIGN KEY (zkat) REFERENCES mvr.zkat (code);

--mt.
DROP TABLE IF EXISTS mvr.mt;

CREATE TABLE mvr.mt (
  code SMALLINT PRIMARY KEY NOT NULL
  ,abbr TEXT
  ,name TEXT NOT NULL
  ,parent_name TEXT
  );

COMMENT ON TABLE mvr.mt IS 'Meža tipi';

COMMENT ON COLUMN mvr.mt.code IS 'Kods';

COMMENT ON COLUMN mvr.mt.abbr IS 'Saīsinājums';

COMMENT ON COLUMN mvr.mt.name IS 'Nosaukums';

COMMENT ON COLUMN mvr.mt.name IS 'Galvenais meža tips';

INSERT INTO mvr.mt
VALUES (
  1
  ,'Sl'
  ,'Sils'
  ,'Sausieņi'
  )
  ,(
  2
  ,'Mr'
  ,'Mētrājs'
  ,'Sausieņi'
  )
  ,(
  3
  ,'Ln'
  ,'Lāns'
  ,'Sausieņi'
  )
  ,(
  4
  ,'Dm'
  ,'Damaksnis'
  ,'Sausieņi'
  )
  ,(
  5
  ,'Vr'
  ,'Vēris'
  ,'Sausieņi'
  )
  ,(
  6
  ,'Gr'
  ,'Gārša'
  ,'Sausieņi'
  )
  ,(
  7
  ,'Gs'
  ,'Grīnis'
  ,'Slapjaiņi'
  )
  ,(
  8
  ,'Mrs'
  ,'Slapjais mētrājs'
  ,'Slapjaiņi'
  )
  ,(
  9
  ,'Dms'
  ,'Slapjais damaksnis'
  ,'Slapjaiņi'
  )
  ,(
  10
  ,'Vrs'
  ,'Slapjais vēris'
  ,'Slapjaiņi'
  )
  ,(
  11
  ,'Grs'
  ,'Slapjā gārša'
  ,'Slapjaiņi'
  )
  ,(
  12
  ,'Pv'
  ,'Purvājs'
  ,'Purvaiņi'
  )
  ,(
  14
  ,'Nd'
  ,'Niedrājs'
  ,'Purvaiņi'
  )
  ,(
  15
  ,'Db'
  ,'Dumbrājs'
  ,'Purvaiņi'
  )
  ,(
  16
  ,'Lk'
  ,'Liekņa'
  ,'Purvaiņi'
  )
  ,(
  17
  ,'Av'
  ,'Viršu ārenis'
  ,'Āreņi'
  )
  ,(
  18
  ,'Am'
  ,'Mētru ārenis'
  ,'Āreņi'
  )
  ,(
  19
  ,'As'
  ,'Šaurlapu ārenis'
  ,'Āreņi'
  )
  ,(
  21
  ,'Ap'
  ,'Platlapu ārenis'
  ,'Āreņi'
  )
  ,(
  22
  ,'Kv'
  ,'Viršu kūdrenis'
  ,'Kūdreņi'
  )
  ,(
  23
  ,'Km'
  ,'Mētru kūdrenis'
  ,'Kūdreņi'
  )
  ,(
  24
  ,'Ks'
  ,'Šaurlapju kūdrenis'
  ,'Kūdreņi'
  )
  ,(
  25
  ,'Kp'
  ,'Platlapju kūdrenis'
  ,'Kūdreņi'
  )
  ,(
  30
  ,NULL
  ,'Nenoteikts'
  ,NULL
  );

ALTER TABLE mvr.mvr_imported ADD CONSTRAINT mvr_imported_fk_mt FOREIGN KEY (mt) REFERENCES mvr.mt (code);

--p_darbv.
DROP TABLE IF EXISTS mvr.p_darbv;

CREATE TABLE mvr.p_darbv (
  code SMALLINT PRIMARY KEY NOT NULL
  ,name TEXT NOT NULL
  );

COMMENT ON TABLE mvr.p_darbv IS 'Pēdējie darbības veidi';

COMMENT ON COLUMN mvr.p_darbv.code IS 'Kods';

COMMENT ON COLUMN mvr.p_darbv.name IS 'Nosaukums';

INSERT INTO mvr.p_darbv
VALUES (
  1
  ,'Koku ciršana'
  )
  ,(
  2
  ,'Meža reproduktīvā materiāla (MRM) ieguve'
  )
  ,(
  3
  ,'Minerālmēslu vai pesticīdu lietošana'
  )
  ,(
  4
  ,'Atjaunošana'
  )
  ,(
  5
  ,'Ieaudzēšana'
  )
  ,(
  6
  ,'Jaunaudžu kopšana'
  )
  ,(
  7
  ,'Meža bojājumi'
  )
  ,(
  8
  ,'Meliorācija'
  )
  ,(
  9
  ,'Ceļu būve'
  )
  ,(
  10
  ,'Atjaunošana vai kopšana'
  )
  ,(
  11
  ,'Ieaudzēšana vai kopšana'
  );

ALTER TABLE mvr.mvr_imported ADD CONSTRAINT mvr_imported_fk_p_darbv FOREIGN KEY (p_darbv) REFERENCES mvr.p_darbv (code);

--p_cirp.
DROP TABLE IF EXISTS mvr.p_cirp;

CREATE TABLE mvr.p_cirp (
  code SMALLINT PRIMARY KEY NOT NULL
  ,abbr TEXT
  ,name TEXT NOT NULL
  );

COMMENT ON TABLE mvr.p_cirp IS 'Pēdējie ciršanas paņēmieni';

COMMENT ON COLUMN mvr.p_cirp.code IS 'Kods';

COMMENT ON COLUMN mvr.p_cirp.abbr IS 'Saīsinājums';

COMMENT ON COLUMN mvr.p_cirp.name IS 'Nosaukums';

INSERT INTO mvr.p_cirp
VALUES (
  11
  ,'Kailcirte'
  ,'Kailcirte'
  )
  ,(
  12
  ,'Vienlaidus'
  ,'Cirte pēc VMD sanitārā atzinuma (identisks kodam 31)'
  )
  ,(
  13
  ,'Kailc. ar sēklas kok.'
  ,'Kailcirte ar sēklas koku atstāšanu'
  )
  ,(
  14
  ,'Izlases'
  ,'Izlases cirte'
  )
  ,(
  15
  ,'Sēklas koku novākšana'
  ,'Sēklas koku novākšana'
  )
  ,(
  16
  ,'Izlases pēdēj. paņēmiens'
  ,'Izlases cirtes pēdējais paņēmiens'
  )
  ,(
  17
  ,'Caurmēra kailcirte'
  ,'Kailcirte pēc caurmēra'
  )
  ,(
  18
  ,'Caurmēra izlases'
  ,'Izlases cirte pēc caurmēra'
  )
  ,(
  21
  ,'Jaunaudžu'
  ,'Jaunaudžu kopšana'
  )
  ,(
  22
  ,'Kopšanas'
  ,'Kopšanas cirte'
  )
  ,(
  30
  ,'Izlases'
  ,'Sanitārā cirte'
  )
  ,(
  31
  ,'Vienlaidus'
  ,'Cirte pēc VMD sanitārā atzinuma'
  )
  ,(
  41
  ,'Vienlaidus'
  ,'Vienlaidus cirte (rek.)'
  )
  ,(
  42
  ,'Izlases'
  ,'Izlases cirte (rek.)'
  )
  ,(
  51
  ,'Vienlaidus'
  ,'Vienlaidus (citas)'
  )
  ,(
  52
  ,'Izlases'
  ,'Izlases cirte (citas)'
  )
  ,(
  53
  ,NULL
  ,'Kokmateriālu krautuves, pievešanas ceļi'
  )
  ,(
  61
  ,'Vienlaidus'
  ,'Nelikumīga kailcirte'
  )
  ,(
  62
  ,'Izlases'
  ,'Nelikumīga izlases cirte'
  )
  ,(
  71
  ,NULL
  ,'Sanitārā vienlaidus'
  )
  ,(
  72
  ,NULL
  ,'Sanitārā izlases'
  )
  ,(
  73
  ,NULL
  ,'Sanitārā ar atsv. koku atstāšanu'
  )
  ,(
  74
  ,NULL
  ,'Sanitāra vienlaidus (2010.08. vējgāzes)'
  )
  ,(
  75
  ,NULL
  ,'Sanitāra izlases (2010.08. vējgāzes)'
  )
  ,(
  76
  ,NULL
  ,'Sanitāra vienlaidus (kalstoš. eglēm kūdras augsnēs)'
  )
  ,(
  81
  ,'Atmežošana'
  ,'Atmežošanas'
  )
  ,(
  82
  ,NULL
  ,'Ceļi, meliorācijas sistēmas'
  )
  ,(
  91
  ,'Vienlaidus'
  ,'Ainavu vienlaidus'
  )
  ,(
  92
  ,'Izlases'
  ,'Ainavu izlases'
  );

ALTER TABLE mvr.mvr_imported ADD CONSTRAINT mvr_imported_fk_p_cirp FOREIGN KEY (p_cirp) REFERENCES mvr.p_cirp (code);

--s.
DROP TABLE IF EXISTS mvr.s;

CREATE TABLE mvr.s (
  code SMALLINT PRIMARY KEY NOT NULL
  ,abbr TEXT NOT NULL
  ,name TEXT NOT NULL
  );

COMMENT ON TABLE mvr.s IS 'Koku sugas';

COMMENT ON COLUMN mvr.s.code IS 'Kods';

COMMENT ON COLUMN mvr.s.abbr IS 'Saīsinājums';

COMMENT ON COLUMN mvr.s.name IS 'Nosaukums';

INSERT INTO mvr.s
VALUES (
  1
  ,'P'
  ,'Priede'
  )
  ,(
  3
  ,'E'
  ,'Egle'
  )
  ,(
  4
  ,'B'
  ,'Bērzs'
  )
  ,(
  6
  ,'M'
  ,'Melnalksnis'
  )
  ,(
  8
  ,'A'
  ,'Apse'
  )
  ,(
  9
  ,'Ba'
  ,'Baltalksnis'
  )
  ,(
  10
  ,'Oz'
  ,'Ozols'
  )
  ,(
  11
  ,'Os'
  ,'Osis'
  )
  ,(
  12
  ,'L'
  ,'Liepa'
  )
  ,(
  13
  ,'Le'
  ,'Lapegle'
  )
  ,(
  14
  ,'Pc'
  ,'Citas priedes'
  )
  ,(
  15
  ,'Ec'
  ,'Citas egles'
  )
  ,(
  16
  ,'G'
  ,'Goba, vīksna'
  )
  ,(
  17
  ,'Ds'
  ,'Dižskabārdis'
  )
  ,(
  18
  ,'Sk'
  ,'Skabārdis'
  )
  ,(
  19
  ,'Pa'
  ,'Papele'
  )
  ,(
  20
  ,'Vi'
  ,'Vītols'
  )
  ,(
  21
  ,'Bl'
  ,'Blīgzna'
  )
  ,(
  22
  ,'Cp'
  ,'Ciedru priede'
  )
  ,(
  23
  ,'Be'
  ,'Baltegle'
  )
  ,(
  24
  ,'K'
  ,'Kļava'
  )
  ,(
  25
  ,'K'
  ,'Saldais ķirsis'
  )
  ,(
  26
  ,'Me'
  ,'Mežābele'
  )
  ,(
  27
  ,'Bu'
  ,'Bumbiere'
  )
  ,(
  28
  ,'Du'
  ,'Duglāzija'
  )
  ,(
  29
  ,'I'
  ,'Īve'
  )
  ,(
  32
  ,'Pīlādži'
  ,'Pīlādži'
  )
  ,(
  35
  ,'Ievas'
  ,'Ievas'
  )
  ,(
  50
  ,'Dz_akācija'
  ,'Dzeltenā akācija'
  )
  ,(
  61
  ,'Ozc'
  ,'Citi ozoli'
  )
  ,(
  62
  ,'Lc'
  ,'Citas liepas'
  )
  ,(
  63
  ,'Kc'
  ,'Citas kļavas'
  )
  ,(
  64
  ,'Osc'
  ,'Citi oši'
  )
  ,(
  65
  ,'Gc'
  ,'Citas gobas, vīksnas'
  )
  ,(
  66
  ,'R'
  ,'Riekstkoki'
  )
  ,(
  67
  ,'Z'
  ,'Zirgkastaņi'
  )
  ,(
  68
  ,'Ha'
  ,'Hibrīdā apse'
  );

ALTER TABLE mvr.mvr_imported ADD CONSTRAINT mvr_imported_fk_s10 FOREIGN KEY (s10) REFERENCES mvr.s (code);
ALTER TABLE mvr.mvr_imported ADD CONSTRAINT mvr_imported_fk_s11 FOREIGN KEY (s11) REFERENCES mvr.s (code);
ALTER TABLE mvr.mvr_imported ADD CONSTRAINT mvr_imported_fk_s12 FOREIGN KEY (s12) REFERENCES mvr.s (code);
ALTER TABLE mvr.mvr_imported ADD CONSTRAINT mvr_imported_fk_s13 FOREIGN KEY (s13) REFERENCES mvr.s (code);
ALTER TABLE mvr.mvr_imported ADD CONSTRAINT mvr_imported_fk_s14 FOREIGN KEY (s14) REFERENCES mvr.s (code);

--bv.
DROP TABLE IF EXISTS mvr.bv;

CREATE TABLE mvr.bv (
  code SMALLINT PRIMARY KEY NOT NULL
  ,name TEXT NOT NULL
  );

COMMENT ON TABLE mvr.bv IS 'Koku sugas bojājumu veidi';

COMMENT ON COLUMN mvr.bv.code IS 'Kods';

COMMENT ON COLUMN mvr.bv.name IS 'Nosaukums';

INSERT INTO mvr.bv
VALUES (
  100
  ,'Vējgāze, snieglauze'
  )
  ,(
  200
  ,'Ūdens'
  )
  ,(
  300
  ,'Dzīvnieki'
  )
  ,(
  400
  ,'Uguns'
  )
  ,(
  500
  ,'Slimības'
  )
  ,(
  511
  ,'Sakņu trupe priežu audzēs'
  )
  ,(
  512
  ,'Sakņu trupe egļu audzēs'
  )
  ,(
  513
  ,'Skujkoku dzinumu vēzis'
  )
  ,(
  514
  ,'Sveķu vēzis'
  )
  ,(
  515
  ,'Cita'
  )
  ,(
  600
  ,'Kaitēkļi'
  )
  ,(
  610
  ,'Skuju, lapu grauzēji'
  )
  ,(
  611
  ,'Egļu mūķene'
  )
  ,(
  612
  ,'Priežu sprīžotājs'
  )
  ,(
  613
  ,'Priežu pūcīte'
  )
  ,(
  614
  ,'Priežu parastā zāģlapsene'
  )
  ,(
  615
  ,'Priežu rūsganā zāģlapsene'
  )
  ,(
  616
  ,'Lielais, mazais salnsprīžmetis'
  )
  ,(
  617
  ,'Citi skuju, lapu grauzēji'
  )
  ,(
  620
  ,'Stumbra kaitēkļi'
  )
  ,(
  621
  ,'Egles mizgrauži'
  )
  ,(
  622
  ,'Lielais, mazais priežu lūksngrauzis'
  )
  ,(
  623
  ,'Sveķotājsmecernieki'
  )
  ,(
  624
  ,'Citi stumbra kaitēkļi'
  )
  ,(
  625
  ,'Svaigi Egles mizgrauži'
  )
  ,(
  630
  ,'Jaunaudžu kaitēkļi'
  )
  ,(
  631
  ,'Priežu lielais smecernieks'
  )
  ,(
  632
  ,'Maijvabole'
  )
  ,(
  633
  ,'Citi jaunaudžu kaitēkļi'
  )
  ,(
  700
  ,'Saimnieciskā darbība'
  )
  ,(
  800
  ,'Citi'
  )
  ,(
  900
  ,'Sausums'
  );

ALTER TABLE mvr.mvr_imported ADD CONSTRAINT mvr_imported_fk_bv10 FOREIGN KEY (bv10) REFERENCES mvr.bv (code);
ALTER TABLE mvr.mvr_imported ADD CONSTRAINT mvr_imported_fk_bv11 FOREIGN KEY (bv11) REFERENCES mvr.bv (code);
ALTER TABLE mvr.mvr_imported ADD CONSTRAINT mvr_imported_fk_bv12 FOREIGN KEY (bv12) REFERENCES mvr.bv (code);
ALTER TABLE mvr.mvr_imported ADD CONSTRAINT mvr_imported_fk_bv13 FOREIGN KEY (bv13) REFERENCES mvr.bv (code);
ALTER TABLE mvr.mvr_imported ADD CONSTRAINT mvr_imported_fk_bv14 FOREIGN KEY (bv14) REFERENCES mvr.bv (code);