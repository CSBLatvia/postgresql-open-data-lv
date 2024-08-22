#!/bin/bash

# Pārtrauc izpildi kļūdas gadījumā.
set -e

# Par pamatu izmantots https://gist.github.com/laacz/8dfb7b69221790eb8d88e5fb91b9b088.
cd /home/user/data/aw_del

FILES=$(curl https://data.gov.lv/dati/lv/dataset/f0624a01-4612-4092-a04e-5e1b6489668c.jsonld | jq -r '."@graph"[]."dcat:accessURL"."@id" | select(. != null)')

for FILE in $FILES
do
  curl "$FILE" -o ${FILE##*/}
done

mv dzestas_ek_koordinates_*.xlsx aw_eka_del.xlsx