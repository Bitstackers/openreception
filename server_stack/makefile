-include makefile.setup

PWD=$(shell pwd)
DB_SRC=${PWD}/db_src
DB_SCHEMA=schema.sql
DB_DATA=test_data_$(TESTDATA_LANG).sql
DB_BASE_DATA=base.sql
TIMESTAMP=$(shell date +%s)

PREFIX?=/opt/openreception/bin

RELEASE=$(shell git tag | tail -n1)
GIT_REV=$(shell git rev-parse --short HEAD)

BUILD_DIR=build

all: $(BUILD_DIR) snapshots

$(BUILD_DIR):
	-@mkdir $(BUILD_DIR)

snapshots: $(BUILD_DIR) \
           $(BUILD_DIR)/authserver-$(GIT_REV).dart \
           $(BUILD_DIR)/callflowcontrol-$(GIT_REV).dart \
           $(BUILD_DIR)/cdrserver-$(GIT_REV).dart \
           $(BUILD_DIR)/configserver-$(GIT_REV).dart \
           $(BUILD_DIR)/contactserver-$(GIT_REV).dart \
           $(BUILD_DIR)/dialplanserver-$(GIT_REV).dart \
           $(BUILD_DIR)/managementserver-$(GIT_REV).dart \
           $(BUILD_DIR)/messagedispatcher-$(GIT_REV).dart \
           $(BUILD_DIR)/messageserver-$(GIT_REV).dart \
           $(BUILD_DIR)/notificationserver-$(GIT_REV).dart \
           $(BUILD_DIR)/receptionserver-$(GIT_REV).dart \
           $(BUILD_DIR)/userserver-$(GIT_REV).dart

build/%-$(GIT_REV).dart: bin/%.dart
	dart --snapshot=$@ $<

analyze-all: analyze analyze-hints

analyze:
	@(dartanalyzer --no-hints --fatal-warnings bin/*.dart)

analyze-hints:
	@echo "! (dartanalyzer bin/*.dart | grep '^\[')" | bash

dependency:
	pub get

upgrade-dependency:
	pub upgrade

clean: 
	-rm -rf $(BUILD_DIR)

install: build
	install --directory ${PREFIX}
	install --target-directory=${PREFIX} $(BUILD_DIR)/authserver-$(GIT_REV).dart
	install --target-directory=${PREFIX} \
           $(BUILD_DIR)/authserver-$(GIT_REV).dart \
           $(BUILD_DIR)/callflowcontrol-$(GIT_REV).dart \
           $(BUILD_DIR)/cdrserver-$(GIT_REV).dart \
           $(BUILD_DIR)/configserver-$(GIT_REV).dart \
           $(BUILD_DIR)/contactserver-$(GIT_REV).dart \
           $(BUILD_DIR)/dialplanserver-$(GIT_REV).dart \
           $(BUILD_DIR)/managementserver-$(GIT_REV).dart \
           $(BUILD_DIR)/messagedispatcher-$(GIT_REV).dart \
           $(BUILD_DIR)/messageserver-$(GIT_REV).dart \
           $(BUILD_DIR)/notificationserver-$(GIT_REV).dart \
           $(BUILD_DIR)/receptionserver-$(GIT_REV).dart \
           $(BUILD_DIR)/userserver-$(GIT_REV).dart

install-symlinks: install
	ln -s ${PREFIX}/authserver-$(GIT_REV).dart ${PREFIX}/authserver.dart
	ln -s ${PREFIX}/callflowcontrol-$(GIT_REV).dart ${PREFIX}/callflowcontrol.dart
	ln -s ${PREFIX}/cdrserver-$(GIT_REV).dart ${PREFIX}/cdrserver.dart
	ln -s ${PREFIX}/configserver-$(GIT_REV).dart ${PREFIX}/configserver.dart
	ln -s ${PREFIX}/contactserver-$(GIT_REV).dart ${PREFIX}/contactserver.dart
	ln -s ${PREFIX}/dialplanserver-$(GIT_REV).dart ${PREFIX}/dialplanserver.dart
	ln -s ${PREFIX}/managementserver-$(GIT_REV).dart ${PREFIX}/managementserver.dart
	ln -s ${PREFIX}/messagedispatcher-$(GIT_REV).dart ${PREFIX}/messagedispatcher.dart
	ln -s ${PREFIX}/messageserver-$(GIT_REV).dart ${PREFIX}/messageserver.dart
	ln -s ${PREFIX}/notificationserver-$(GIT_REV).dart ${PREFIX}/notificationserver.dart
	ln -s ${PREFIX}/receptionserver-$(GIT_REV).dart ${PREFIX}/receptionserver.dart
	ln -s ${PREFIX}/userserver-$(GIT_REV).dart ${PREFIX}/userserver.dart

remove-symlinks: 
	-rm ${PREFIX}/authserver.dart
	-rm ${PREFIX}/callflowcontrol.dart
	-rm ${PREFIX}/cdrserver.dart
	-rm ${PREFIX}/configserver.dart
	-rm ${PREFIX}/contactserver.dart
	-rm ${PREFIX}/dialplanserver.dart
	-rm ${PREFIX}/managementserver.dart
	-rm ${PREFIX}/messagedispatcher.dart
	-rm ${PREFIX}/messageserver.dart
	-rm ${PREFIX}/notificationserver.dart
	-rm ${PREFIX}/receptionserver.dart
	-rm ${PREFIX}/userserver.dart

default-config:
	@install --directory ${PREFIX}
	@install lib/configuration.dart.dist lib/configuration.dart

install_db:
	-psql -c "CREATE DATABASE ${PGDB} WITH OWNER = ${PGUSER} ENCODING='UTF8' LC_COLLATE='en_DK.UTF-8' LC_CTYPE='en_DK.UTF-8' TEMPLATE = template0;" --host=${PGHOST} --username=${PG_SUPER_USER} -w
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

# This rule will DROP this existing database. DO NOT RUN IN PRODUCTION.
remove_test_db:
	psql -c "SELECT pid, (SELECT pg_terminate_backend(pid)) as killed from pg_stat_activity WHERE datname = '${PGDB}'" --host=${PGHOST} --username=${PG_SUPER_USER} -w;
	-psql -c "DROP DATABASE ${PGDB}" --host=${PGHOST} --username=${PG_SUPER_USER} -w

replace_test_db: remove_test_db install_db install_db_test_data

install_db_base_data:
	LANG=C.UTF-8 PGOPTIONS='--client-min-messages=warning' psql ${PGARGS} --dbname=${PGDB} --file=${DB_SRC}/${DB_BASE_DATA} --host=${PGHOST} --username=${PGUSER} -w
