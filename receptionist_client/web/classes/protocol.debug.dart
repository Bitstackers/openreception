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
 * Gives a list of peers.
 */
class PeerList extends Protocol{
  /**
   * TODO Comment
   */
  PeerList(){
    assert(configuration.loaded);

    String base = configuration.aliceBaseUrl.toString();
    String path = '/debug/peer/list';

    _url = _buildUrl(base, path);
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

/**
 * Gives a list of every channel in the PBX.
 */
class ChannelList extends Protocol{
  /**
   * TODO Comment
   */
  ChannelList(){
    assert(configuration.loaded);

    String base = configuration.aliceBaseUrl.toString();
    String path = '/debug/channel/list';

    _url = _buildUrl(base, path);
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
