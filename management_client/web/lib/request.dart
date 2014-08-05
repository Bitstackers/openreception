library request;

import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:libdialplan/libdialplan.dart';
import 'package:libdialplan/ivr.dart';

import 'configuration.dart';
import 'model.dart';

part 'requests/calendar.dart';
part 'requests/cdr.dart';
part 'requests/contact.dart';
part 'requests/dialplan.dart';
part 'requests/organization.dart';
part 'requests/reception.dart';
part 'requests/reception_contact.dart';
part 'requests/user.dart';

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

  UnknowStatusCode(int this.statusCode, String this.statusText, String this.message);

  String toString() {
    if (statusCode == null || statusText == null) return "UnknowStatusCode";
    return "UnknowStatusCode: ${statusCode} ${statusText} - ${message}";
  }
}
