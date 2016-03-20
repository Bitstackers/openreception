library openreception_tests.support.auth;

import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:logging/logging.dart';

import 'package:openreception_framework/model.dart' as model;

const String _namespace = 'test.support.auth';

class AuthTokenDir {
  final Directory dir;
  Set<AuthToken> tokens = new Set<AuthToken>();
  final Logger _log = new Logger('$_namespace.AuthTokenDir');

  AuthTokenDir(this.dir, {Iterable<AuthToken> intialTokens: const []}) {
    tokens.addAll(intialTokens);
  }

  Future writeTokens() async {
    await Future.wait((tokens.map((token) {
      final String tokenPath = '${dir.path}/${token.tokenName}.json';

      _log.finest('Writing token to file ${tokenPath}');
      return new File(tokenPath).writeAsString(JSON.encode(token.toJson()));
    })));
    _log.finest('Writing ${tokens.length} to directory ${dir.path}');
  }
}

class AuthToken {
  final model.User user;

  AuthToken(this.user);

  String get tokenName => this.user.id.toString();

  int get hashCode => tokenName.hashCode;

  Map toJson() => {
        "access_token": "none",
        "token_type": "Bearer",
        "expires_in": 3600,
        "id_token": "none",
        "expiresAt": "2100-12-31 00:00:00.000",
        "identity": user.toJson()
      };

  String toString() => tokenName;
}
