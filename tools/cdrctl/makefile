include makefile.setup

GIT_REV=$(shell git rev-parse --short HEAD)
SNAPSHOT=${PREFIX}/cdrctl-${GIT_REV}.dart.snapshot

all: cdrctl

cdrctl:
	-@mkdir -p ${PREFIX}
	pub get && pub --no-package-symlinks upgrade
	dart --snapshot=${SNAPSHOT} bin/cdrctl.dart
	ln -f -s ${SNAPSHOT} ${PREFIX}/cdrctl.dart

remove-symlink:
	-rm ${PREFIX}/cdrctl.dart
