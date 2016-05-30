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

library store_command;

import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as path;

import 'configuration.dart';
import 'google.dart';
import 'logger.dart';
import 'store.dart';

class StoreCommand extends Command {
  final String _argDaemonize = 'daemonize';
  final String _argFile = 'file';
  final String _argSummarize = 'summarize';
  final Configuration _config;
  final description = 'Store CDR files at Google Cloud Storage.\n'
      'Optionally create summary data from the CDR data.';
  final Logger _log;
  final name = 'store';

  /**
   * Constructor.
   */
  StoreCommand(
      List<String> args, Configuration this._config, Logger this._log) {
    argParser
      ..addOption(_argFile, abbr: 'f', help: 'The file to parse and store')
      ..addFlag(_argDaemonize,
          abbr: 'd',
          help:
              'Continously monitor and upload files using the configured directories.'
              ' If -d is set, -f is ignored',
          negatable: false)
      ..addFlag(_argSummarize,
          abbr: 's',
          help: 'Generate and save summary data from uploaded file',
          negatable: false);

    argParser.parse(args);
  }

  Future run() async {
    if (argResults.wasParsed(_argDaemonize)) {
      return await _daemonize(argResults[_argSummarize], _config, _log);
    }

    if (argResults.wasParsed(_argFile)) {
      final File file = new File(argResults[_argFile].trim());
      if (file.existsSync()) {
        return await _goOnce(file, argResults[_argSummarize], _config, _log);
      } else {
        throw new UsageException(
            'Cannot find file ${argResults[_argFile]}', '');
      }
    }
  }
}

/**
 * Monitor the [config] directories for CDR files and upload them continously to
 * Google.
 */
Future _daemonize(bool summarize, Configuration config, Logger log) async {
  final Google g = await google(config.credentials, config.scopes);

  try {
    log.info('store._daemonize() got a Google service account auth client');

    await Future.doWhile(() async {
      try {
        await _goContinously(summarize, g, config, log);

        await new Future.delayed(
            new Duration(seconds: config.uploadIntervalInSeconds));
      } catch (error) {
        log.disaster('store._daemonize() failed with ${error}');
      }

      return true;
    });
  } catch (error) {
    log.disaster('store._daemonize() failed with ${error}');
  }
}

/**
 * Collect a maximum of 120 CDR files, 100 from [config.cdrDirectory] and 20
 * from [config.cdrPartiallyUploadedDirectory]. Hand files over to
 * upload.upload() and return when done.
 */
Future _goContinously(
    bool summarize, Google g, Configuration config, Logger log) async {
  final Duration minimumFileAge = new Duration(seconds: 10);

  try {
    final List<FileSystemEntity> files =
        config.cdrDirectory.listSync().take(100).toList();
    final List<FileSystemEntity> partiallyUploadedFiles =
        config.cdrPartiallyStoredDirectory.listSync();

    partiallyUploadedFiles.shuffle();
    files.addAll(partiallyUploadedFiles.take(20));

    files.removeWhere((FileSystemEntity file) =>
        file is Directory ||
        path.extension(file.path) != '.json' ||
        file.statSync().modified.difference(new DateTime.now()) >
            minimumFileAge);

    if (files.isEmpty) {
      log.info(
          'store.goContinously() found no files to process. Waiting ${config.uploadIntervalInSeconds} seconds');
    } else {
      log.info(
          'store.goContinously() will start processing ${files.length.toString()} files now');
    }

    return await parseStoreAndSummarize(files, summarize, g, config, log);
  } catch (error) {
    log.error('store.goContinously() failed with ${error}');
  }
}

/**
 * Upload [file] to Google and optionally create a summary file.
 */
Future _goOnce(
    File file, bool summarize, Configuration config, Logger log) async {
  final Google g = await google(config.credentials, config.scopes);

  try {
    log.info('store._goOnce() got a Google service account auth client');

    await parseStoreAndSummarize([file], summarize, g, config, log);
    g.gClient.close();
  } catch (error) {
    log.error('store._goOnce() failed with ${error}');
    exit(1);
  }
}
