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

part of openreception.service.io;

class WebSocketClient extends Service.WebSocket {

  static final String className = '${libraryName}.WebSocketClient';
  static final Logger log = new Logger(className);

  IO.WebSocket  _websocket        = null;

  Future<Service.WebSocket> connect (Uri path) =>
      IO.WebSocket.connect(path.toString()).then((IO.WebSocket ws) {
        this._websocket = ws;
        this._websocket.listen(this.onMessage, onError: this.onError,
            onDone: () => this.onClose);

        return this;
    });

  Future close () => this._websocket.close();
}
