all: pubspec.lock
	@echo Nothing to do for a library, how about 'make tests' instead?

upgrade-packages:
	@pub upgrade

tests: pubspec.lock
	@dart test/tests.dart > results.xml

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

