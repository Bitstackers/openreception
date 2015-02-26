/*                  This file is part of OpenReception
                   Copyright (C) 2014-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

library service;

import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'package:logging/logging.dart' show Logger, Level, LogRecord;
import 'package:openreception_framework/service.dart'      as ORService;
import 'package:openreception_framework/storage.dart'      as ORStorage;
import 'package:openreception_framework/service-html.dart' as ORServiceHTML;


import '../classes/logger.dart';

import '../protocol/protocol.dart';
import '../model/model.dart' as model;
import '../config/configuration.dart';

part 'service-authentication.dart';
part 'service-call.dart';
part 'service-contact.dart';
part 'service-message.dart';
part 'service-peer.dart';
part 'service-reception.dart';

const String libraryName = "service";

abstract class HTTPError extends Error {
  final String message;
  HTTPError(this.message);
  String toString() => "HTTPError::${this.runtimeType} : $message";
}

class NotFound extends HTTPError {
  NotFound (String message): super(message);
}

class Forbidden extends HTTPError {
  Forbidden (String message): super(message);
}

class Unauthorized extends HTTPError {
  Unauthorized (String message): super(message);
}

class BadRequest extends HTTPError {
  BadRequest (String message) : super(message);
}

class ServerError extends HTTPError {
  ServerError (String message) : super(message);
}

class UndefinedError extends HTTPError {
  UndefinedError (String message) : super(message);
}

Error _badRequest(String resource) {
  Error error = new BadRequest(resource);
  model.NotificationList.instance.add(new model.Notification(error.toString()));
  return error;
}

Error _notFound(String resource) {
  Error error = new NotFound(resource);
  model.NotificationList.instance.add(new model.Notification(error.toString()));
  return error;
}

Error _serverError(String resource) {
  Error error = new ServerError(resource);
  model.NotificationList.instance.add(new model.Notification(error.toString()));
  return error;
}

String _buildUrl(String base, String path, [List<String> fragments]) {
  if (!base.endsWith('/') && !path.startsWith('/')) {
    base = '$base/';
  } else if (base.endsWith('/') && !path.startsWith('/')) {
    path = path.replaceFirst('/', '');
  }

  assert(base != null);
  assert(path != null);

  final StringBuffer buffer = new StringBuffer();
  final String url = '${base}${path}';

  if (fragments != null && !fragments.isEmpty) {
    buffer.write('?${fragments.first}');
    fragments.skip(1).forEach((fragment) => buffer.write('&${fragment}'));
  }

  return '${url}${buffer.toString()}';
}
