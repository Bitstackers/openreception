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

part of openreception.service.html;

/**
 * HTTP Client for use with dart:html.
 */
class Client extends Service.WebService {

  static final String className = '${libraryName}.Client';

  Logger log = new Logger(Client.className);

  /**
   * Retrives [resource] using HTTP GET.
   * Throws subclasses of [StorageException] upon failure.
   */
  Future<String> get(Uri resource) {
    final Completer<String> completer = new Completer<String>();

    log.finest("GET $resource");

    HTML.HttpRequest request;
    request = new HTML.HttpRequest()
        ..open('GET', resource.toString())
        ..onLoad.listen((_) {
          try {
            Service.WebService.checkResponse(
                request.status,
                'GET',
                resource,
                request.responseText);
            completer.complete(request.responseText);
          } catch (error) {
            completer.completeError(error);
          }
        })
        ..onError.listen((e) => completer.completeError(e))
        ..send();

    return completer.future;
  }

  /**
   * Retrives [resource] using HTTP PUT, sending [payload].
   * Throws subclasses of [StorageException] upon failure.
   */
  Future<String> put(Uri resource, String payload) {
    final Completer<String> completer = new Completer<String>();

    log.finest("PUT $resource");

    HTML.HttpRequest request;
    request = new HTML.HttpRequest()
        ..open('PUT', resource.toString())
        ..onLoad.listen((_) {
          try {
            Service.WebService.checkResponse(
                request.status,
                'PUT',
                resource,
                request.responseText);
            completer.complete(request.responseText);
          } catch (error) {
            completer.completeError(error);
          }
        })
        ..onError.listen((e) => completer.completeError(e))
        ..send(payload);

    return completer.future;
  }

  /**
   * Retrives [resource] using HTTP POST, sending [payload].
   * Throws subclasses of [StorageException] upon failure.
   */
  Future<String> post(Uri resource, String payload) {
    final Completer<String> completer = new Completer<String>();

    log.finest("POST $resource");

    HTML.HttpRequest request;
    request = new HTML.HttpRequest()
        ..open('POST', resource.toString())
        ..onLoad.listen((_) {
          try {
            Service.WebService.checkResponse(
                request.status,
                'GET',
                resource,
                request.responseText);
            completer.complete(request.responseText);
          } catch (error) {
            completer.completeError(error);
          }
        })
        ..onError.listen((e) => completer.completeError(e))
        ..send(payload);

    return completer.future;
  }

  /**
   * Retrives [resource] using HTTP DELETE.
   * Throws subclasses of [StorageException] upon failure.
   */
  Future<String> delete(Uri resource) {
    final Completer<String> completer = new Completer<String>();

    log.finest("DELETE $resource");

    HTML.HttpRequest request;
    request = new HTML.HttpRequest()
        ..open('DELETE', resource.toString())
        ..onLoad.listen((_) {
          try {
            Service.WebService.checkResponse(
                request.status,
                'DELETE',
                resource,
                request.responseText);
            completer.complete(request.responseText);
          } catch (error) {
            completer.completeError(error);
          }
        })
        ..onError.listen((e) => completer.completeError(e))
        ..send();

    return completer.future;
  }
}
