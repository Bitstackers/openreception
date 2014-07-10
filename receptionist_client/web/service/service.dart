library service;

import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'package:logging/logging.dart' show Logger, Level, LogRecord;

import '../classes/logger.dart';

import '../protocol/protocol.dart';
import '../model/model.dart' as model;
import '../classes/configuration.dart';

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

class Request {
  
  bool   _useCredientials = true;
  String _token           = configuration.token; 
  
  Request (Uri, String method, [bool useCredentials, String token]) {
    if (useCredentials != null) {
      this._useCredientials = useCredentials;
    }

    if (token != null) {
      this._token = token;
    }
  }
}