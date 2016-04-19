library openreception_tests.rest;

import 'dart:io';
import 'dart:async';

import 'package:esl/esl.dart' as esl;
import 'package:logging/logging.dart';

import 'package:openreception_tests/storage.dart' as storeTest;
import 'package:openreception_tests/service.dart' as serviceTest;
import 'package:openreception_tests/process.dart' as process;
import 'package:openreception_tests/support.dart';
import 'package:openreception_tests/config.dart';

import 'package:openreception_framework/resource.dart' as resource;
import 'package:openreception_framework/service.dart' as service;
import 'package:openreception_framework/service-io.dart' as service;
import 'package:openreception_framework/model.dart' as model;

import 'package:unittest/unittest.dart';

part 'rest/rest-authentication.dart';
part 'rest/rest-calendar.dart';
part 'rest/rest-call.dart';
part 'rest/rest-config.dart';
part 'rest/rest-contact.dart';
part 'rest/rest-dialplan.dart';
part 'rest/rest-ivr.dart';
part 'rest/rest-message.dart';
part 'rest/rest-notification.dart';
part 'rest/rest-organization.dart';
part 'rest/rest-peeraccount.dart';
part 'rest/rest-reception.dart';
part 'rest/rest-user.dart';

const String _namespace = 'rest';
/**
 * Run all rest-service tests.
 */
allTests() {
  _runPeerAccountTests();
  _runMessageTests();
  _runDialplanDeploymentTests();
  _runConfigTests();
  _runAuthServerTests();
  _runCallTests();
  _runUserTests();
  _runOrganizationTests();
  _runReceptionTests();
  _runContactTests();
  _runCalendarTests();
  _runDialplanTests();
  _runIvrTests();
  _runNotificationTests();
}

/**
 * Test for the presence of CORS headers.
 */
Future isCORSHeadersPresent(Uri uri, Logger log) async {
  final HttpClient client = new HttpClient();

  void checkHeaders(HttpClientResponse response) {
    if (response.headers['access-control-allow-origin'] == null &&
        response.headers['Access-Control-Allow-Origin'] == null) {
      log.warning(response.statusCode);
      response.headers.forEach((name, values) {
        log.warning('$name : ${values.join(', ')}');
      });

      fail('No CORS headers on path uri');
    }
  }

  log.info('Checking CORS headers on URI $uri.');

  return client
      .getUrl(uri)
      .then((HttpClientRequest request) => request.close().then(checkHeaders))
      .then((_) => log.info('Got expected headers.'))
      .whenComplete(() => client.close(force: true));
}

/**
 * Test server behaviour when trying to access a resource not associated with
 * a handler.
 *
 * The expected behaviour is that the server should return a Not Found error.
 */
Future nonExistingPath(Uri uri, Logger log) async {
  final HttpClient client = new HttpClient();

  log.info('Checking server behaviour on a non-existing path.');

  void checkResponseCode(HttpClientResponse response) {
    if (response.statusCode != 404) {
      fail('Expected to received a 404 on path $uri '
          'but got ${response.statusCode}');
    }
  }

  return client
      .getUrl(uri)
      .then((HttpClientRequest request) =>
          request.close().then(checkResponseCode))
      .then((_) => log.info('Got expected status code 404.'))
      .whenComplete(() => client.close(force: true));
}
