ORC
==================

Receptionist browser-based console for use with the ServerStack [1] which is
required to make the client run.

This project currently holds an implementation of the client, written in Dart.

# Configuration
Copy the file web/config/configuration_url.dart.dist to
web/config/configuration_url.dart and update to match the hostname of the
config server in ServerStack.

# Build
Run `pub build` to build the JavaScript sources and deploy on any HTTP server
able to serve plain files. An example config for Nginx is located in the
`extra/` folder.

- Enjoy.

[1] https://github.com/Bitstackers/ServerStack
