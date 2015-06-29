-include makefile.setup

PWD=$(shell pwd)
DB_SRC=${PWD}/db_src
DB_SCHEMA=schema.sql
DB_DATA=test_data_$(TESTDATA_LANG).sql
TIMESTAMP=$(shell date +%s)

PREFIX?=/usr/local/databaseservers

OUTPUT_DIRECTORY=out

AuthBinary=AuthServer.dart
CallFlowBinary=CallFlow.dart
ContactBinary=ContactServer.dart
MessageBinary=MessageServer.dart
MessageDispatcherBinary=MessageDispatcher.dart
MiscBinary=MiscServer.dart
NotificationBinary=NotificationServer.dart
ReceptionBinary=ReceptionServer.dart
SpawnerBinary=Spawner.dart


all: $(OUTPUT_DIRECTORY) auth callflow contact message messagedispatcher misc reception spawner notification

analyze-all: analyze analyze-hints

configs: */bin/config.json.dist
	for source in */bin/config.json.dist; do \
	   target=$${source%%.dist}; \
	   cp -np $${source} $${target}; \
	done

analyze:
	@(dartanalyzer --no-hints --fatal-warnings bin/*.dart)

analyze-hints:
	@echo "! (dartanalyzer bin/*.dart | grep '^\[')" | bash

dependency:
	pub get

upgrade-dependency:
	pub upgrade

auth: 
	dart2js --output-type=dart --checked --verbose --out=$(OUTPUT_DIRECTORY)/${AuthBinary} --categories=Server bin/authserver.dart

callflow: 
	dart2js --output-type=dart --checked --verbose --out=$(OUTPUT_DIRECTORY)/${CallFlowBinary} --categories=Server bin/callflowcontrol.dart

contact: 
	dart2js --output-type=dart --checked --verbose --out=$(OUTPUT_DIRECTORY)/${ContactBinary} --categories=Server bin/contactserver.dart

message: 
	dart2js --output-type=dart --checked --verbose --out=$(OUTPUT_DIRECTORY)/${MessageBinary} --categories=Server bin/messageserver.dart

messagedispatcher: 
	dart2js --output-type=dart --checked --verbose --out=$(OUTPUT_DIRECTORY)/${MessageDispatcherBinary} --categories=Server bin/messagedispatcher.dart

misc: 
	dart2js --output-type=dart --checked --verbose --out=$(OUTPUT_DIRECTORY)/${MiscBinary} --categories=Server bin/configserver.dart

notification:
	dart2js --output-type=dart --checked --verbose --out=$(OUTPUT_DIRECTORY)/${NotificationBinary} --categories=Server bin/notificationserver.dart

reception: 
	dart2js --output-type=dart --checked --verbose --out=${OUTPUT_DIRECTORY}/${ReceptionBinary} --categories=Server bin/receptionserver.dart

spawner: 
	dart2js --output-type=dart --checked --verbose --out=${OUTPUT_DIRECTORY}/${SpawnerBinary} --categories=Server bin/spawner.dart

$(OUTPUT_DIRECTORY):
	mkdir -p $(OUTPUT_DIRECTORY)

clean: 
	rm -rf $(OUTPUT_DIRECTORY)

install: all
	install --directory ${PREFIX}
	install --target-directory=${PREFIX} $(OUTPUT_DIRECTORY)/*.dart

install-default-config:
	@install --directory ${PREFIX}
	@install bin/config.json.dist ${PREFIX}/config.json

install_db:
	PGOPTIONS='--client-min-messages=warning' psql ${PGARGS} --dbname=${PGDB} --file=${DB_SRC}/${DB_SCHEMA} --host=${PGHOST} --username=${PGUSER} -w

install_db_test_data:
	LANG=C.UTF-8 PGOPTIONS='--client-min-messages=warning' psql ${PGARGS} --dbname=${PGDB} --file=${DB_SRC}/${DB_DATA} --host=${PGHOST} --username=${PGUSER} -w

# This rule depends on a .pgpass file containing the password for the user specified in makefile.dbsetup
latest_db_install:
	make -C ${DB_SRC} ${DB_SCHEMA} ${DB_DATA}
	psql -c "SELECT pid, (SELECT pg_terminate_backend(pid)) as killed from pg_stat_activity WHERE datname = '${PGDB}'" --host=${PGHOST} --username=${PG_SUPER_USER} -w;
	-psql -c "ALTER DATABASE ${PGDB} RENAME TO ${PGDB}_${TIMESTAMP}" --host=${PGHOST} --username=${PG_SUPER_USER} -w
	psql -c "CREATE DATABASE ${PGDB} WITH OWNER = ${PGUSER} ENCODING='UTF8' LC_COLLATE='en_DK.UTF-8' LC_CTYPE='en_DK.UTF-8' TEMPLATE = template0;" --host=${PGHOST} --username=${PG_SUPER_USER} -w
	PGOPTIONS='--client-min-messages=warning' psql ${PGARGS} --dbname=${PGDB} --file=${DB_SRC}/${DB_SCHEMA} --host=${PGHOST} --username=${PGUSER} -w
	LANG=C.UTF-8 PGOPTIONS='--client-min-messages=warning' psql ${PGARGS} --dbname=${PGDB} --file=${DB_SRC}/${DB_DATA} --host=${PGHOST} --username=${PGUSER} -w

#$(OUTPUT_DIRECTORY)/NotificationServer.dart : NotificationServer/bin/notificationserver.dart NotificationServer/lib/*.dart
#	mkdir -p "`dirname $@`"
#	cd `basename $@ .dart` && pub get
#	dart2js --output-type=dart --checked --verbose --out=$@ --categories=Server $<


