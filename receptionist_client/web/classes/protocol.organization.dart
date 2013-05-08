/*                                Bob
                   Copyright (C) 2012-, AdaHeads K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This library is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License and
  a copy of the GCC Runtime Library Exception along with this program;
  see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see
  <http://www.gnu.org/licenses/>.
*/
part of protocol;

/**
 * TODO Comment
 */
Future<Response> getOrganization(int id){
  assert(configuration.loaded);

  final completer = new Completer<Response>();

  HttpRequest request;

  String base = configuration.aliceBaseUrl.toString();
  String path = '/organization';

  List<String> fragments = new List<String>()
      ..add('org_id=${id}');

  String url = _buildUrl(base, path, fragments);

  request = new HttpRequest()
      ..open(GET, url)
      ..onLoad.listen((val) {
        switch(request.status) {
          case 200:
            Map data = _parseJson(request.responseText);
            if (data != null) {
              completer.complete(new Response(Response.OK, data));
            } else {
              completer.complete(new Response(Response.ERROR, data));
            }
            break;

          case 404:
            completer.complete(new Response(Response.NOTFOUND, null));
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
 * TODO Comment
 */
Future<Response> getOrganizationList({String view: MINI}){
  assert(configuration.loaded);
  assert(view == MINI || view == MIDI);

  final completer = new Completer<Response>();

  HttpRequest request;

  String base = configuration.aliceBaseUrl.toString();
  String path = '/organization/list';
  List<String> fragments = new List<String>()
      ..add('view=${view}');

  String url = _buildUrl(base, path, fragments);

  request = new HttpRequest()
      ..open(GET, url)
      ..onLoad.listen((val) {
        switch(request.status) {
          case 200:
            Map data = _parseJson(request.responseText);
            if (data != null) {
              completer.complete(new Response(Response.OK, data));
            } else {
              completer.complete(new Response(Response.ERROR, data));
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
      ..send();

  return completer.future;
}
