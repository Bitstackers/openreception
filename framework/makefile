all: fetch-dependencies upgrade-dependencies
	@echo Nothing to do for a library, how about 'make tests' instead?

fetch-dependencies:
	@echo ============================
	@echo == Getting dependencies.. ==
	@echo ============================
	@pub get
	@echo ===============================
	@echo == Getting dependencies done ==
	@echo ===============================
	@echo

upgrade-dependencies:
	@echo ==============================
	@echo == Upgrading dependencies.. ==
	@echo ==============================
	@pub upgrade
	@echo =================================
	@echo == Upgrading dependencies done ==
	@echo =================================
	@echo

tests:
	@dart test/tests.dart
