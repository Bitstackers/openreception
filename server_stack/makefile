all: organization contact

organization: outfolder
	cd OrganizationServer/ && pub get && pub upgrade
	dart2js --output-type=dart --checked --terse --verbose --out=out/OrganizationServer.dart --categories=Server OrganizationServer/bin/organizationserver.dart

contact: outfolder
	cd ContactServer/ && pub get && pub upgrade
	dart2js --output-type=dart --checked --terse --verbose --out=out/ContactServer.dart --categories=Server ContactServer/bin/contactserver.dart

outfolder:
	-mkdir out