include makefile.setup

GIT_REV=$(shell git rev-parse --short HEAD)
SNAPSHOT=${PREFIX}/drvupld-${GIT_REV}.dart.snapshot

all: drvupld

drvupld:
	-@mkdir -p ${PREFIX}
	pub get && pub --no-package-symlinks upgrade
	dart --snapshot=${SNAPSHOT} bin/drvupld.dart
	ln -f -s ${SNAPSHOT} ${PREFIX}/drvupld.dart

remove-symlink:
	-rm ${PREFIX}/drvupld.dart
