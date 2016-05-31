all: default-configs dependencies	

analyze-all:
	-make -C framework analyze
	-make -C server_stack analyze

dependencies:
	-make -C framework dependencies
	-make -C integration_tests dependencies
	-make -C management_client dependencies
	-make -C receptionist_client dependencies
	-make -C server_stack dependencies
	-make -C tools/cdrctl dependencies
	-make -C tools/client_app_server dependencies
	-make -C tools/drvupld dependencies
	-make -C tools/or_migrate dependencies
	-make -C tools/wavadjust dependencies

default-configs:
	-make -C integration_tests default-config
	-make -C receptionist_client default-config
	-make -C server_stack default-config
	-make -C tools/cdrctl default-config
	-make -C tools/client_app_server default-config
	-make -C tools/drvupld default-config
	-make -C tools/wavadjust default-config

