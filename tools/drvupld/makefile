-include makefile.setup

GIT_REV=$(shell git rev-parse --short HEAD)
SNAPSHOT=${PREFIX}/drvupld-${GIT_REV}.dart.snapshot

all: drvupld

default-config: makefile.setup

makefile.setup:
	install makefile.setup.dist makefile.setup

drvupld:
	-@mkdir -p ${PREFIX}
	pub get && pub --no-package-symlinks upgrade
	dart --snapshot=${SNAPSHOT} bin/drvupld.dart
	ln -f -s ${SNAPSHOT} ${PREFIX}/drvupld.dart

remove-symlink:
	-rm ${PREFIX}/drvupld.dart

dependencies: pubspec.lock

pubspec.lock: pubspec.yaml
	@pub upgrade

