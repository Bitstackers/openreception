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
class Organization extends Protocol {
  /**
   * Todo Comment
   */
  Organization.get(int organizationId) {
    assert(configuration.loaded);

    String base = configuration.aliceBaseUrl.toString();
    String path = '/organization';

    List<String> fragments = new List<String>()
                                ..add('org_id=${organizationId}');

    _url = _buildUrl(base, path, fragments);
    _request = new HttpRequest()
        ..open(GET, _url);
  }

  void onResponse(responseCallback callback) {
    assert(_request != null);
    assert(_notSent);

    _request.onLoad.listen((_) {
      switch(_request.status) {
        case 200:
          Map data = parseJson(_request.responseText);
          if (data != null) {
            callback(new Response(Response.OK, data));
          } else {
            callback(new Response(Response.ERROR, data));
          }
          break;

        case 404:
          callback(new Response(Response.NOTFOUND, null));
          break;

        default:
          _logError();
          callback(new Response(Response.ERROR, null));
      }
    });

    _request.onError.listen((_) {
      _logError();
      callback(new Response(Response.ERROR, null));
    });
  }
}

/**
 * TODO Comment
 */
class OrganizationList extends Protocol {
  const String MINI = 'mini';
  const String MIDI = 'midi';

  /**
   * Todo Comment
   */
  OrganizationList({String view: MINI}) {
    assert(configuration.loaded);
    assert(view == MINI || view == MIDI);

    String base = configuration.aliceBaseUrl.toString();
    String path = '/organization/list';
    List<String> fragments = new List<String>()
        ..add('view=${view}');

    _url = _buildUrl(base, path, fragments);
    _request = new HttpRequest()
        ..open(GET, _url);
  }

  void onResponse(responseCallback callback) {
    assert(_request != null);
    assert(_notSent);

    _request.onLoad.listen((_) {
      switch(_request.status) {
        case 200:
          Map data = parseJson(_request.responseText);
          if (data != null) {
            callback(new Response(Response.OK, data));
          } else {
            callback(new Response(Response.ERROR, data));
          }
          break;

        default:
          _logError();
          callback(new Response(Response.ERROR, null));
      }
    });

    _request.onError.listen((_) {
      _logError();
      callback(new Response(Response.ERROR, null));
    });
  }
}
