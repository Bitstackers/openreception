AUTH_CACHE_STORAGE=/tmp/tokens

dependencies:
	pub get

tests:
	@dart bin/servertests.dart > results.xml

tests-plain-output:
	@dart bin/servertests.dart --no-xml

bin/basic_agent: support_tools/src/basic_agent.c
	make -C support_tools deps_install
	(cd support_tools && make basic_agent)
	-mkdir -p bin
	mv support_tools/basic_agent bin/

install_dummy_tokens:
	install --directory         ${AUTH_CACHE_STORAGE}
	install magic_tokens/*.json ${AUTH_CACHE_STORAGE}

analyze-all: analyze analyze-hints

analyze:
	@(dartanalyzer --no-hints --fatal-warnings bin/*.dart lib/*.dart)

analyze-hints:
	@echo "! (dartanalyzer bin/*.dart lib/*.dart | grep '^\[')" | bash

.PHONY: bin/basic_agent
