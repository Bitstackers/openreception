library googleauth;

import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:crypto/crypto.dart';

final Uri authorizationEndpoint = Uri.parse("https://accounts.google.com/o/oauth2/auth");
final Uri tokenEndpoint = Uri.parse("https://accounts.google.com/o/oauth2/token");
final List<String> _scopes = ['https://www.googleapis.com/auth/userinfo.profile', 'https://www.googleapis.com/auth/userinfo.email'];

Uri _AuthorizationUrl;

Map<String, Map> savedSession = new Map<String, Map>();

Uri googleAuthUrl(String identifier, String secret, Uri redirectUrl) {
  if(_AuthorizationUrl == null) {
    oauth2.AuthorizationCodeGrant grant = new oauth2.AuthorizationCodeGrant(identifier, secret, authorizationEndpoint, tokenEndpoint);
    _AuthorizationUrl = grant.getAuthorizationUrl(redirectUrl, scopes:_scopes);
  }
  
  return _AuthorizationUrl;
}

String Sha256Token(String token) => CryptoUtils.bytesToHex((new SHA256()..add(token.codeUnits)).close());
