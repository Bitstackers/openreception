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
 *
 * TODO: Add reason for the exception. Should be carried in 'message'
 *   or 'error' field from the server.
 */
abstract class WebService {

  static const String GET    = 'GET';
  static const String PUT    = 'PUT';
  static const String POST   = 'POST';
  static const String DELETE = 'DELETE';

  Future<String> get    (Uri path);
  Future<String> put    (Uri path, String payload);
  Future<String> post   (Uri path, String payload);
  Future<String> delete (Uri path);

  static void checkResponse(int responseCode,String method,
                            Uri path, String response) {
    switch (responseCode) {
      case 200:
        break;

      case 400:
        throw new Storage.ClientError ('$method $path - $response');
        break;

      case 401:
        throw new Storage.NotAuthorized ('$method  $path - $response');
        break;

      case 403:
        throw new Storage.Forbidden ('$method $path - $response');
        break;

      case 409:
        throw new Storage.Conflict ('$method $path - $response');
        break;

      case 404:
       throw new Storage.NotFound('$method  $path - $response');
       break;

      case 500:
        throw new Storage.ServerError('$method  $path - $response');
        break;

      default:
        throw new StateError('Status (${responseCode}): $method $path - $response');
    }
  }
}
