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
class Message extends Protocol{
  String _payload;

  /**
   * TODO Comment
   */
  Message(int cmId, String message){
    assert(configuration.loaded);

    var base = configuration.aliceBaseUrl.toString();
    var path = '/message/send';

    if (cmId == null){
      log.critical('Protocol.Message: cmId is null');
      throw new Exception();
    }

    if (message == null){
      log.critical('Protocol.Message: message is null');
      throw new Exception();
    }

    _url = _buildUrl(base, path);
    _request = new HttpRequest()
      ..open(POST, _url)
      ..setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');

    _payload = 'cm_id=${cmId}&msg=${encodeUriComponent(message)}';
  }

  void onSuccess(void onData(String responseText)){
    assert(_request != null);
    assert(_notSent);

    _request.onLoad.listen((_) {
      if (_request.status == 204){
        onData(_request.responseText);
      }
    });
  }

  /**
   * TODO Comment
   */
  void onError(Callback onData) {
    assert(_request != null);
    assert(_notSent);

    _request.onError.listen((_) {
      log.critical(_errorLogMessage('Protocol Message failed.'));
      onData();
    });

    _request.onLoad.listen((_) {
      if (_request.status != 204){
        log.critical(_errorLogMessage('Protocol Message failed.'));
        onData();
      }
    });
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
}