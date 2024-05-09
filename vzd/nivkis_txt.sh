#!/bin/bash
export PGPASSWORD=
cd $HOME/data/nivkis_txt

# property
mkdir property
cd property
wget -q https://data.gov.lv/dati/dataset/be841486-4af9-4d38-aa14-6502a2ddb517/resource/931e6299-61ba-477b-ba8d-f0fb30db9667/download/property.zip
unzip -q property.zip
rm property.zip
psql -U scheduler -d spatial -w -c "DROP TABLE IF EXISTS vzd.nivkis_property_tmp;"
psql -U scheduler -d spatial -w -c "CREATE TABLE IF NOT EXISTS vzd.nivkis_property_tmp (data XML);"
for file in $(find . -name '*.xml'); do
  sed -i -e 's/\r//g' -e 's/\t/ /g' -e 's/\\/\//g' "${file}"
  tr -d '\n' <"$file" >"${file}_new"
  mv "${file}_new" $file
  echo "\COPY vzd.nivkis_property_tmp FROM" "${file}" >> script.sql
done
psql -U scheduler -d spatial -w -f script.sql
rm script.sql
cd ..
rm -r property
psql -U scheduler -d spatial -w -c "CALL vzd.nivkis_property_proc()"

# ownership
mkdir ownership
cd ownership
wget -q https://data.gov.lv/dati/dataset/be841486-4af9-4d38-aa14-6502a2ddb517/resource/a0d801da-8eb0-4426-9087-50e8139bce39/download/ownership.zip
unzip -q ownership.zip
rm ownership.zip
psql -U scheduler -d spatial -w -c "DROP TABLE IF EXISTS vzd.nivkis_ownership_tmp;"
psql -U scheduler -d spatial -w -c "CREATE TABLE IF NOT EXISTS vzd.nivkis_ownership_tmp (data XML);"
for file in $(find . -name '*.xml'); do
  echo "\COPY vzd.nivkis_ownership_tmp FROM" "${file}" >> script.sql
done
psql -U scheduler -d spatial -w -f script.sql
rm script.sql
cd ..
rm -r ownership
psql -U scheduler -d spatial -w -c "CALL vzd.nivkis_ownership_proc()"

# parcel
mkdir parcel
cd parcel
wget -q https://data.gov.lv/dati/dataset/be841486-4af9-4d38-aa14-6502a2ddb517/resource/1618f19a-c818-4966-8183-a2e3c108597a/download/parcel.zip
unzip -q parcel.zip
rm parcel.zip
psql -U scheduler -d spatial -w -c "DROP TABLE IF EXISTS vzd.nivkis_parcel_tmp;"
psql -U scheduler -d spatial -w -c "CREATE TABLE IF NOT EXISTS vzd.nivkis_parcel_tmp (data XML);"
for file in $(find . -name '*.xml'); do
  echo "\COPY vzd.nivkis_parcel_tmp FROM" "${file}" >> script.sql
done
psql -U scheduler -d spatial -w -f script.sql
rm script.sql
cd ..
rm -r parcel
psql -U scheduler -d spatial -w -c "CALL vzd.nivkis_parcel_proc()"

# parcelpart
mkdir parcelpart
cd parcelpart
wget -q https://data.gov.lv/dati/dataset/be841486-4af9-4d38-aa14-6502a2ddb517/resource/58635c63-8c04-4193-a9f2-ec674c57ae93/download/parcelpart.zip
unzip -q parcelpart.zip
rm parcelpart.zip
psql -U scheduler -d spatial -w -c "DROP TABLE IF EXISTS vzd.nivkis_parcelpart_tmp;"
psql -U scheduler -d spatial -w -c "CREATE TABLE IF NOT EXISTS vzd.nivkis_parcelpart_tmp (data XML);"
for file in $(find . -name '*.xml'); do
  echo "\COPY vzd.nivkis_parcelpart_tmp FROM" "${file}" >> script.sql
done
psql -U scheduler -d spatial -w -f script.sql
rm script.sql
cd ..
rm -r parcelpart
psql -U scheduler -d spatial -w -c "CALL vzd.nivkis_parcelpart_proc()"

# building
mkdir building
cd building
wget -q https://data.gov.lv/dati/dataset/be841486-4af9-4d38-aa14-6502a2ddb517/resource/9fe29b57-07cd-4458-b22c-b0b9f2bc8915/download/building.zip
unzip -q building.zip
rm building.zip
psql -U scheduler -d spatial -w -c "DROP TABLE IF EXISTS vzd.nivkis_building_tmp;"
psql -U scheduler -d spatial -w -c "CREATE TABLE IF NOT EXISTS vzd.nivkis_building_tmp (data XML);"
for file in $(find . -name '*.xml'); do
  sed -i -e 's/\r//g' -e 's/\t/ /g' -e 's/\\/\//g' "${file}"
  echo "\COPY vzd.nivkis_building_tmp FROM" "${file}" >> script.sql
done
psql -U scheduler -d spatial -w -f script.sql
rm script.sql
cd ..
rm -r building
psql -U scheduler -d spatial -w -c "CALL vzd.nivkis_building_proc()"

