/*                 Copyright (C) 2016-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

library dumpconfig_command;

import 'package:args/command_runner.dart';

import 'configuration.dart';
import 'logger.dart';

class DumpConfigCommand extends Command {
  final Configuration _config;
  final description = 'Dump the current configuration to STDOUT.';
  final Logger _log;
  final name = 'dumpconfig';

  /**
   * Constructor.
   */
  DumpConfigCommand(
      List<String> args, Configuration this._config, Logger this._log) {
    argParser.parse(args);
  }

  void run() {
    _log.info(_config.toString());
  }
}
