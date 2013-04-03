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
 * Class to send log messages to the server,
 */
class Log extends Protocol {
  String _payload;

  /**
   * Sends logmessage on the INFO interface.
   */
  Log.Info(String message) {
    _Log(message, configuration.serverLogInterfaceInfo);
  }

  /**
   * Sends logmessage on the ERROR interface.
   */
  Log.Error(String message) {
    _Log(message, configuration.serverLogInterfaceError);
  }

  /**
   * Sends logmessage on the CRITICAL interface.
   */
  Log.Critical(String message) {
    _Log(message, configuration.serverLogInterfaceCritical);
  }

  _Log(String message, Uri url) {
    assert(configuration.loaded);

    if (message == null){
      log.critical('Protocol.Log: message is null');
      throw new Exception();
    }

    if (url == null){
      log.critical('Protocol.Log: url is null');
      throw new Exception();
    }

    _url = url.toString();
    _request = new HttpRequest()
      ..open(POST, _url)
      ..setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');

    _payload = 'msg=${encodeUriComponent(message)}';
  }

  /**
   * TODO Comment
   */
  @override
  void send() {
    if (_notSent) {
      _request.send(_payload);
      _notSent = false;
    }
  }

  /**
   * TODO Comment
   */
  void onError(Callback onData) {
    assert(_request != null);
    assert(_notSent);

    _request.onError.listen((_) => onData());

    _request.onLoad.listen((_) {
      if (_request.status != 204){
        onData();
      }
    });
  }
}
