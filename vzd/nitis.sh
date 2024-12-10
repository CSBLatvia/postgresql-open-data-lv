#!/bin/bash

# Pārtrauc izpildi kļūdas gadījumā.
set -e

# Par pamatu izmantots https://gist.github.com/laacz/8dfb7b69221790eb8d88e5fb91b9b088.
# Dzēš esošās un lejupielādē jaunās datnes, atarhivē tās un izdzēš arhīvus.
cd $HOME/data/nitis

FILES=$(curl https://data.gov.lv/dati/lv/dataset/f8a8a929-28d5-4f4f-85e9-062168cb4aba.jsonld | jq -r '."@graph"[]."dcat:accessURL"."@id" | select(. != null)')

for FILE in $FILES
do
  curl "$FILE" -o ${FILE##*/}
done

7za x \*.zip -y -bsp0 -bso0
rm *.zip
rm *.xlsx

# Apvieno periodus, pirmajā kolonnā pievieno faila nosaukumu.
dos2unix *.csv
awk '(NR == 1){print "\"Filename;" $0 "\""}(FNR > 1){print FILENAME ";" $0}' ZV_CSV_*.csv > zv.csv
awk '(NR == 1){print "\"Filename;" $0 "\""}(FNR > 1){print FILENAME ";" $0}' ZVB_CSV_*.csv > zvb.csv
awk '(NR == 1){print "\"Filename;" $0 "\""}(FNR > 1){print FILENAME ";" $0}' TG_CSV_*.csv > tg.csv

# Dzēš sākotnējās datnes.
rm *_*.csv

#Pievieno pēdiņas ap visām pirmās rindas kolonnām.
sed -i '1s/;/\";\"/g' *.csv

# Izsauc procedūru vzd.nitis(), kas atjauno datus.
export PGPASSWORD=
psql -U scheduler -d spatial -w -c "CALL vzd.nitis()"
# Izsauc procedūru vzd.nitis_geom(), kas pievieno trūkstošo ģeometriju no NĪVKIS datiem.
psql -U scheduler -d spatial -w -c "CALL vzd.nitis_geom()"