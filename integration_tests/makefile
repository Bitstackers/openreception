tests:
	@echo "Nothing to do yet!"
	@false


bin/basic_agent: support_tools/src/basic_agent.c
	make -C support_tools deps_install
	(cd support_tools && make basic_agent)
	mkdir -p bin
	mv support_tools/basic_agent bin/

.PHONY: bin/basic_agent
