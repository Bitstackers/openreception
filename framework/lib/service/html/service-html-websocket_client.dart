part of openreception.service.html;

class WebSocketClient extends Service.WebSocket {

  static final String className = '${libraryName}.WebSocketClient';
  static final Logger log = new Logger(className);

  HTML.WebSocket  _websocket        = null;

  Future<Service.WebSocket> connect (Uri path) {
    this._websocket = new HTML.WebSocket (path.toString());
    Completer ready = new Completer();

    this._websocket
        ..onMessage.listen(this._onMessage)
        ..onError.listen(this.onError)
        ..onOpen.listen((_) => ready.complete());

    return ready.future;
  }

  void _onMessage (HTML.MessageEvent e) =>
    this.onMessage(e.data.toString());

  Future close () => new Future.sync(() => this._websocket.close());
}
