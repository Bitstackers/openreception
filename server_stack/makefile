all: organization contact

organization: outfolder
	cd OrganizationServer/
	pub get
	pub upgrade
	dart2js --output-type=dart --checked --terse --verbose --out=../out/OrganizationServer.dart --categories=Server bin/organizationserver.dart
	cd ..

contact: outfolder
	cd ContactServer/
	pub get
	pub upgrade
	dart2js --output-type=dart --checked --terse --verbose --out=../out/OrganizationServer.dart --categories=Server bin/contactserver.dart
	cd ..

outfolder:
	-mkdir out