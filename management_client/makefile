BUILD_DIR?=build

all: js-build

js-build: $(BUILD_DIR)
	pub build --output=$(BUILD_DIR)

$(BUILD_DIR):
	-@mkdir $(BUILD_DIR)

dependencies: pubspec.lock

pubspec.lock: pubspec.yaml
	@pub upgrade

