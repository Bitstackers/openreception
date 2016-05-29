include makefile.setup

GIT_REV=$(shell git rev-parse --short HEAD)
SNAPSHOT=${PREFIX}/wavadjust-${GIT_REV}.dart.snapshot

all: wavadjust

wavadjust:
	-@mkdir -p ${PREFIX}
	pub get && pub --no-package-symlinks upgrade
	dart --snapshot=${SNAPSHOT} bin/wavadjust.dart
	ln -f -s ${SNAPSHOT} ${PREFIX}/wavadjust.dart

remove-symlink:
	-rm ${PREFIX}/wavadjust.dart
