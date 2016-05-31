-include makefile.setup

GIT_REV=$(shell git rev-parse --short HEAD)
SNAPSHOT=${PREFIX}/cdrctl-${GIT_REV}.dart.snapshot

all: cdrctl

default-config: makefile.setup

makefile.setup:
	install makefile.setup.dist makefile.setup

cdrctl:
	-@mkdir -p ${PREFIX}
	pub get && pub --no-package-symlinks upgrade
	dart --snapshot=${SNAPSHOT} bin/cdrctl.dart
	ln -f -s ${SNAPSHOT} ${PREFIX}/cdrctl.dart

remove-symlink:
	-rm ${PREFIX}/cdrctl.dart

dependencies: pubspec.lock

pubspec.lock: pubspec.yaml
	@pub upgrade

