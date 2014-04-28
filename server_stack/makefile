PWD=$(shell pwd)
DB_SRC=${PWD}/db_src
DB_SCHEMA=postgresql/schema.sql
DB_DATA=postgresql/test_data.sql
TIMESTAMP=$(shell date +%s)

PREFIX?=/usr/local/databaseservers

OUTPUT_DIRECTORY=out

AuthBinary=AuthServer.dart
ContactBinary=ContactServer.dart
LogBinary=LogServer.dart
MessageBinary=MessageServer.dart
MiscBinary=MiscServer.dart
ReceptionBinary=ReceptionServer.dart

-include makefile.dbsetup

all: auth contact log message misc reception $(OUTPUT_DIRECTORY)/NotificationServer.dart

configs: */bin/config.json.dist
	for source in */bin/config.json.dist; do \
	   target=$${source%%.dist}; \
	   cp -np $${source} $${target}; \
	done

auth: $(OUTPUT_DIRECTORY)
	cd AuthServer/ && pub get 
	dart2js --output-type=dart --checked --verbose --out=$(OUTPUT_DIRECTORY)/${AuthBinary} --categories=Server AuthServer/bin/authserver.dart

contact: $(OUTPUT_DIRECTORY)
	cd ContactServer/ && pub get 
	dart2js --output-type=dart --checked --verbose --out=$(OUTPUT_DIRECTORY)/${ContactBinary} --categories=Server ContactServer/bin/contactserver.dart

log: $(OUTPUT_DIRECTORY)
	cd LogServer/ && pub get 
	dart2js --output-type=dart --checked --verbose --out=$(OUTPUT_DIRECTORY)/${LogBinary} --categories=Server LogServer/bin/logserver.dart

message: $(OUTPUT_DIRECTORY)
	cd MessageServer/ && pub get
	dart2js --output-type=dart --checked --verbose --out=$(OUTPUT_DIRECTORY)/${MessageBinary} --categories=Server MessageServer/bin/messageserver.dart

misc: $(OUTPUT_DIRECTORY)
	cd MiscServer/ && pub get
	dart2js --output-type=dart --checked --verbose --out=$(OUTPUT_DIRECTORY)/${MiscBinary} --categories=Server MiscServer/bin/miscserver.dart

reception: $(OUTPUT_DIRECTORY)
	cd ReceptionServer/ && pub get
	dart2js --output-type=dart --checked --verbose --out=${OUTPUT_DIRECTORY}/${ReceptionBinary} --categories=Server ReceptionServer/bin/receptionserver.dart

$(OUTPUT_DIRECTORY):
	mkdir -p $(OUTPUT_DIRECTORY)

clean: 
	rm -rf $(OUTPUT_DIRECTORY)

install: all
	install --directory ${PREFIX}
	install --target-directory=${PREFIX} out/*.dart

install-default-config:
	@install --directory ${PREFIX}
	@install AuthServer/bin/config.json.dist ${PREFIX}/authconfig.json
	@install ContactServer/bin/config.json.dist ${PREFIX}/contactconfig.json
	@install LogServer/bin/config.json.dist ${PREFIX}/logconfig.json
	@install MessageServer/bin/config.json.dist ${PREFIX}/messageconfig.json
	@install MiscServer/bin/config.json.dist ${PREFIX}/miscconfig.json
	@install ReceptionServer/bin/config.json.dist ${PREFIX}/receptionconfig.json

# This rule depends on a .pgpass file containing the password for the user specified in makefile.dbsetup
latest_db_install:
	make -C ${DB_SRC} ${DB_SCHEMA} ${DB_DATA}
	psql -c "SELECT pid, (SELECT pg_terminate_backend(pid)) as killed from pg_stat_activity WHERE datname = '${PGDB}'" --host=${PGHOST} --username=${PG_SUPER_USER} -w;
	-psql -c "ALTER DATABASE ${PGDB} RENAME TO ${PGDB}_${TIMESTAMP}" --host=${PGHOST} --username=${PG_SUPER_USER} -w
	psql -c "CREATE DATABASE ${PGDB} WITH OWNER = ${PGUSER} ENCODING='UTF8' TEMPLATE = template0;" --host=${PGHOST} --username=${PG_SUPER_USER} -w
	PGOPTIONS='--client-min-messages=warning' psql ${PGARGS} --dbname=${PGDB} --file=${DB_SRC}/${DB_SCHEMA} --host=${PGHOST} --username=${PGUSER} -w
	LANG=C.UTF-8 PGOPTIONS='--client-min-messages=warning' psql ${PGARGS} --dbname=${PGDB} --file=${DB_SRC}/${DB_DATA} --host=${PGHOST} --username=${PGUSER} -w

$(OUTPUT_DIRECTORY)/NotificationServer.dart : NotificationServer/bin/notificationserver.dart NotificationServer/lib/*.dart
	mkdir -p "`dirname $@`"
	cd `basename $@ .dart` && pub get
	dart2js --output-type=dart --checked --verbose --out=$@ --categories=Server $<

