#!/bin/bash

# Pārtrauc izpildi kļūdas gadījumā.
set -e

export PGPASSWORD=
cd $HOME/data/nivkis_txt
FILES=$(curl https://data.gov.lv/dati/lv/dataset/142ce95f-ccda-4cd8-b1ac-1cc5c6980849.jsonld | jq -r '."@graph"[]."dcat:accessURL"."@id" | select(. != null)')

for FILE in $FILES
do
  curl "$FILE" -o ${FILE##*/}
done

rm *.csv
rm *.json
psql -U scheduler -d spatial -w -c "CALL vzd.nivkis_building_pre_reg_proc()"
psql -U scheduler -d spatial -w -c "CALL vzd.nivkis_ekas_rekviziti_proc()"
