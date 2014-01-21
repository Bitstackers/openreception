-include makefile.dbsetup

all: test.db

install-sqlite:
	cp test.db ../exe/sqlite/customers.db 

install-pgsql:
	@echo Deploying database schema on ${PGHOST} using databasename ${PGDBNAME}

sources: postgresql/schema.sql postgresql/test_data.sql sqlite/schema.sql sqlite/test_data.sql

test.db: sqlite/schema.sql sqlite/test_data.sql
	rm -f test.db
	sqlite3 test.db < sqlite/schema.sql
	sqlite3 test.db < sqlite/test_data.sql

postgresql/schema.sql: schema.sql to_postgresql
	mkdir -p postgresql
	./to_postgresql schema.sql

postgresql/test_data.sql: test_data.sql to_postgresql
	mkdir -p postgresql
	./to_postgresql test_data.sql

sqlite/schema.sql: schema.sql to_sqlite
	mkdir -p sqlite
	./to_sqlite schema.sql

sqlite/test_data.sql: test_data.sql to_sqlite
	mkdir -p sqlite
	./to_sqlite test_data.sql

clean:
	rm -f */schema.sql.orig
	rm -f */schema.sql.rej
	rm -f */test_data.sql.orig
	rm -f */test_data.sql.rej

distclean: clean
	rm -f test.db
	rm -f */schema.sql
	rm -f */test_data.sql

