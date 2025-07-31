#!/bin/bash

# Pārtrauc izpildi kļūdas gadījumā.
set -e

cd $HOME/data/aw_shp
wget -q https://data.gov.lv/dati/dataset/6b06a7e8-dedf-4705-a47b-2a7c51177473/resource/b643b1b3-223f-4394-9beb-18524f8b0b82/download/aw_shp.zip
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
