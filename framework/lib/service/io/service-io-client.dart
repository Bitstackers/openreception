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
  static final io.ContentType contentTypeJson =
      new io.ContentType("application", "json", charset: "utf-8");
  static final io.ContentType contentTypeApplicationForm =
      new io.ContentType("application", "x-www-form-urlencoded");

  final io.HttpClient client = new io.HttpClient();

  /**
   * Retrives [resource] using HTTP GET.
   * Throws subclasses of [StorageException] upon failure.
   */
  Future<String> get(Uri resource) async {
    log.finest('GET $resource');

    io.HttpClientRequest request = await client.getUrl(resource);
    io.HttpClientResponse response = await request.close();

    return await _handleResponse(response, 'GET', resource);
  }

  /**
   * Retrives [resource] using HTTP PUT, sending [payload].
   * Throws subclasses of [StorageException] upon failure.
   */
  Future<String> put(Uri resource, String payload) async {
    log.finest('PUT $resource');

    io.HttpClientRequest request = await client.putUrl(resource)
      ..headers.contentType = contentTypeJson
      ..write(payload);
    io.HttpClientResponse response = await request.close();

    return await _handleResponse(response, 'PUT', resource);
  }

  /**
   * Retrives [resource] using HTTP POST, sending [payload].
   * Throws subclasses of [StorageException] upon failure.
   */
  Future<String> post(Uri resource, String payload) async {
    log.finest('POST $resource');

    io.HttpClientRequest request = await client.postUrl(resource)
      ..headers.contentType = contentTypeJson
      ..write(payload);
    io.HttpClientResponse response = await request.close();

    return await _handleResponse(response, 'POST', resource);
  }

  /**
   * Retrives [resource] using HTTP POST, sending [payload] as a from.
   * Throws subclasses of [StorageException] upon failure.
   */
  Future<String> postForm(Uri resource, Map payload) async {
    log.finest('POST $resource');

    io.HttpClientRequest request = await client.postUrl(resource)
      ..headers.contentType = contentTypeApplicationForm
      ..write(mapToUrlFormEncodedPostBody(payload));
    io.HttpClientResponse response = await request.close();

    return await _handleResponse(response, 'POST', resource);
  }

  /**
   * Retrives [resource] using HTTP DELETE.
   * Throws subclasses of [StorageException] upon failure.
   */
  Future<String> delete(Uri resource) async {
    log.finest('DELETE $resource');

    io.HttpClientRequest request = await client.deleteUrl(resource);
    io.HttpClientResponse response = await request.close();

    return await _handleResponse(response, 'DELETE', resource);
  }
}

String mapToUrlFormEncodedPostBody(Map body) => body.keys
    .map((key) => '$key=${Uri.encodeQueryComponent(body[key])}')
    .join('&');
