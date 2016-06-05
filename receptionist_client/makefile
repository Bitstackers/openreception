BUILD_DIR?=build

all: build

build: pubspec.lock web/configuration_url.dart
	@pub build

distclean:
	-rm -r build

pub_upgrade:
	pub upgrade

pubspec.lock: pubspec.yaml
	pub upgrade

default-config: web/configuration_url.dart

web/configuration_url.dart: web/configuration_url.dart.dist
	install web/configuration_url.dart.dist web/configuration_url.dart

js-build: $(BUILD_DIR)
	pub build --output=$(BUILD_DIR)

$(BUILD_DIR):
	-@mkdir $(BUILD_DIR)

.PHONY: build

dependencies: pubspec.lock
