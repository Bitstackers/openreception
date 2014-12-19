library authenticationserver.router;

import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:route/server.dart';

//import 'cache.dart' as cache;
import 'configuration.dart';
import 'database.dart' as db;
import 'googleauth.dart';
import 'token_watcher.dart' as watcher;
import 'token_vault.dart';
import 'package:openreception_framework/httpserver.dart';
import 'package:openreception_framework/common.dart';

part 'router/invalidate.dart';
part 'router/login.dart';
part 'router/oauthcallback.dart';
part 'router/user.dart';
part 'router/validate.dart';

part 'router/refresher.dart';

final Pattern anything = new UrlPattern(r'/(.*)');
final Pattern loginUrl = new UrlPattern('/token/create');
final Pattern oauthReturnUrl = new UrlPattern('/token/oauth2callback');
final Pattern userUrl = new UrlPattern('/token/([0-9a-zA-Z]+)');
final Pattern validateUrl = new UrlPattern('/token/([0-9a-zA-Z]+)/validate');
final Pattern invalidateUrl = new UrlPattern('/token/([0-9a-zA-Z]+)/invalidate');

final Pattern refreshUrl = new UrlPattern('/token/([0-9a-zA-Z]+)/refresh');

void setup(HttpServer server) {
  Router router = new Router(server)
    ..serve(loginUrl, method: 'GET').listen(login)
    ..serve(oauthReturnUrl, method: 'GET').listen(oauthCallback)
    ..serve(userUrl, method: 'GET').listen(userinfo)
    ..serve(validateUrl, method: 'GET').listen(validateToken)
    ..serve(invalidateUrl, method: 'POST').listen(invalidateToken)
    ..serve(anything, method: 'OPTIONS').listen(preFlight)
    ..serve(refreshUrl, method: 'GET').listen(refresher)
    ..defaultStream.listen(page404);
}
