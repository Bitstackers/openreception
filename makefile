all: default-configs dependencies servers

BUILD_DIR?=build

analyze-quick:
	@make -C framework analyze
	@make -C server_stack analyze
	@make -C receptionist_client analyze
	@make -C integration_tests analyze
	@make -C management_client analyze

analyze-all:
	@make -C framework analyze-all
	@make -C server_stack analyze-all
	@make -C server_stack analyze-all
	@make -C server_stack analyze-all

dependencies:
	@make -C framework dependencies
	@make -C integration_tests dependencies
	@make -C management_client dependencies
	@make -C receptionist_client dependencies
	@make -C server_stack dependencies
	@make -C tools/cdrctl dependencies
	@make -C tools/client_app_server dependencies
	@make -C tools/drvupld dependencies
	@make -C tools/or_migrate dependencies
	@make -C tools/wavadjust dependencies

default-configs:
	@make -C integration_tests default-config
	@make -C receptionist_client default-config
	@make -C server_stack default-config
	@make -C tools/cdrctl default-config
	@make -C tools/drvupld default-config
	@make -C tools/wavadjust default-config

servers: $(BUILD_DIR)
	BUILD_DIR=../$(BUILD_DIR)/server_stack make -C server_stack snapshots-no-rev

receptionist-client: $(BUILD_DIR)
	BUILD_DIR=../$(BUILD_DIR)/receptionist_client make -C receptionist_client js-build

management-client:
	BUILD_DIR=../$(BUILD_DIR)/management_client make -C management_client js-build

toolset:
	BUILD_DIR=../$(BUILD_DIR)/tools make -C integration_tests datastore_ctl stack_runner


$(BUILD_DIR):
	mkdir $(BUILD_DIR)
