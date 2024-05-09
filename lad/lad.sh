#!/bin/bash
export PGPASSWORD=
# Izsauc procedūru lad.field_blocks_proc(), kas atjauno lauku bloku datus.
psql -U scheduler -d spatial -w -c "CALL lad.field_blocks_proc()"
# Izsauc procedūru lad.fields_proc(), kas atjauno lauku datus.
psql -U scheduler -d spatial -w -c "CALL lad.fields_proc()"