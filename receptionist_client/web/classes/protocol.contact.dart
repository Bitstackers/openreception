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

Future<Response<model.ContactList>> getContactList(int receptionId) {
  assert(receptionId != null);

  final String       base      = configuration.contactServer.toString(); //configuration.aliceBaseUrl.toString();
  final Completer<Response<model.ContactList>> completer =
      new Completer<Response<model.ContactList>>();
  final List<String> fragments = new List<String>();
  final String       path      = '/contact/list/reception/${receptionId}';
  HttpRequest        request;
  String             url;

  fragments.add('token=${configuration.token}');
  url = _buildUrl(base, path, fragments);

  request = new HttpRequest()
      ..open(GET, url)
      ..onLoad.listen((value) {
        switch(request.status) {
          case 200:
            log.debug('protocol.getContactList json: ${request.responseText}'); //TODO remove.
            model.ContactList data = new model.ContactList.fromJson(_parseJson(request.responseText), 'contacts');
            completer.complete(new Response<model.ContactList>(Response.OK, data));
            break;

          case 404:
            completer.complete(new Response<model.ContactList>(Response.NOTFOUND, new model.ContactList.emptyList()));
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

Future<Response<model.Contact>> getContact(int receptionId, int contactId) {
  assert(receptionId != null);
  assert(receptionId >= 0);
  assert(contactId != null);
  assert(contactId >= 0);

  final String       base      = configuration.contactServer.toString(); //configuration.aliceBaseUrl.toString();
  final Completer<Response<model.Contact>> completer =
      new Completer<Response<model.Contact>>();
  final List<String> fragments = new List<String>();
  final String       path      = '/contact/${contactId}/reception/${receptionId}';
  HttpRequest        request;
  String             url;

  fragments.add('token=${configuration.token}');
  url = _buildUrl(base, path, fragments);

  request = new HttpRequest()
      ..open(GET, url)
      ..onLoad.listen((value) {
        switch(request.status) {
          case 200:
            log.debug('protocol.getContact json: ${request.responseText}'); //TODO remove.
            model.Contact data = new model.Contact.fromJson(_parseJson(request.responseText));
            completer.complete(new Response<model.Contact>(Response.OK, data));
            break;

          case 404:
            completer.complete(new Response<model.Contact>(Response.NOTFOUND, model.nullContact));
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
