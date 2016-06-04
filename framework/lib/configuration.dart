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

library openreception.framework.config;

import 'package:args/args.dart';

class Datastore {
  final EslConfig eslconfig;

  const Datastore({EslConfig this.eslconfig: const EslConfig()});

  /**
   *
   */
  factory Datastore.fromArgs(ArgResults results) {
    final EslConfig eslconfig = new EslConfig.fromArgs(results);

    return new Datastore(eslconfig: eslconfig);
  }

  /**
   *
   */
  factory Datastore.defaults() => const Datastore();
}

/**
 * ESL configuration values.
 */
class EslConfig {
  final String hostname;
  final String password;
  final int port;

  /**
   *
   */
  const EslConfig(
      {String this.hostname: 'localhost',
      String this.password: 'ClueCon',
      int this.port: 8021});

  /**
   *
   */
  String toDsn() => password + '@' + hostname + ':' + port.toString();

  /**
   *
   */
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

  /**
   *
   */
  factory EslConfig.fromArgs(ArgResults results) {
    final String hostname = results['esl-hostname'];
    final String password = results['esl-password'];
    final int port = int.parse(results['esl-port']);

    return new EslConfig(hostname: hostname, port: port, password: password);
  }

  /**
   *
   */
  ArgParser get argParser {
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
