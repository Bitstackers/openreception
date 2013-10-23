/*                     This file is part of Bob
                   Copyright (C) 2012-, AdaHeads K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

library protocol;

import 'dart:async';
import 'dart:html';
import 'dart:convert';

import 'configuration.dart';
import 'logger.dart';
import 'model.dart' as model;

part 'protocol.agent.dart';
part 'protocol.call.dart';
part 'protocol.debug.dart';
part 'protocol.log.dart';
part 'protocol.message.dart';
part 'protocol.organization.dart';

const String GET = "GET";
const String POST = "POST";

/**
 * TODO comment.
 * Something about response from the protocol.
 */
class Response<T> {
  static const int CRITICALERROR = -2;
  static const int ERROR = -1;
  static const int OK = 0;
  static const int NOTFOUND = 1;

  T data;
  int status;
  String statusText;

  Response(this.status, this.data);
  Response.error(this.status, this.statusText);

  /**
   * [Response] as String, for debug/log purposes.
   */
  String toString() => '${status} ${statusText}';
}

/**
 * Makes a complete url from [base], [path] and the [fragments].
 * Output: base + path + ? + fragment[0] + & + fragment[1] ...
 */
String _buildUrl(String base, String path, [List<String> fragments]) {
  assert(base != null);
  assert(path != null);

  final StringBuffer buffer  = new StringBuffer();
  final String       url = '${base}${path}';

  if (fragments != null && !fragments.isEmpty) {
    buffer.write('?${fragments.first}');
    fragments.skip(1).forEach((fragment) => buffer.write('&${fragment}'));
  }

  log.debug('protocol._buildUrl ${url}${buffer.toString()}');
  return '${url}${buffer.toString()}';
}

/**
 * Validates and parses String in JSON format to a Map.
 */
Map _parseJson(String responseText) {
  try {
    return JSON.decode(responseText);
  } catch(e) {
    log.critical('protocol._parseJson exception: ${e}');
    return null;
  }
}

/**
 * Log [request] and [url] to [log.critical]
 */
void _logError(HttpRequest request, String url) {
  log.critical('Protocol failed. Status: [${request.status}] URL: ${url}');
}
