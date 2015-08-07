library request;

import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:libdialplan/libdialplan.dart';
import 'package:libdialplan/ivr.dart';
import 'package:openreception_framework/service.dart' as ORService;
import 'package:openreception_framework/service-html.dart' as Transport;
import 'package:openreception_framework/model.dart' as ORModel;

import 'configuration.dart';
import 'controller.dart' as Controller;
import 'model.dart';
import 'package:logging/logging.dart';

part 'requests/calendar.dart';
part 'requests/archive/cdr.dart';
part 'requests/dialplan.dart';
//part 'requests/user.dart';

Logger log = new Logger('request');

class HttpMethod {
  static const String GET = 'GET';
  static const String POST = 'POST';
  static const String PUT = 'PUT';
  static const String DELETE = 'DELETE';
}

class ForbiddenException implements Exception {
  final message;

  ForbiddenException(this.message);

  String toString() {
    if (message == null) return "ForbiddenException";
    return "ForbiddenException: $message";
  }
}

class InternalServerError implements Exception {
  final message;

  InternalServerError(this.message);

  String toString() {
    if (message == null) return "InternalServerError";
    return "InternalServerError: $message";
  }
}

class UnknowStatusCode implements Exception {
  int statusCode;
  String statusText;
  String message;

  UnknowStatusCode(
      int this.statusCode, String this.statusText, String this.message);

  String toString() {
    if (statusCode == null || statusText == null) return "UnknowStatusCode";
    return "UnknowStatusCode: ${statusCode} ${statusText} - ${message}";
  }
}
