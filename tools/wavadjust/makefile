-include makefile.setup

GIT_REV=$(shell git rev-parse --short HEAD)
SNAPSHOT=${PREFIX}/wavadjust-${GIT_REV}.dart.snapshot

all: wavadjust

default-config: makefile.setup

makefile.setup:
	install makefile.setup.dist makefile.setup

wavadjust:
	-@mkdir -p ${PREFIX}
	pub get && pub --no-package-symlinks upgrade
	dart --snapshot=${SNAPSHOT} bin/wavadjust.dart
	ln -f -s ${SNAPSHOT} ${PREFIX}/wavadjust.dart

remove-symlink:
	-rm ${PREFIX}/wavadjust.dart

dependencies: pubspec.lock

pubspec.lock: pubspec.yaml
	@pub upgrade

