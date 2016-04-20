all: fetch-dependencies upgrade-dependencies
	@echo Nothing to do for a library, how about 'make tests' instead?

tests: pubspec.lock
	@dart test/tests.dart

tests-text-output:
	@dart test/tests.dart text-output

analyze: pubspec.lock
	@dartanalyzer --no-hints --fatal-warnings lib/*.dart
	@dartanalyzer --no-hints --fatal-warnings test/*.dart

analyze-hints: pubspec.lock
	@echo "! (dartanalyzer lib/*.dart | grep '^\[')" | bash
	@echo "! (dartanalyzer test/*.dart | grep '^\[')" | bash

analyze-all: analyze analyze-hints

pubspec.lock: pubspec.yaml
	@pub upgrade

