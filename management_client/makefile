BUILD_DIR?=build

all: js-build

js-build: $(BUILD_DIR)
	pub build --output=$(BUILD_DIR)

$(BUILD_DIR):
	-@mkdir $(BUILD_DIR)

dependencies: pubspec.lock

pubspec.lock: pubspec.yaml
	@pub upgrade

analyze:
	@(dartanalyzer --no-hints --fatal-warnings web/client.dart)

analyze-hints:
	@echo "! (dartanalyzer web/client.dart | grep '^\[')" | bash
