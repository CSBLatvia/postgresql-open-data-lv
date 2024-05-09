#!/bin/bash
cd $HOME/data
mkdir aw_csv
cd aw_csv
wget -q https://data.gov.lv/dati/dataset/0c5e1a3b-0097-45a9-afa9-7f7262f3f623/resource/e7110ebe-1bc0-4c3a-94a3-f20cb723b717/download/aw_ciems.zip
unzip -o -q aw_ciems.zip
wget -q https://data.gov.lv/dati/dataset/0c5e1a3b-0097-45a9-afa9-7f7262f3f623/resource/92da0c49-e922-41be-8bf4-1a6cb8afe0f9/download/aw_dziv.zip
unzip -o -q aw_dziv.zip
wget -q https://data.gov.lv/dati/dataset/0c5e1a3b-0097-45a9-afa9-7f7262f3f623/resource/02ef9ab7-70d1-45e3-b445-eb64bc5a2edd/download/aw_eka.zip
unzip -o -q aw_eka.zip
wget -q https://data.gov.lv/dati/dataset/0c5e1a3b-0097-45a9-afa9-7f7262f3f623/resource/4bc2aa5a-02ec-4021-9d58-c1da60107a20/download/aw_iela.zip
unzip -o -q aw_iela.zip
wget -q https://data.gov.lv/dati/dataset/0c5e1a3b-0097-45a9-afa9-7f7262f3f623/resource/8ce7a833-6d30-41b0-93e0-b0d5e5d46d68/download/aw_novads.zip
unzip -o -q aw_novads.zip
wget -q https://data.gov.lv/dati/dataset/0c5e1a3b-0097-45a9-afa9-7f7262f3f623/resource/59b24a57-fde2-4d63-bc58-86ba8da68b62/download/aw_pagasts.zip
unzip -o -q aw_pagasts.zip
wget -q https://data.gov.lv/dati/dataset/0c5e1a3b-0097-45a9-afa9-7f7262f3f623/resource/e60e1aa2-5be7-422e-8192-c042f8ddc9c4/download/aw_pilseta.zip
unzip -o -q aw_pilseta.zip
wget -q https://data.gov.lv/dati/dataset/0c5e1a3b-0097-45a9-afa9-7f7262f3f623/resource/1bcb3d7c-42a5-4cda-9990-232e549ec6b0/download/aw_ppils.zip
unzip -o -q aw_ppils.zip
wget -q https://data.gov.lv/dati/dataset/0c5e1a3b-0097-45a9-afa9-7f7262f3f623/resource/aee4ac4a-fdbf-4355-846a-3c98175bedf4/download/aw_vietu_centroidi.zip
unzip -o -q aw_vietu_centroidi.zip
wget -q https://data.gov.lv/dati/dataset/0c5e1a3b-0097-45a9-afa9-7f7262f3f623/resource/725f8616-c480-4168-9575-8461faf8436d/download/aw_ciems_his.zip
unzip -o -q aw_ciems_his.zip
wget -q https://data.gov.lv/dati/dataset/0c5e1a3b-0097-45a9-afa9-7f7262f3f623/resource/9d66b09f-619a-4d7f-9f34-a62845d1ee84/download/aw_dziv_his.zip
unzip -o -q aw_dziv_his.zip
wget -q https://data.gov.lv/dati/dataset/0c5e1a3b-0097-45a9-afa9-7f7262f3f623/resource/b6bca7e4-8c96-423f-b368-51ee09fb7b0f/download/aw_eka_his.zip
unzip -o -q aw_eka_his.zip
wget -q https://data.gov.lv/dati/dataset/0c5e1a3b-0097-45a9-afa9-7f7262f3f623/resource/1f0ba691-f8fa-43d4-85de-c641f3c1fd0b/download/aw_iela_his.zip
unzip -o -q aw_iela_his.zip
wget -q https://data.gov.lv/dati/dataset/0c5e1a3b-0097-45a9-afa9-7f7262f3f623/resource/ab9a4455-ce82-4dfc-9117-f340a3a728ba/download/aw_novads_his.zip
unzip -o -q aw_novads_his.zip
wget -q https://data.gov.lv/dati/dataset/0c5e1a3b-0097-45a9-afa9-7f7262f3f623/resource/ae547ada-1cec-448b-9f50-4c108df9cb1f/download/aw_pagasts_his.zip
unzip -o -q aw_pagasts_his.zip
wget -q https://data.gov.lv/dati/dataset/0c5e1a3b-0097-45a9-afa9-7f7262f3f623/resource/a7e135c7-6ef9-4c03-8321-0f3ba41ca4da/download/aw_pilseta_his.zip
unzip -o -q aw_pilseta_his.zip
wget -q https://data.gov.lv/dati/dataset/0c5e1a3b-0097-45a9-afa9-7f7262f3f623/resource/0a373698-1704-46bf-b008-6c1db4e57292/download/aw_rajons.zip
unzip -o -q aw_rajons.zip
rm *.zip
export PGPASSWORD=
psql -U scheduler -d spatial -w -c "TRUNCATE TABLE aw_csv.aw_ciems RESTART IDENTITY;"
psql -U scheduler -d spatial -w -c "\COPY aw_csv.aw_ciems (kods, tips_cd, nosaukums, vkur_cd, vkur_tips, apstipr, apst_pak, statuss, sort_nos, dat_sak, dat_mod, dat_beig, atrib, std) FROM AW_CIEMS.CSV WITH (FORMAT CSV, DELIMITER ';', QUOTE '#', HEADER, FORCE_NULL (apstipr, apst_pak))"
psql -U scheduler -d spatial -w -c "TRUNCATE TABLE aw_csv.aw_ciems_his RESTART IDENTITY;"
psql -U scheduler -d spatial -w -c "\COPY aw_csv.aw_ciems_his (kods, tips_cd, dat_sak, dat_mod, dat_beig, std, nosaukums, vkur_cd, vkur_tips) FROM AW_CIEMS_HIS.CSV WITH (FORMAT CSV, DELIMITER ';', QUOTE '#', HEADER)"
psql -U scheduler -d spatial -w -c "TRUNCATE TABLE aw_csv.aw_dziv RESTART IDENTITY;"
psql -U scheduler -d spatial -w -c "\COPY aw_csv.aw_dziv (kods, tips_cd, statuss, apstipr, apst_pak, vkur_cd, vkur_tips, nosaukums, sort_nos, atrib, dat_sak, dat_mod, dat_beig, std) FROM AW_DZIV.CSV WITH (FORMAT CSV, DELIMITER ';', QUOTE '#', HEADER, FORCE_NULL (apstipr, apst_pak))"
psql -U scheduler -d spatial -w -c "TRUNCATE TABLE aw_csv.aw_dziv_his RESTART IDENTITY;"
psql -U scheduler -d spatial -w -c "\COPY aw_csv.aw_dziv_his (kods, tips_cd, dat_sak, dat_mod, dat_beig, std, nosaukums, vkur_cd, vkur_tips) FROM AW_DZIV_HIS.CSV WITH (FORMAT CSV, DELIMITER ';', QUOTE '#', HEADER)"
psql -U scheduler -d spatial -w -c "TRUNCATE TABLE aw_csv.aw_eka RESTART IDENTITY;"
psql -U scheduler -d spatial -w -c "\COPY aw_csv.aw_eka (kods, tips_cd, statuss, apstipr, apst_pak, vkur_cd, vkur_tips, nosaukums, sort_nos, atrib, pnod_cd, dat_sak, dat_mod, dat_beig, for_build, plan_adr, std, koord_x, koord_y, dd_n, dd_e) FROM AW_EKA.CSV WITH (FORMAT CSV, DELIMITER ';', QUOTE '#', HEADER, FORCE_NULL (apstipr, apst_pak, pnod_cd, koord_x, koord_y, dd_n, dd_e))"
psql -U scheduler -d spatial -w -c "TRUNCATE TABLE aw_csv.aw_eka_his RESTART IDENTITY;"
psql -U scheduler -d spatial -w -c "\COPY aw_csv.aw_eka_his (kods, kods_his, tips_cd, dat_sak, dat_mod, dat_beig, std, nosaukums, vkur_cd, vkur_tips) FROM AW_EKA_HIS.CSV WITH (FORMAT CSV, DELIMITER ';', QUOTE '#', HEADER, FORCE_NULL (kods_his))"
psql -U scheduler -d spatial -w -c "TRUNCATE TABLE aw_csv.aw_iela RESTART IDENTITY;"
psql -U scheduler -d spatial -w -c "\COPY aw_csv.aw_iela (kods, tips_cd, nosaukums, vkur_cd, vkur_tips, apstipr, apst_pak, statuss, sort_nos, dat_sak, dat_mod, dat_beig, atrib, std) FROM AW_IELA.CSV WITH (FORMAT CSV, DELIMITER ';', QUOTE '#', HEADER, FORCE_NULL (apstipr, apst_pak))"
psql -U scheduler -d spatial -w -c "TRUNCATE TABLE aw_csv.aw_iela_his RESTART IDENTITY;"
psql -U scheduler -d spatial -w -c "\COPY aw_csv.aw_iela_his (kods, tips_cd, dat_sak, dat_mod, dat_beig, std, nosaukums, vkur_cd, vkur_tips) FROM AW_IELA_HIS.CSV WITH (FORMAT CSV, DELIMITER ';', QUOTE '#', HEADER)"
psql -U scheduler -d spatial -w -c "TRUNCATE TABLE aw_csv.aw_novads RESTART IDENTITY;"
psql -U scheduler -d spatial -w -c "\COPY aw_csv.aw_novads (kods, tips_cd, nosaukums, vkur_cd, vkur_tips, apstipr, apst_pak, statuss, sort_nos, dat_sak, dat_mod, dat_beig, atrib, std) FROM AW_NOVADS.CSV WITH (FORMAT CSV, DELIMITER ';', QUOTE '#', HEADER, FORCE_NULL (apstipr, apst_pak))"
psql -U scheduler -d spatial -w -c "TRUNCATE TABLE aw_csv.aw_novads_his RESTART IDENTITY;"
psql -U scheduler -d spatial -w -c "\COPY aw_csv.aw_novads_his (kods, tips_cd, dat_sak, dat_mod, dat_beig, std, nosaukums, vkur_cd, vkur_tips) FROM AW_NOVADS_HIS.CSV WITH (FORMAT CSV, DELIMITER ';', QUOTE '#', HEADER)"
psql -U scheduler -d spatial -w -c "TRUNCATE TABLE aw_csv.aw_pagasts RESTART IDENTITY;"
psql -U scheduler -d spatial -w -c "\COPY aw_csv.aw_pagasts (kods, tips_cd, nosaukums, vkur_cd, vkur_tips, apstipr, apst_pak, statuss, sort_nos, dat_sak, dat_mod, dat_beig, atrib, std) FROM AW_PAGASTS.CSV WITH (FORMAT CSV, DELIMITER ';', QUOTE '#', HEADER, FORCE_NULL (apstipr, apst_pak))"
psql -U scheduler -d spatial -w -c "TRUNCATE TABLE aw_csv.aw_pagasts_his RESTART IDENTITY;"
psql -U scheduler -d spatial -w -c "\COPY aw_csv.aw_pagasts_his (kods, tips_cd, dat_sak, dat_mod, dat_beig, std, nosaukums, vkur_cd, vkur_tips) FROM AW_PAGASTS_HIS.CSV WITH (FORMAT CSV, DELIMITER ';', QUOTE '#', HEADER)"
psql -U scheduler -d spatial -w -c "TRUNCATE TABLE aw_csv.aw_pilseta RESTART IDENTITY;"
psql -U scheduler -d spatial -w -c "\COPY aw_csv.aw_pilseta (kods, tips_cd, nosaukums, vkur_cd, vkur_tips, apstipr, apst_pak, statuss, sort_nos, dat_sak, dat_mod, dat_beig, atrib, std) FROM AW_PILSETA.CSV WITH (FORMAT CSV, DELIMITER ';', QUOTE '#', HEADER, FORCE_NULL (apstipr, apst_pak))"
psql -U scheduler -d spatial -w -c "TRUNCATE TABLE aw_csv.aw_pilseta_his RESTART IDENTITY;"
psql -U scheduler -d spatial -w -c "\COPY aw_csv.aw_pilseta_his (kods, tips_cd, dat_sak, dat_mod, dat_beig, std, nosaukums, vkur_cd, vkur_tips) FROM AW_PILSETA_HIS.CSV WITH (FORMAT CSV, DELIMITER ';', QUOTE '#', HEADER)"
psql -U scheduler -d spatial -w -c "TRUNCATE TABLE aw_csv.aw_ppils RESTART IDENTITY;"
psql -U scheduler -d spatial -w -c "\COPY aw_csv.aw_ppils (kods, ppils) FROM AW_PPILS.CSV WITH (FORMAT CSV, DELIMITER ';', QUOTE '#', HEADER)"
psql -U scheduler -d spatial -w -c "TRUNCATE TABLE aw_csv.aw_rajons RESTART IDENTITY;"
psql -U scheduler -d spatial -w -c "\COPY aw_csv.aw_rajons (kods, tips_cd, nosaukums, vkur_cd, vkur_tips, apstipr, apst_pak, statuss, sort_nos, dat_sak, dat_mod, dat_beig, atrib) FROM AW_RAJONS.CSV WITH (FORMAT CSV, DELIMITER ';', QUOTE '#', HEADER, FORCE_NULL (apstipr, apst_pak))"
psql -U scheduler -d spatial -w -c "TRUNCATE TABLE aw_csv.aw_vietu_centroidi RESTART IDENTITY;"
psql -U scheduler -d spatial -w -c "\COPY aw_csv.aw_vietu_centroidi (kods, tips_cd, nosaukums, vkur_cd, vkur_tips, std, koord_x, koord_y, dd_n, dd_e) FROM AW_VIETU_CENTROIDI.CSV WITH (FORMAT CSV, DELIMITER ';', QUOTE '#', HEADER, FORCE_NULL (koord_x, koord_y, dd_n, dd_e))"
cd ..
rm -r aw_csv
psql -U scheduler -d spatial -w -c "CALL vzd.adreses()"
psql -U scheduler -d spatial -w -c "CALL vzd.adreses_his_ekas_split()"