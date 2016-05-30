/*                 Copyright (C) 2016-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

library google;

import 'dart:async';

import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis/storage/v1.dart';

class Google {
  StorageApi _blob;
  auth.AutoRefreshingAuthClient gClient;

  StorageApi get blob => _blob;
}

/**
 * Return a [Google] object with an auto refreshing client and access to Cloud
 * Storage.
 */
Future<Google> google(
    auth.ServiceAccountCredentials credentials, List<String> scopes) async {
  final auth.AutoRefreshingAuthClient authClient =
      await auth.clientViaServiceAccount(credentials, scopes);
  return new Google()
    .._blob = new StorageApi(authClient)
    ..gClient = authClient;
}
