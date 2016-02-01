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

part of openreception.service;

/**
 * Superclass for abstracting away the griddy details of
 * client/server-specific web-clients.
 */
abstract class WebSocket {
  static const String GET = 'GET';
  static const String PUT = 'PUT';
  static const String POST = 'POST';
  static const String DELETE = 'DELETE';

  dynamic onMessage = (_) => {};
  dynamic onError = (_) => {};
  dynamic onClose = () => {};

  Future<WebSocket> connect(Uri path);

  Future close();

  void checkResponseCode(int responseCode) {
    switch (responseCode) {
      case 200:
        break;

      case 400:
        throw new Storage.ClientError();
        break;

      case 401:
        throw new Storage.NotAuthorized();
        break;

      case 403:
        throw new Storage.Forbidden();
        break;

      case 404:
        throw new Storage.NotFound();
        break;

      case 500:
        throw new Storage.ServerError();
        break;

      default:
        throw new StateError('Status (${responseCode}):');
    }
  }
}
