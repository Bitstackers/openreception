HOME=$(CURDIR)

all: build

build: pubspec.lock
	@pub build

distclean:
	-rm -r build

pub_upgrade:
	pub upgrade

pubspec.lock: pubspec.yaml
	pub upgrade

.PHONY: build
