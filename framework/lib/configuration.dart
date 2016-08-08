/*                  This file is part of OpenReception
                   Copyright (C) 2016-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

/// Common configuration models and parsing functions.
///
/// Currently unused in the stack, but is meant to be implemented as a
/// common method for configuring and launching processes for use with,
/// among others, tests.

library openreception.framework.config;

import 'package:args/args.dart';

/// Configuration class for Datastore service.
class Datastore {
  /// ESL configuration values
  final EslConfig eslconfig;

  /// Creates a new [Datastore] configuration object.
  ///
  /// Optionally takes in [eslconfig], which defaults to a standard config
  /// if omitted.
  const Datastore({EslConfig this.eslconfig: const EslConfig()});

  /// Creates a new [Datastore] configuration object from parsed
  /// agument [results].
  factory Datastore.fromArgs(ArgResults results) {
    final EslConfig eslconfig = new EslConfig.fromArgs(results);

    return new Datastore(eslconfig: eslconfig);
  }

  /// Creates a new [Datastore] object with default values.
  factory Datastore.defaults() => const Datastore();
}

/// Configuration class for ESL configuration values.
class EslConfig {
  /// The hostname of the ESL server.
  final String hostname;

  /// The password for authenticating against the ESL server.
  final String password;

  /// The port of the ESL server.
  final int port;

  /// Creates a new [EslConfig] object.
  ///
  /// Optionally takes in [hostname], [password] and [port] that falls back
  /// to default values if omitted.
  const EslConfig(
      {String this.hostname: 'localhost',
      String this.password: 'ClueCon',
      int this.port: 8021});

  /// Creates a new [EslConfig] object from a [dsn] string.
  ///
  /// A dsn string for [EslConfig] has the form <password>@<host>:<port>,
  /// where the port may be omitted.
  ///
  /// An example of a dsn is `ClueCon@pbx.example:8021`. This example will
  /// create a config that connects to the host `pbx.example` on port `8021`
  /// using password `ClueCon`.
  factory EslConfig.fromDsn(String dsn) {
    String hostname = '';
    String password = '';
    int port = 0;

    {
      final split = dsn.split('@');

      if (split.length > 2) {
        throw new FormatException('Dsn $dsn contains too many "@" characters');
      } else if (split.length == 2) {
        password = split.first;
        dsn = split.last;
      }
    }

    {
      final split = dsn.split(':');
      if (split.length > 2) {
        throw new FormatException('Dsn $dsn contains too many ":" characters');
      } else if (split.length == 2) {
        port = int.parse(split.last);
      }
      hostname = split.first;
    }

    return new EslConfig(hostname: hostname, password: password, port: port);
  }

  /// Creates a new [EslConfig]  configuration object from parsed
  /// agument [results].
  factory EslConfig.fromArgs(ArgResults results) {
    final String hostname = results['esl-hostname'];
    final String password = results['esl-password'];
    final int port = int.parse(results['esl-port']);

    return new EslConfig(hostname: hostname, port: port, password: password);
  }

  /// A dsn represenation of the [EslConfig].
  ///
  /// The representation is suitable for creating a new [EslConfig] object
  /// using the [EslConfig.fromDsn] constructor.
  String toDsn() => password + '@' + hostname + ':' + port.toString();

  /// An [ArgParser] suitable for parsing command line arguments.
  ///
  /// The [ArgParser] may be used to convert arguments into [ArgResults]
  /// that can then be turned into [EslConfig] objects, using the
  /// [EslConfig.fromArgs] constructor.
  static ArgParser get argParser {
    EslConfig defaults = const EslConfig();

    return new ArgParser()
      ..addOption('esl-hostname',
          defaultsTo: defaults.hostname, help: 'The hostname of the ESL server')
      ..addOption('esl-password',
          defaultsTo: defaults.password,
          help: 'The password for the ESL server')
      ..addOption('esl-port',
          defaultsTo: defaults.port.toString(),
          help: 'The port of the ESL server');
  }
}
