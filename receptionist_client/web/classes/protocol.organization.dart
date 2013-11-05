/*                     This file is part of Bob
                   Copyright (C) 2012-, AdaHeads K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of protocol;

/**
 * Get the [id] organization JSON data.
 *
 * Completes with
 *  On success   : [Response] object with status OK (data)
 *  On not found : [Response] object with status NOTFOUND (no data)
 *  on error     : [Response] object with status ERROR or CRITICALERROR (data)
 */
Future<Response<model.Organization>> getOrganization(int id) {
  assert(id != null);

  final String       base      = configuration.aliceBaseUrl.toString();
  final Completer<Response<model.Organization>> completer =
      new Completer<Response<model.Organization>>();
  final List<String> fragments = new List<String>();
  final String       path      = '/organization';
  HttpRequest        request;
  String             url;

  fragments.add('org_id=${id}');
  url = _buildUrl(base, path, fragments);

  request = new HttpRequest()
      ..open(GET, url)
      ..onLoad.listen((val) {
        switch(request.status) {
          case 200:
            log.debug('protocol.getOrganization json: ${request.responseText}'); //TODO remove.
            model.Organization data = new model.Organization.fromJson(_parseJson(request.responseText));
            completer.complete(new Response<model.Organization>(Response.OK, data));
            break;

          case 404:
            completer.complete(new Response<model.Organization>(Response.NOTFOUND, model.nullOrganization));
            break;

          default:
            completer.completeError(new Response.error(Response.CRITICALERROR, '${url} [${request.status}] ${request.statusText}'));
        }
      })
      ..onError.listen((e) {
        _logError(request, url);
        completer.completeError(new Response.error(Response.CRITICALERROR, e.toString()));
      })
      ..send();

  return completer.future;
}

const String MINI = 'mini';
const String MIDI = 'midi';

/**
 * Get the organization list JSON data.
 *
 * Completes with
 *  On success : [Response] object with status OK (data)
 *  on error   : [Response] object with status ERROR or CRITICALERROR (data)
 */
Future<Response<model.OrganizationList>> getOrganizationList({String view: MINI}) {
  assert(view == MINI || view == MIDI);

  final String       base      = configuration.aliceBaseUrl.toString();
  final Completer<Response<model.OrganizationList>> completer =
      new Completer<Response<model.OrganizationList>>();
  final List<String> fragments = new List<String>();
  final String       path      = '/organization/list';
  HttpRequest        request;
  String             url;

  fragments.add('view=${view}');
  url = _buildUrl(base, path, fragments);

  request = new HttpRequest()
      ..open(GET, url)
      ..onLoad.listen((val) {
        switch(request.status) {
          case 200:
            var response = _parseJson(request.responseText);
            //TODO REMOVE BEFORE FRIDAY 8 Nov. TESTING ONLY
            for(int i = 5; i < 100; i++) {
              response['organization_list'].add({"organization_id": i, "full_name": 'EvilCorp${i}', "uri": 'EvilCorp${i}'});
            }
            model.OrganizationList data = new model.OrganizationList.fromJson(response, 'organization_list');
            completer.complete(new Response<model.OrganizationList>(Response.OK, data));
            break;

          default:
            completer.completeError(new Response.error(Response.CRITICALERROR, '${url} [${request.status}] ${request.statusText}'));
        }
      })
      ..onError.listen((e) {
        _logError(request, url);
        completer.completeError(new Response.error(Response.CRITICALERROR, e.toString()));
      })
      ..send();

  return completer.future;
}
