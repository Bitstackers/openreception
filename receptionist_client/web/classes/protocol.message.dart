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
   * TODO find better function type.
   */
  void onError(void onData()) {
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