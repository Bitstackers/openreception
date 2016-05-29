/*                 Copyright (C) 2016-, BitStackers

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart';

import '../src/logger.dart';
import '../src/sox.dart';

main(List<String> args) async {
  final Logger log = new Logger();

  try {
    final ArgParser parser = new ArgParser();
    final ArgResults results = getParsedArgs(parser, args);

    if (results.wasParsed('help')) {
      print(parser.usage);
      exit(0);
    }

    log.noisy = results.wasParsed('noisy');

    await checkArgs(parser, results);

    await Future.forEach(results['input'], (String s) async {
      await adjustFile(new File(s), results['rate'], results['volume'],
          new Directory(results['output']), log);
    });
  } catch (error) {
    if (error is FormatException || error is ArgumentError) {
      log.error(error.message);
      exit(64); // usage error.
    } else {
      log.error(error.message);
      exit(1);
    }
  }
}

/**
 * Check that all required CLI arguments are present and valid.
 *
 * Throws [ArgumentError] on missing/bad arguments.
 */
Future checkArgs(ArgParser parser, ArgResults results) async {
  if (results.wasParsed('volume')) {
    try {
      double.parse(results['volume']);
    } catch (_) {
      throw new ArgumentError(
          'Bad -v: "${results['volume']}". Must be a float');
    }
  }

  if (!results.wasParsed('input')) {
    throw new ArgumentError('Missing -i / --input');
  }

  final List<File> files = new List<File>();
  for (String file in results['input']) {
    if (file.trim().isNotEmpty) {
      files.add(new File(file));
    }
  }

  if (files.any((File file) => isRelative(file.path))) {
    throw new ArgumentError('One or more -i file paths are relative');
  }

  if (files.any((File file) => !file.existsSync())) {
    throw new ArgumentError('One or more -i files could not be found');
  }

  if (!(await isWav(files))) {
    throw new ArgumentError('One or more -i files are not WAV files');
  }

  if (results.wasParsed('output') &&
      !(new Directory(results['output']).existsSync())) {
    throw new ArgumentError('-o / --output directory does not exist');
  }
}

/**
 * Build an [ArgResults] from [args]
 */
ArgResults getParsedArgs(ArgParser argParser, List<String> args) {
  argParser
    ..addOption('volume',
        abbr: 'v',
        defaultsTo: '0.3',
        help:
            'The output volume. 1.0 is neutral, <1.0 is lower, >1.0 is higher')
    ..addOption('rate',
        abbr: 'r',
        allowed: ['8000', '16000', '32000', '48000'],
        defaultsTo: '8000',
        help: 'The frequency of the output file')
    ..addOption('input',
        abbr: 'i',
        allowMultiple: true,
        splitCommas: true,
        help:
            'Input file(s). Comma-separate multiple files. Path must be absolute.')
    ..addOption('output',
        abbr: 'o', help: 'Output folder. Final output files are placed here')
    ..addFlag('noisy',
        abbr: 'n',
        help: 'Be noisy. If not set, only errors are printed to STDOUT')
    ..addFlag('help', abbr: 'h', help: 'This help text');

  return argParser.parse(args);
}
