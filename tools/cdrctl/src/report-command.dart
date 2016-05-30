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

library report_command;

import 'dart:async';

import 'package:args/command_runner.dart';

import 'configuration.dart';
import 'logger.dart';
import 'report.dart';

class ReportCommand extends Command {
  final String _argDirection = 'direction';
  final String _argFrom = 'from';
  final String _argIncludeCdrFiles = 'include-cdr-files';
  final String _argJsonOutput = 'json';
  final String _argKind = 'kind';
  final String _argPrettyPrint = 'pretty-print';
  final String _argRid = 'rid';
  final String _argTo = 'to';
  final String _argUid = 'uid';
  final Configuration _config;
  final description = 'Output summaries and call lists on STDOUT.';
  final Logger _log;
  final name = 'report';

  /**
   * Constructor.
   */
  ReportCommand(
      List<String> args, Configuration this._config, Logger this._log) {
    argParser
      ..addFlag(_argIncludeCdrFiles,
          help:
              'Add list of CDR files. Only applicable to summaries. Defaults to false',
          defaultsTo: false,
          negatable: false)
      ..addFlag(_argJsonOutput,
          help: 'Output as JSON. Does not fold agent summary data',
          defaultsTo: false,
          negatable: false)
      ..addFlag(_argPrettyPrint,
          help:
              'Pretty print the JSON output. Only applicable if --json is set',
          defaultsTo: false,
          negatable: false)
      ..addOption(_argDirection,
          abbr: 'd',
          help:
              'Filter calls on direction. Defaults to "both". Only applicable to --kind list',
          allowed: ['both', 'inbound', 'outbound'],
          allowedHelp: {
            'both': 'Return both inbound and outbound calls\n',
            'inbound': 'Return only inbound calls\n',
            'outbound': 'Return only outbound calls\n'
          },
          defaultsTo: 'both')
      ..addOption(_argFrom,
          abbr: 'f',
          help:
              'Start of report. Optional. Must be an ISO 8601 formatted date/time string\n'
              'Defaults to beginning (midnight) of today\n'
              'Dates are parsed as follows (for both --from and --to):\n'
              '  2016-02-17 is parsed to 2016-02-17 00:00:00.000\n'
              '  "2016-02-17 16:30:45" is parsed to 2016-02-17 16:30:45.000\n'
              '  "2016-02-17 08:00:00Z" is parsed to 2016-02-17 08:00:00.000Z\n'
              '  2016-02-17T13:59:59.999 is parsed to 2016-02-17 13:59:59.999')
      ..addOption(_argKind,
          abbr: 'k',
          help: 'The kind of report to output. Defaults to "summary"',
          allowed: ['list', 'summary'],
          allowedHelp: {
            'list': 'A list of calls. Optionally filter on --rid and/or --uid\n'
                'Lists everything in the absence of --rid / --uid\n',
            'summary': 'Summary of calls. Optionally filter on --rid\n'
                'Summarize everything in the absence of --rid\n'
                'NOTE: Setting the --include-cdr-files flag may result in very large output\n'
                'Summaries are for days, not time of day\n'
          },
          defaultsTo: 'summary')
      ..addOption(_argRid,
          abbr: 'r',
          help:
              'Reception id. Optional. If set, reports are only done for this specific reception\n'
              'Can be set multiple times with comma separated values: -r 1,2,3,4',
          allowMultiple: true,
          splitCommas: true)
      ..addOption(_argTo,
          abbr: 't',
          help:
              'End of report. Optional. Must be an ISO 8601 formatted date/time string\n'
              'Defaults to end of today (1 millisecond before midnight). See --from for parsing examples')
      ..addOption(_argUid,
          abbr: 'u',
          help:
              'User id. Optional. If set, reports are only done for this specific user.\n'
              'Can be set multiple times with comma separated values: -u 1,2,3,4\n'
              'Only applicable to --kind list',
          allowMultiple: true,
          splitCommas: true);

    argParser.parse(args);
  }

  Future run() async {
    /// --from and --to
    final DateTime now = new DateTime.now();
    DateTime from = new DateTime(now.year, now.month, now.day);
    DateTime to = new DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
    if (argResults.wasParsed(_argFrom)) {
      from = DateTime.parse(argResults[_argFrom]);
    }

    if (argResults.wasParsed(_argTo)) {
      to = DateTime.parse(argResults[_argTo]);
    }

    if (to.isBefore(from) || to.isAtSameMomentAs(from)) {
      throw new UsageException('--to time is equal to or before --from', '');
    }

    /// We treat --rid as string because all filtering done on this value is
    /// against strings
    List<String> rids = new List<String>();
    if (argResults.wasParsed(_argRid)) {
      rids = (argResults[_argRid] as List<String>)
          .where((String rid) => rid.trim().isNotEmpty)
          .toList(growable: false);
    }

    /// We treat --uid as string because nearly all filtering done on this value
    /// is against strings
    List<String> uids = new List<String>();
    if (argResults.wasParsed(_argUid)) {
      uids = (argResults[_argUid] as List<String>)
          .where((String uid) => uid.trim().isNotEmpty)
          .toList(growable: false);
    }

    /// Direction
    final String direction = argResults[_argDirection];

    /// Kind
    final String kind = argResults[_argKind];

    return await dispatch(
        direction,
        kind,
        from,
        to,
        rids,
        uids,
        argResults[_argIncludeCdrFiles],
        argResults[_argJsonOutput],
        argResults[_argPrettyPrint],
        _config,
        _log);
  }
}
