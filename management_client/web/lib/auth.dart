library auth;

import 'dart:html';

import 'configuration.dart';


bool handleToken() {
  Uri url = Uri.parse(window.location.href);
  //TODO Save to localStorage.
  if (url.queryParameters.containsKey('settoken')) {
    config.token = url.queryParameters['settoken'];
    return true;
  } else {
    login();
    return false;
  }
}

void login() {
  String loginUrl = '${config.authBaseUrl}/token/create?returnurl=${window.location}';
  //TODO
  //loginUrl = '${window.location}?settoken=feedabbadeadbeef0';
  window.location.assign(loginUrl);
}
