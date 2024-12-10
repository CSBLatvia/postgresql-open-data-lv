#!/bin/bash

# Pārtrauc izpildi kļūdas gadījumā.
set -e

cd $HOME/data/aw_shp
wget -q https://data.gov.lv/dati/dataset/0c5e1a3b-0097-45a9-afa9-7f7262f3f623/resource/f539e8df-d4e4-4fc1-9f94-d25b662a4c38/download/aw_shp.zip
7za x aw_shp.zip -y -bsp0 -bso0
rm Autoceli.*
rm Pilsetas.*
rm Ekas.*
rm Ielas.*
rm Mazciemi.*
rm Novadi.*
rm Pagasti.*
rm aw_shp.zip
export PGPASSWORD=
psql -U scheduler -d spatial -w -c "CALL vzd.teritorialas_vienibas()"
psql -U scheduler -d spatial -w -c "CALL vzd.ciemi_proc()"