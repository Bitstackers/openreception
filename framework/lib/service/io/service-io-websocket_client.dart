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
