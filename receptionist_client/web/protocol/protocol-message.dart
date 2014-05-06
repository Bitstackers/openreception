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
 * Send [message] to [cmId].
 *
 * Completes with
 *  On success : [Response] object with status OK
 *  On error   : [Response] object with status ERROR or CRITICALERROR
 */

/**
 * POST /message/send?[to=<contact_id>@<reception_id>{,<contact_id>@<reception_id>}&]
                      [cc=<contact_id>@<reception_id>{,<contact_id>@<reception_id>}&]
                      [bcc=<contact_id>@<reception_id>{,<contact_id>@<reception_id>}&]
                      message=<message>
 */
Future<Response<Map>> sendMessage(String message, List to, int toContactID, {List cc, List bcc}) {
  assert(to != null);
  assert(message.isNotEmpty); // Turn into a more specific exception so we can catch it an let the user know.

  final String                   base       = configuration.messageBaseUrl.toString();
  final Completer<Response<Map>> completer  = new Completer<Response<Map>>();
  final List<String>             fragments = new List<String>();
  final String                   path       = '/message/send';

  /* Assemble the initial content for the message. */
  Map payload = {'message': message,
       'to': to.map((v) => v.toString()).toList(),
       'subject': 'subject',
       'to_contact_id': toContactID,
       'takenFrom': 'Thomas', //TODO: FIX
       'takeByAgent': model.User.currentUser.ID,
       'urgent': false   //TODO: FIX
       };

  /* Attach the cc recipients - only if there are any. */
  if (cc != null) {
    payload ['cc'] = cc.map((v) => v.toString()).toList();
  }

  /* Same thing goes for the bcc recipients.*/ 
  if (bcc != null) {
    payload ['bcc'] = bcc.map((v) => v.toString()).toList();
  }

  /* 
   * Now we are ready to send the request to the server. 
   */
  
  HttpRequest                    request;
  String                         url;

  fragments.add('token=${configuration.token}');
  url = _buildUrl(base, path, fragments);

  request = new HttpRequest()
  ..open(POST, url)
  ..setRequestHeader('Content-Type', 'application/x-www-form-urlencoded')
  ..onLoad.listen((_) {
    switch(request.status) {
      case 200:
        Map data = _parseJson(request.responseText);
        if (data != null) {
          completer.complete(new Response<Map>(Response.OK, data));
        } else {
          completer.complete(new Response<Map>(Response.ERROR, data));
        }
        break;

      default:
        completer.completeError(new Response.error(Response.CRITICALERROR, '${url} [${request.status}] ${request.statusText}'));
    }
  })
  ..onError.listen((e) {
    _logError(request, url);
    completer.completeError(new Response.error(Response.CRITICALERROR, e.toString()));
  })
  ..send(payload);

  return completer.future;
}

/**
 * Retrieves the list of messages stored on the server.
 */
Future<Response<Map>> getMessages() {

  final String                   base       = configuration.messageBaseUrl.toString();
  final Completer<Response<Map>> completer  = new Completer<Response<Map>>();
  final List<String>             fragments = new List<String>();
  final String                   path       = '/message/list';
  
  HttpRequest                    request;
  String                         url;

  fragments.add('token=${configuration.token}');
  url = _buildUrl(base, path, fragments);

  request = new HttpRequest()
    ..open(GET, url)
    ..onLoad.listen((_) {
      switch(request.status) {
        case 200:
          Map data = _parseJson(request.responseText);
          completer.complete(new Response<Map>(Response.OK, data));
          break;

        case 204:
          completer.complete(new Response<Map>(Response.OK, null));
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