# premisegroup
mkdir premisegroup
cd premisegroup
wget -q https://data.gov.lv/dati/dataset/be841486-4af9-4d38-aa14-6502a2ddb517/resource/5d8b1cfa-1e67-4b77-a6ac-b4e37eba0d7e/download/premisegroup.zip
unzip -q premisegroup.zip
rm premisegroup.zip
psql -U scheduler -d spatial -w -c "DROP TABLE IF EXISTS vzd.nivkis_premisegroup_tmp;"
psql -U scheduler -d spatial -w -c "CREATE TABLE IF NOT EXISTS vzd.nivkis_premisegroup_tmp (data XML);"
for file in $(find . -name '*.xml'); do
  sed -i -e 's/\r//g' -e 's/\t/ /g' -e 's/\\/\//g' "${file}"
  echo "\COPY vzd.nivkis_premisegroup_tmp FROM" "${file}" >> script.sql
done
psql -U scheduler -d spatial -w -f script.sql
rm script.sql
cd ..
rm -r premisegroup
psql -U scheduler -d spatial -w -c "CALL vzd.nivkis_premisegroup_proc()"

# address
mkdir address
cd address
wget -q https://data.gov.lv/dati/dataset/be841486-4af9-4d38-aa14-6502a2ddb517/resource/2aeea249-6948-4713-92c2-e01543ea0f33/download/address.zip
unzip -q address.zip
rm address.zip
psql -U scheduler -d spatial -w -c "DROP TABLE IF EXISTS vzd.nivkis_address_tmp;"
psql -U scheduler -d spatial -w -c "CREATE TABLE IF NOT EXISTS vzd.nivkis_address_tmp (data XML);"
for file in $(find . -name '*.xml'); do
  echo "\COPY vzd.nivkis_address_tmp FROM" "${file}" >> script.sql
done
psql -U scheduler -d spatial -w -f script.sql
rm script.sql
cd ..
rm -r address
psql -U scheduler -d spatial -w -c "CALL vzd.nivkis_address_proc()"

# encumbrance
mkdir encumbrance
cd encumbrance
wget -q https://data.gov.lv/dati/dataset/be841486-4af9-4d38-aa14-6502a2ddb517/resource/ca8a415c-a894-427f-b14d-d1e44c582620/download/encumbrance.zip
unzip -q encumbrance.zip
rm encumbrance.zip
psql -U scheduler -d spatial -w -c "DROP TABLE IF EXISTS vzd.nivkis_encumbrance_tmp;"
psql -U scheduler -d spatial -w -c "CREATE TABLE IF NOT EXISTS vzd.nivkis_encumbrance_tmp (data XML);"
for file in $(find . -name '*.xml'); do
  echo "\COPY vzd.nivkis_encumbrance_tmp FROM" "${file}" >> script.sql
done
psql -U scheduler -d spatial -w -f script.sql
rm script.sql
cd ..
rm -r encumbrance
psql -U scheduler -d spatial -w -c "CALL vzd.nivkis_encumbrance_proc()"

# mark
mkdir mark
cd mark
wget -q https://data.gov.lv/dati/dataset/be841486-4af9-4d38-aa14-6502a2ddb517/resource/9417c9f2-5961-492d-8606-ca84a5b41386/download/mark.zip
unzip -q mark.zip
rm mark.zip
psql -U scheduler -d spatial -w -c "DROP TABLE IF EXISTS vzd.nivkis_mark_tmp;"
psql -U scheduler -d spatial -w -c "CREATE TABLE IF NOT EXISTS vzd.nivkis_mark_tmp (data XML);"
for file in $(find . -name '*.xml'); do
  echo "\COPY vzd.nivkis_mark_tmp FROM" "${file}" >> script.sql
done
psql -U scheduler -d spatial -w -f script.sql
rm script.sql
cd ..
rm -r mark
psql -U scheduler -d spatial -w -c "CALL vzd.nivkis_mark_proc()"

# valuation
mkdir valuation
cd valuation
wget -q https://data.gov.lv/dati/dataset/be841486-4af9-4d38-aa14-6502a2ddb517/resource/35a2dbfa-e4b9-41d5-88d0-e1393115dcb1/download/valuation.zip
unzip -q valuation.zip
rm valuation.zip
psql -U scheduler -d spatial -w -c "DROP TABLE IF EXISTS vzd.nivkis_valuation_tmp;"
psql -U scheduler -d spatial -w -c "CREATE TABLE IF NOT EXISTS vzd.nivkis_valuation_tmp (data XML);"
for file in $(find . -name '*.xml'); do
  echo "\COPY vzd.nivkis_valuation_tmp FROM" "${file}" >> script.sql
done
psql -U scheduler -d spatial -w -f script.sql
rm script.sql
cd ..
rm -r valuation
psql -U scheduler -d spatial -w -c "CALL vzd.nivkis_valuation_proc()"

# Refresh materialized view nivkis_ekas_rekviziti.
psql -U scheduler -d spatial -w -c "REFRESH MATERIALIZED VIEW vzd.nivkis_ekas_rekviziti;"