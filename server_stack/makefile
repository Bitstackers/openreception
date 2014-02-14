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

