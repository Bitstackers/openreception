library authenticationserver.router;

import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:route/server.dart';

import 'cache.dart' as cache;
import 'package:Utilities/common.dart';
import 'configuration.dart';
import 'database.dart' as db;
import 'googleauth.dart';
import 'package:Utilities/httpserver.dart';

part 'router/login.dart';
part 'router/oauthcallback.dart';
part 'router/user.dart';

final Pattern loginUrl = new UrlPattern('/login');
final Pattern oauthReturnUrl = new UrlPattern('/oauth2callback');
final Pattern userUrl = new UrlPattern('/user');

void setup(HttpServer server) {
  Router router = new Router(server)
    ..serve(loginUrl, method: 'GET').listen(login)
    ..serve(oauthReturnUrl, method: 'GET').listen(oauthCallback)
    ..serve(userUrl, method: 'GET').listen(userinfo)
    ..defaultStream.listen(page404);
}
