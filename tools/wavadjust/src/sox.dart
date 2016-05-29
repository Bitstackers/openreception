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

import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as path;

import 'logger.dart';

/**
 * Return true of all [files] are WAV files.
 */
Future<bool> isWav(List<File> files) async {
  final List<String> soxiArgs = new List<String>()
    ..add('-t')
    ..addAll(files.map((File file) => file.path));
  final ProcessResult processResult = await Process.run('soxi', soxiArgs);

  if (processResult.exitCode > 0) {
    return false;
  }

  final List<String> result = (processResult.stdout as String)
      .split('\n')
      .where((String s) => s.trim().isNotEmpty);
  return result.every((String s) => s == 'wav');
}

/**
 * Returns the max volume multiplier for [file]
 */
Future<String> maxVolMultiplier(File file) async => double
    .parse(((await Process.run('sox', [file.path, '-n', 'stat', '-v'])).stderr))
    .floor()
    .toString();

/**
 * Adjust [file] according to [rate] and [volume]. The final result is placed in
 * [output].
 */
Future adjustFile(
    File file, String rate, String volume, Directory output, Logger log) async {
  final List<String> errors = new List<String>();

  /// Remix to one channel (mono)
  final String monoFilePath =
      path.join(output.path, 'm' + path.basename(file.path));
  final List<String> monoArgs = new List<String>()
    ..add(file.path)
    ..add('-c 1')
    ..add(monoFilePath);

  final ProcessResult monoResult = await Process.run('sox', monoArgs);

  if (monoResult.exitCode == 0) {
    log.info('${file.path} is remixed to mono as $monoFilePath');
  } else {
    errors.add('${file.path} could not be remixed to mono');
  }

  /// Raise volume to maximum
  final String maxVolFilePath =
      path.join(output.path, 'v' + path.basename(monoFilePath));
  final List<String> maxVolArgs = new List<String>()
    ..add('-v')
    ..add(await maxVolMultiplier(file))
    ..add(monoFilePath)
    ..add(maxVolFilePath);

  final ProcessResult maxVolResult = await Process.run('sox', maxVolArgs);

  if (maxVolResult.exitCode == 0) {
    log.info('$monoFilePath volume maximized as $maxVolFilePath');
  } else {
    errors.add('$monoFilePath could not maximize volume');
  }

  /// Normalize volume to [volume]
  final String normVolFilePath =
      path.join(output.path, 'v' + path.basename(maxVolFilePath));
  final List<String> normVolArgs = new List<String>()
    ..add('-v')
    ..add(volume)
    ..add(maxVolFilePath)
    ..add(normVolFilePath);

  final ProcessResult normVolResult = await Process.run('sox', normVolArgs);

  if (normVolResult.exitCode == 0) {
    log.info('$maxVolFilePath volume adjusted by $volume as $normVolFilePath');
  } else {
    errors.add('${maxVolFilePath} could not adjust volume');
  }

  /// Set frequency to [rate]
  final String rateFilePath =
      path.join(output.path, 'r' + path.basename(normVolFilePath));
  final List<String> rateArgs = new List<String>()
    ..add(normVolFilePath)
    ..add('-r')
    ..add(rate)
    ..add(rateFilePath);

  final ProcessResult rateResult = await Process.run('sox', rateArgs);

  if (rateResult.exitCode == 0) {
    log.info('$normVolFilePath frequency set to $rate as $rateFilePath');
  } else {
    errors.add('$normVolFilePath could not change frequency');
  }

  /// Copy the [rateFilePath] file to [file] basename
  await new File(rateFilePath)
      .copy(path.join(output.path, path.basename(file.path)));

  /// Remove intermediate files
  await new File(monoFilePath).delete();
  await new File(maxVolFilePath).delete();
  await new File(normVolFilePath).delete();
  await new File(rateFilePath).delete();

  if (errors.isNotEmpty) {
    for (String error in errors) {
      log.error(error);
    }
  }

  log.info(
      '${path.join(output.path, path.basename(file.path))} is ready for use');
}
