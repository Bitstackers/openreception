library management_tool.auth;

import 'dart:html';

import 'package:management_tool/configuration.dart';

/**
 * Returns true if there is a token.
 *  Otherwise it sends the user to the login site.
 *
 * Remark:
 *  It does not check if it's a valid token.
 */
bool handleToken() {
  Uri url = Uri.parse(window.location.href);
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
  String loginUrl =
      '${config.clientConfig.authServerUri}/token/create?returnurl=${window.location}';
  window.location.assign(loginUrl);
}
