#!/bin/bash

# Pārtrauc izpildi kļūdas gadījumā.
set -e

cd $HOME/data
rm -rf aw_csv
mkdir aw_csv
cd aw_csv
wget -q https://data.gov.lv/dati/dataset/6b06a7e8-dedf-4705-a47b-2a7c51177473/resource/0d3810f4-1ac0-4fba-8b10-0188084a361b/download/aw_ciems.csv
wget -q https://data.gov.lv/dati/dataset/6b06a7e8-dedf-4705-a47b-2a7c51177473/resource/b83be373-f444-4f50-9b98-28741845325e/download/aw_dziv.csv
wget -q https://data.gov.lv/dati/dataset/6b06a7e8-dedf-4705-a47b-2a7c51177473/resource/a510737a-18ce-400f-ad4b-04fce5228272/download/aw_eka.csv
wget -q https://data.gov.lv/dati/dataset/6b06a7e8-dedf-4705-a47b-2a7c51177473/resource/3c4ab802-76cf-433c-9c1c-89215e28d833/download/aw_iela.csv
wget -q https://data.gov.lv/dati/dataset/6b06a7e8-dedf-4705-a47b-2a7c51177473/resource/c62c60bb-58d4-4f26-82c0-5b630769f9d1/download/aw_novads.csv
wget -q https://data.gov.lv/dati/dataset/6b06a7e8-dedf-4705-a47b-2a7c51177473/resource/6ba8c905-27a1-443a-b9c6-256a0777425b/download/aw_pagasts.csv
wget -q https://data.gov.lv/dati/dataset/6b06a7e8-dedf-4705-a47b-2a7c51177473/resource/ee02baa4-2bc3-4f77-a6cb-5427a3e9befe/download/aw_pilseta.csv
wget -q https://data.gov.lv/dati/dataset/6b06a7e8-dedf-4705-a47b-2a7c51177473/resource/21856ec7-8592-40d6-9e65-b23117348c98/download/aw_ppils.csv
wget -q https://data.gov.lv/dati/dataset/6b06a7e8-dedf-4705-a47b-2a7c51177473/resource/68f1152c-0f4c-4fc3-abb3-df4b8bfea992/download/aw_vietu_centroidi.csv
wget -q https://data.gov.lv/dati/dataset/6b06a7e8-dedf-4705-a47b-2a7c51177473/resource/c8f34472-8ca4-40d5-9c84-05b24dc19afe/download/aw_ciems_his.csv
wget -q https://data.gov.lv/dati/dataset/6b06a7e8-dedf-4705-a47b-2a7c51177473/resource/26e63e84-c04d-40b5-9c37-0ca9d08789ad/download/aw_dziv_his.csv
wget -q https://data.gov.lv/dati/dataset/6b06a7e8-dedf-4705-a47b-2a7c51177473/resource/d07443d7-15a8-4db6-9e53-7a68eec3c0dd/download/aw_eka_his.csv
wget -q https://data.gov.lv/dati/dataset/6b06a7e8-dedf-4705-a47b-2a7c51177473/resource/a7461a4e-4407-4506-9333-a50c4f51b328/download/aw_iela_his.csv
wget -q https://data.gov.lv/dati/dataset/6b06a7e8-dedf-4705-a47b-2a7c51177473/resource/c5c3d570-1596-49f2-a486-53439b449641/download/aw_novads_his.csv
wget -q https://data.gov.lv/dati/dataset/6b06a7e8-dedf-4705-a47b-2a7c51177473/resource/5950bf88-4441-470f-9e13-efcbd79bc1f0/download/aw_pagasts_his.csv
wget -q https://data.gov.lv/dati/dataset/6b06a7e8-dedf-4705-a47b-2a7c51177473/resource/87e2c4e5-13d9-4142-9052-8a6e9f094479/download/aw_pilseta_his.csv
wget -q https://data.gov.lv/dati/dataset/6b06a7e8-dedf-4705-a47b-2a7c51177473/resource/e7f17c92-fad4-4153-bef5-670a321c4ec1/download/aw_rajons.csv
export PGPASSWORD=
psql -U scheduler -d spatial -w -c "TRUNCATE TABLE aw_csv.aw_ciems RESTART IDENTITY;"
psql -U scheduler -d spatial -w -c "\COPY aw_csv.aw_ciems (kods, tips_cd, nosaukums, vkur_cd, vkur_tips, apstipr, apst_pak, statuss, sort_nos, dat_sak, dat_mod, dat_beig, atrib, std) FROM aw_ciems.csv WITH (FORMAT CSV, HEADER)"
psql -U scheduler -d spatial -w -c "TRUNCATE TABLE aw_csv.aw_ciems_his RESTART IDENTITY;"
psql -U scheduler -d spatial -w -c "\COPY aw_csv.aw_ciems_his (kods, tips_cd, dat_sak, dat_mod, dat_beig, std, nosaukums, vkur_cd, vkur_tips) FROM aw_ciems_his.csv WITH (FORMAT CSV, HEADER)"
psql -U scheduler -d spatial -w -c "TRUNCATE TABLE aw_csv.aw_dziv RESTART IDENTITY;"
psql -U scheduler -d spatial -w -c "\COPY aw_csv.aw_dziv (kods, tips_cd, statuss, apstipr, apst_pak, vkur_cd, vkur_tips, nosaukums, sort_nos, atrib, dat_sak, dat_mod, dat_beig, std) FROM aw_dziv.csv WITH (FORMAT CSV, HEADER)"
psql -U scheduler -d spatial -w -c "TRUNCATE TABLE aw_csv.aw_dziv_his RESTART IDENTITY;"
psql -U scheduler -d spatial -w -c "\COPY aw_csv.aw_dziv_his (kods, tips_cd, dat_sak, dat_mod, dat_beig, std, nosaukums, vkur_cd, vkur_tips) FROM aw_dziv_his.csv WITH (FORMAT CSV, HEADER)"
psql -U scheduler -d spatial -w -c "TRUNCATE TABLE aw_csv.aw_eka RESTART IDENTITY;"
psql -U scheduler -d spatial -w -c "\COPY aw_csv.aw_eka (kods, tips_cd, statuss, apstipr, apst_pak, vkur_cd, vkur_tips, nosaukums, sort_nos, atrib, pnod_cd, dat_sak, dat_mod, dat_beig, for_build, plan_adr, std, koord_x, koord_y, dd_n, dd_e) FROM aw_eka.csv WITH (FORMAT CSV, HEADER)"
psql -U scheduler -d spatial -w -c "TRUNCATE TABLE aw_csv.aw_eka_his RESTART IDENTITY;"
psql -U scheduler -d spatial -w -c "\COPY aw_csv.aw_eka_his (kods, kods_his, tips_cd, dat_sak, dat_mod, dat_beig, std, nosaukums, vkur_cd, vkur_tips) FROM aw_eka_his.csv WITH (FORMAT CSV, HEADER)"
psql -U scheduler -d spatial -w -c "TRUNCATE TABLE aw_csv.aw_iela RESTART IDENTITY;"
psql -U scheduler -d spatial -w -c "\COPY aw_csv.aw_iela (kods, tips_cd, nosaukums, vkur_cd, vkur_tips, apstipr, apst_pak, statuss, sort_nos, dat_sak, dat_mod, dat_beig, atrib, std) FROM aw_iela.csv WITH (FORMAT CSV, HEADER)"
psql -U scheduler -d spatial -w -c "TRUNCATE TABLE aw_csv.aw_iela_his RESTART IDENTITY;"
psql -U scheduler -d spatial -w -c "\COPY aw_csv.aw_iela_his (kods, tips_cd, dat_sak, dat_mod, dat_beig, std, nosaukums, vkur_cd, vkur_tips) FROM aw_iela_his.csv WITH (FORMAT CSV, HEADER)"
psql -U scheduler -d spatial -w -c "TRUNCATE TABLE aw_csv.aw_novads RESTART IDENTITY;"
psql -U scheduler -d spatial -w -c "\COPY aw_csv.aw_novads (kods, tips_cd, nosaukums, vkur_cd, vkur_tips, apstipr, apst_pak, statuss, sort_nos, dat_sak, dat_mod, dat_beig, atrib, std) FROM aw_novads.csv WITH (FORMAT CSV, HEADER)"
psql -U scheduler -d spatial -w -c "TRUNCATE TABLE aw_csv.aw_novads_his RESTART IDENTITY;"
psql -U scheduler -d spatial -w -c "\COPY aw_csv.aw_novads_his (kods, tips_cd, dat_sak, dat_mod, dat_beig, std, nosaukums, vkur_cd, vkur_tips) FROM aw_novads_his.csv WITH (FORMAT CSV, HEADER)"
psql -U scheduler -d spatial -w -c "TRUNCATE TABLE aw_csv.aw_pagasts RESTART IDENTITY;"
psql -U scheduler -d spatial -w -c "\COPY aw_csv.aw_pagasts (kods, tips_cd, nosaukums, vkur_cd, vkur_tips, apstipr, apst_pak, statuss, sort_nos, dat_sak, dat_mod, dat_beig, atrib, std) FROM aw_pagasts.csv WITH (FORMAT CSV, HEADER)"
psql -U scheduler -d spatial -w -c "TRUNCATE TABLE aw_csv.aw_pagasts_his RESTART IDENTITY;"
psql -U scheduler -d spatial -w -c "\COPY aw_csv.aw_pagasts_his (kods, tips_cd, dat_sak, dat_mod, dat_beig, std, nosaukums, vkur_cd, vkur_tips) FROM aw_pagasts_his.csv WITH (FORMAT CSV, HEADER)"
psql -U scheduler -d spatial -w -c "TRUNCATE TABLE aw_csv.aw_pilseta RESTART IDENTITY;"
psql -U scheduler -d spatial -w -c "\COPY aw_csv.aw_pilseta (kods, tips_cd, nosaukums, vkur_cd, vkur_tips, apstipr, apst_pak, statuss, sort_nos, dat_sak, dat_mod, dat_beig, atrib, std) FROM aw_pilseta.csv WITH (FORMAT CSV, HEADER)"
psql -U scheduler -d spatial -w -c "TRUNCATE TABLE aw_csv.aw_pilseta_his RESTART IDENTITY;"
psql -U scheduler -d spatial -w -c "\COPY aw_csv.aw_pilseta_his (kods, tips_cd, dat_sak, dat_mod, dat_beig, std, nosaukums, vkur_cd, vkur_tips) FROM aw_pilseta_his.csv WITH (FORMAT CSV, HEADER)"
psql -U scheduler -d spatial -w -c "TRUNCATE TABLE aw_csv.aw_ppils RESTART IDENTITY;"
psql -U scheduler -d spatial -w -c "\COPY aw_csv.aw_ppils (kods, ppils) FROM aw_ppils.csv WITH (FORMAT CSV, HEADER)"
psql -U scheduler -d spatial -w -c "TRUNCATE TABLE aw_csv.aw_rajons RESTART IDENTITY;"
psql -U scheduler -d spatial -w -c "\COPY aw_csv.aw_rajons (kods, tips_cd, nosaukums, vkur_cd, vkur_tips, apstipr, apst_pak, statuss, sort_nos, dat_sak, dat_mod, dat_beig, atrib) FROM aw_rajons.csv WITH (FORMAT CSV, HEADER)"
psql -U scheduler -d spatial -w -c "TRUNCATE TABLE aw_csv.aw_vietu_centroidi RESTART IDENTITY;"
psql -U scheduler -d spatial -w -c "\COPY aw_csv.aw_vietu_centroidi (kods, tips_cd, nosaukums, vkur_cd, vkur_tips, std, koord_x, koord_y, dd_n, dd_e) FROM aw_vietu_centroidi.csv WITH (FORMAT CSV, HEADER)"
cd ..
rm -r aw_csv
psql -U scheduler -d spatial -w -c "CALL vzd.adreses()"
psql -U scheduler -d spatial -w -c "CALL vzd.adreses_his_ekas_split()"