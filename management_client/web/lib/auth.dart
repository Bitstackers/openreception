library auth;

import 'dart:html';

import 'configuration.dart';

/**
 * Returns true if there is a token.
 *  Otherwise it sends the user to the login site.
 *
 * Remark:
 *  It does not check if it's a valid token.
 */
bool handleToken() {
  Uri url = Uri.parse(window.location.href);
  //TODO Save to localStorage. and check on upstart if it's still valid
  if (url.queryParameters.containsKey('settoken')) {
    config.token = url.queryParameters['settoken'];
    return true;
  } else {
    login();
    return false;
  }
}

/**Sends the user to the login site.*/
void login() {
  String loginUrl = '${config.clientConfig.authServerUri}/token/create?returnurl=${window.location}';
  window.location.assign(loginUrl);
}
