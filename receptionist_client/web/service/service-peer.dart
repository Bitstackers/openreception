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

part of service;

abstract class Peer {

  /**
   * Fetches a list of currently known peers from the Server.
   */
  static Future<model.PeerList> list() {

    const String context = '${libraryName}.list';

    final String                   base      = "http://localhost:4242";
    final Completer<model.PeerList> completer = new Completer<model.PeerList>();
    final List<String>             fragments = new List<String>();
    final String                   path      = '/debug/peer/list';
    HttpRequest                    request;
    String                         url;

    fragments.add('token=${configuration.token}');
    url = _buildUrl(base, path, fragments);

    request = new HttpRequest()
      ..open(GET, url)
      ..onLoad.listen((_) {
        switch(request.status) {
          case 200:
            completer.complete(new model.PeerList.fromList(JSON.decode(request.responseText)['peers']));
            break;
          case 400:
            completer.completeError(_badRequest('Resource ${base}${path}'));
            break;

          case 404:
            completer.completeError(_notFound('Resource ${base}${path}'));
            break;

          case 500:
            completer.completeError(_serverError('Resource ${base}${path}'));
            break;
          default:
            completer.completeError(new UndefinedError('Status (${request.status}): Resource ${base}${path}'));
        }
      })
      ..onError.listen((e) {
        log.errorContext('Status (${request.status}): Resource ${base}${path}', context);
        completer.completeError(e);
      })
      ..send();

    return completer.future;
  }

}