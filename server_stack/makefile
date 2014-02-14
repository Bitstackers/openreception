PWD=$(shell pwd)
DB_SRC=${PWD}/db_src
DB_SCHEMA=postgresql/schema.sql
DB_DATA=postgresql/test_data.sql
TIMESTAMP=$(shell date +%s)

-include makefile.dbsetup

all: auth contact log message misc reception

OUTPUT_DIRECTORY=out

auth: outfolder
	cd AuthServer/ && pub get 
	dart2js --output-type=dart --checked --verbose --out=$(OUTPUT_DIRECTORY)/AuthServer.dart --categories=Server AuthServer/bin/authserver.dart

contact: outfolder
	cd ContactServer/ && pub get 
	dart2js --output-type=dart --checked --verbose --out=$(OUTPUT_DIRECTORY)/ContactServer.dart --categories=Server ContactServer/bin/contactserver.dart

log: outfolder
	cd LogServer/ && pub get 
	dart2js --output-type=dart --checked --verbose --out=$(OUTPUT_DIRECTORY)/LogServer.dart --categories=Server LogServer/bin/logserver.dart

message: outfolder
	cd MessageServer/ && pub get
	dart2js --output-type=dart --checked --verbose --out=$(OUTPUT_DIRECTORY)/MessageServer.dart --categories=Server MessageServer/bin/messageserver.dart

misc: outfolder
	cd MiscServer/ && pub get
	dart2js --output-type=dart --checked --verbose --out=$(OUTPUT_DIRECTORY)/MiscServer.dart --categories=Server MiscServer/bin/miscserver.dart

reception: outfolder
	cd ReceptionServer/ && pub get
	dart2js --output-type=dart --checked --verbose --out=$(OUTPUT_DIRECTORY)/ReceptionServer.dart --categories=Server ReceptionServer/bin/receptionserver.dart

outfolder:
	mkdir -p $(OUTPUT_DIRECTORY)

clean: 
	rm -rf $(OUTPUT_DIRECTORY)

# This rule depends on a .pgpass file containing the password for the user specified in makefile.dbsetup
latest_db_install:
	make -C ${DB_SRC} ${DB_SCHEMA} ${DB_DATA}
	psql -c "SELECT pid, (SELECT pg_terminate_backend(pid)) as killed from pg_stat_activity WHERE datname = '${PGDB}'" --host=${PGHOST} --username=${PG_SUPER_USER} -w;
	-psql -c "ALTER DATABASE ${PGDB} RENAME TO ${PGDB}_${TIMESTAMP}" --host=${PGHOST} --username=${PG_SUPER_USER} -w
	psql -c "CREATE DATABASE ${PGDB} WITH OWNER = ${PGUSER} ENCODING='UTF8' TEMPLATE = template0;" --host=${PGHOST} --username=${PG_SUPER_USER} -w
	PGOPTIONS='--client-min-messages=warning' psql ${PGARGS} --dbname=${PGDB} --file=${DB_SRC}/${DB_SCHEMA} --host=${PGHOST} --username=${PGUSER} -w
	LANG=C.UTF-8 PGOPTIONS='--client-min-messages=warning' psql ${PGARGS} --dbname=${PGDB} --file=${DB_SRC}/${DB_DATA} --host=${PGHOST} --username=${PGUSER} -w
