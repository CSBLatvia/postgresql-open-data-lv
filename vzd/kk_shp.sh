#!/bin/bash

# Pārtrauc izpildi kļūdas gadījumā.
set -e

# Par pamatu izmantots https://gist.github.com/laacz/8dfb7b69221790eb8d88e5fb91b9b088.
# Dzēš esošās un lejupielādē jaunās datnes, atarhivē tās un izdzēš arhīvus.
cd $HOME/data
rm -rf kk_shp
mkdir kk_shp
cd kk_shp

FILES=$(curl https://data.gov.lv/dati/lv/dataset/b28f0eed-73b0-4e44-94e7-b04b11bf0b69.jsonld | jq -r '."@graph"[]."dcat:accessURL"."@id" | select(. != null)')

for FILE in $FILES
do
  curl "$FILE" -o ${FILE##*/}
done

7za x \*.zip -y -bsp0 -bso0
rm *.zip

# Apvieno lejupielādētos shapefile (tikai ēkas, inženierbūves, zemes vienības, zemes vienību daļas un apgrūtinājumu ceļa servitūtu teritorijas).
cd $HOME/data

APPEND=0
LAYERS="KKBuilding KKEngineeringStructurePoly KKParcel KKParcelPart KKWayRestriction"

for type in $LAYERS; do
    APPEND=0
    target_file="kk_shp/$type.shp"
    target_layer=$(echo "$type" | tr '[:upper:]' '[:lower:]')

    for file in kk_shp/**/"$type".shp; do
        if [ "$APPEND" == 0 ]; then
            echo -n "Create $target_file "
            ogr2ogr -f 'ESRI Shapefile' "$target_file" "$file" -lco ENCODING=UTF-8
            APPEND=1
        else
            echo -n "Update $target_file "
            ogr2ogr -f 'ESRI Shapefile' -update -append "$target_file" "$file" -nln "$target_layer"
        fi
        echo "(${target_file%.shp}; $file)"
    done
done

# Dzēš direktorijas ar atsevišķajām datnēm.
rm -rf $HOME/data/kk_shp/*/

# Izsauc procedūru vzd.nivkis(), kas atjauno datus.
export PGPASSWORD=
psql -U scheduler -d spatial -w -c "CALL vzd.nivkis()"
