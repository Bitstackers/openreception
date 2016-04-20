HOME=$(CURDIR)

all: build

build: pubspec.lock web/configuration_url.dart
	@pub build

distclean:
	-rm -r build

pub_upgrade:
	pub upgrade

pubspec.lock: pubspec.yaml
	pub upgrade


web/configuration_url.dart: web/configuration_url.dart.dist
	install web/configuration_url.dart.dist web/configuration_url.dart

.PHONY: build
