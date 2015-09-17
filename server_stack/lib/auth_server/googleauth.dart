/*                  This file is part of OpenReception
                   Copyright (C) 2014-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

library openreception.authentication_server.google_auth;

import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:crypto/crypto.dart';

final Uri authorizationEndpoint = Uri.parse("https://accounts.google.com/o/oauth2/auth");
final Uri tokenEndpoint = Uri.parse("https://accounts.google.com/o/oauth2/token");
final List<String> _scopes = ['https://www.googleapis.com/auth/userinfo.profile', 'https://www.googleapis.com/auth/userinfo.email'];

Uri _AuthorizationUrl;

Uri googleAuthUrl(String identifier, String secret, Uri redirectUrl) {
  if(_AuthorizationUrl == null) {
    oauth2.AuthorizationCodeGrant grant = new oauth2.AuthorizationCodeGrant(identifier, secret, authorizationEndpoint, tokenEndpoint);
    _AuthorizationUrl = grant.getAuthorizationUrl(redirectUrl, scopes:_scopes);
  }
  
  return _AuthorizationUrl;
}

String Sha256Token(String token) => CryptoUtils.bytesToHex((new SHA256()..add(token.codeUnits)).close());
