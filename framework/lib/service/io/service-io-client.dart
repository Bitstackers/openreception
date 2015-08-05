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

part of openreception.service.io;

/**
 * HTTP Client for use with dart:io.
 */
class Client extends Service.WebService {

  static final String className = '${libraryName}.Client';
  static final Logger log = new Logger(className);
  static final IO.ContentType contentTypeJson = new IO.ContentType("application", "json", charset: "utf-8");

  final IO.HttpClient client = new IO.HttpClient();

  /**
   * Retrives [resource] using HTTP GET.
   * Throws subclasses of [StorageException] upon failure.
   */
  Future<String> get(Uri resource) {
    log.finest('GET $resource');

    return client.getUrl(resource)
      .then((IO.HttpClientRequest request) => request.close())
      .then((IO.HttpClientResponse response) => _handleResponse(response, 'GET', resource));
  }

  /**
   * Retrives [resource] using HTTP PUT, sending [payload].
   * Throws subclasses of [StorageException] upon failure.
   */
  Future<String> put(Uri resource, String payload) {
    log.finest('PUT $resource');

    return client.putUrl(resource).then((IO.HttpClientRequest request) {
      request.headers.contentType = contentTypeJson;
      request.write(payload);
      return request.close();
    })
    .then((IO.HttpClientResponse response) => _handleResponse(response, 'PUT', resource));
  }

  /**
   * Retrives [resource] using HTTP POST, sending [payload].
   * Throws subclasses of [StorageException] upon failure.
   */
  Future<String> post(Uri resource, String payload) {
    log.finest('POST $resource');

    return client.postUrl(resource).then((IO.HttpClientRequest request) {
      request.headers.contentType = contentTypeJson;
      request.write(payload);
      return request.close();
    })
    .then((IO.HttpClientResponse response) => _handleResponse(response, 'POST', resource));
  }

  /**
   * Retrives [resource] using HTTP DELETE.
   * Throws subclasses of [StorageException] upon failure.
   */
  Future<String> delete(Uri resource) {
    log.finest('DELETE $resource');

    return client.deleteUrl(resource)
        .then((IO.HttpClientRequest request) => request.close())
        .then((IO.HttpClientResponse response) => _handleResponse(response, 'DELETE', resource));
  }

}
