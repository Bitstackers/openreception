# OpenReceptionFramework

This framework contains model classes, interface clients and utilities meant to be
shared among servers, clients, tools and tests.

## Installation

The framework is a support library, so there is no installation step.

## Running tests:

In order to run the unit tests for the framework, you can invoke the test rule.

   make tests

### Enabling output:

If you also want to enable logging output (useful for further debugging) you may
set the environment variable `LOGLEVEL`. For example, to `ALL` to enable all log
output:

   LOGLEVEL=ALL make tests

Valid values are: ALL, FINEST, FINER, FINE, CONFIG, INFO, WARNING, SEVERE, SHOUT, OFF.
These correspond to the values found in the Dart logging package.
