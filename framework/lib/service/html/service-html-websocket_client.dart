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

part of openreception.framework.service.html;

class WebSocketClient extends service.WebSocket {
  static final String className = '${libraryName}.WebSocketClient';
  static final Logger log = new Logger(className);

  html.WebSocket _websocket = null;

  Future<service.WebSocket> connect(Uri path) {
    this._websocket = new html.WebSocket(path.toString());
    Completer<service.WebSocket> ready = new Completer();

    this._websocket
      ..onMessage.listen(_onMessage)
      ..onError.listen((html.Event event) => onError(null))
      ..onOpen.listen((_) => ready.complete())
      ..onClose.listen((_) => this.onClose());

    return ready.future;
  }

  void _onMessage(html.MessageEvent e) => this.onMessage(e.data.toString());

  Future close() => new Future.sync(() => this._websocket.close());
}
