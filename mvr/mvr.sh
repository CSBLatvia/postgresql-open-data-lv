#!/bin/bash

# Pārtrauc izpildi kļūdas gadījumā.
set -e

# Par pamatu izmantots https://gist.github.com/laacz/8dfb7b69221790eb8d88e5fb91b9b088.
# Dzēš esošās un lejupielādē jaunās datnes, atarhivē tās un izdzēš arhīvus.
cd $HOME/data
rm -rf mvr
mkdir mvr
cd mvr

FILES=$(curl https://data.gov.lv/dati/lv/dataset/40014c0a-90f5-42be-afb2-fe3c4b8adf92.jsonld | jq -r '."@graph"[]."dcat:accessURL"."@id" | select(. != null)')

for FILE in $FILES
do
  curl "$FILE" -o ${FILE##*/}
done

rm *.pdf

7za x \*.7z
rm *.7z
rm *.sbn
rm *.sbx

# Apvieno lejupielādētos shapefile.
merged_file="./mvr.shp"
for i in $(find . -name '*.shp'); do
    if [ ! -f "$merged_file" ]; then
        echo -n "Create $merged_file "
        ogr2ogr -f "ESRI Shapefile" $merged_file $i -lco ENCODING=UTF-8
    else
        echo -n "Update $merged_file "
        ogr2ogr -f "ESRI Shapefile" -update -append $merged_file $i
    fi
done

# Dzēš atsevišķos shapefile.
find . -type f ! -name 'mvr.*' -delete

# Izsauc procedūru mvr.mvr_proc(), kas atjauno datus.
export PGPASSWORD=
psql -U scheduler -d spatial -w -c "CALL mvr.mvr_proc()"
