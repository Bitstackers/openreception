all: auth contact log message misc reception

clean: 
	-rm out

auth: outfolder
	cd AuthServer/ && /usr/bin/pub get 
	dart2js --output-type=dart --checked --verbose --out=out/AuthServer.dart --categories=Server AuthServer/bin/authserver.dart

contact: outfolder
	cd ContactServer/ && pub get 
	dart2js --output-type=dart --checked --verbose --out=out/ContactServer.dart --categories=Server ContactServer/bin/contactserver.dart

log: outfolder
	cd LogServer/ && pub get 
	dart2js --output-type=dart --checked --verbose --out=out/LogServer.dart --categories=Server LogServer/bin/logserver.dart

message: outfolder
	cd MessageServer/ && pub get
	dart2js --output-type=dart --checked --verbose --out=out/MessageServer.dart --categories=Server MessageServer/bin/messageserver.dart

misc: outfolder
	cd MiscServer/ && pub get
	dart2js --output-type=dart --checked --verbose --out=out/MiscServer.dart --categories=Server MiscServer/bin/miscserver.dart

outfolder:
	-mkdir out

reception: outfolder
	cd ReceptionServer/ && pub get
	dart2js --output-type=dart --checked --verbose --out=out/ReceptionServer.dart --categories=Server ReceptionServer/bin/receptionserver.dart
