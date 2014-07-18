library request;

import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:libdialplan/libdialplan.dart';
import 'package:libdialplan/ivr.dart';

import 'configuration.dart';
import 'model.dart';

part 'requests/contact.dart';
part 'requests/dialplan.dart';
part 'requests/organization.dart';
part 'requests/reception.dart';
part 'requests/reception_contact.dart';
part 'requests/user.dart';
part 'requests/cdr.dart';

class HttpMethod {
  static const String GET = 'GET';
  static const String POST = 'POST';
  static const String PUT = 'PUT';
  static const String DELETE = 'DELETE';
}

class Forbidden {}
class InternalServerError {}
class UnknowStatusCode {
  int statusCode;

  UnknowStatusCode(int this.statusCode);
}
