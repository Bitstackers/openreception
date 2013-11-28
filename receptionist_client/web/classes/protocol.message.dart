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
 * POST /message/send?[to=<contact_id>@<organization_id>{,<contact_id>@<organization_id>}&]
                      [cc=<contact_id>@<organization_id>{,<contact_id>@<organization_id>}&]
                      [bcc=<contact_id>@<organization_id>{,<contact_id>@<organization_id>}&]
                      message=<message>
 */
Future<Response<Map>> sendMessage(String message, List to, {List cc, List bcc}) {
  assert(to != null);
  assert(message.isNotEmpty);

  final String                   base       = configuration.aliceBaseUrl.toString();
  final Completer<Response<Map>> completer  = new Completer<Response<Map>>();
  final String                   path       = '/message/send';

  final String                   toPayload  = 'to=${to.map((i) => 'cid@oid').join(',')}';
  final String                   ccPayload  = cc != null && cc.isNotEmpty ? 'cc=${to.map((i) => 'cid@oid').join(',')}' : '';
  final String                   bccPayload = bcc != null && bcc.isNotEmpty ? 'bcc=${to.map((i) => 'cid@oid').join(',')}' : '';
  final String                   recepients = [toPayload, ccPayload, bccPayload].where((s) => s.isNotEmpty).join('&');
  final String                   payload    = '${recepients}&msg=${Uri.encodeComponent(message)}';

  HttpRequest                    request;
  final String                   url        = _buildUrl(base, path);

  request = new HttpRequest()
  ..open(POST, url)
  ..withCredentials = true
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

Future<Response<Map>> getMessages() {
  return new Future<Response<Map>>(() {
    Map data = {'messages': [{
      'time': 1385546113,
      'message': 'Ring på 12340001. Det handler om hans cycle.',
      'statuc': 'sendt',
      'caller': 'Bent guldimund',
      'agent': 'James bond',
      'methode': 'e-mail'
    },{
      'time': 1385546112,
      'message': 'Ring på 12340002. Det handler om hans grill.',
      'statuc': 'sendt',
      'caller': 'Hans honningkage',
      'agent': 'Svend bent',
      'methode': 'Sms'
    },{
      'time': 1385546110,
      'message': 'Ring på 12340001. Det handler om hans Hund.',
      'statuc': 'sender',
      'caller': 'Alice from wonderland',
      'agent': 'George Gearløs',
      'methode': 'Sms'
    },{
      'time': 1385546110,
      'message': 'Ring på 12340001. Det handler om hans blå skur.',
      'statuc': 'sendt',
      'caller': 'Doktor hvem',
      'agent': 'Thomas Løcke',
      'methode': 'e-mail'
    }]};
    return new Response<Map>(Response.OK, data);
  });
}
