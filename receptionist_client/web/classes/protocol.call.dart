part of protocol;

/**
 * TODO comment
 */
class PickupCall extends Protocol{
  /**
   * TODO comment
   */
  PickupCall(int AgentId, {String callId}){
    assert(configuration.loaded);

    var base = configuration.aliceBaseUrl.toString();
    var path = '/call/pickup';
    var fragments = new List<String>();

    if (AgentId == null){
      log.critical('Protocol.PickupCall: AgentId is null');
      throw new Exception();
    }

    fragments.add('agent_id=${AgentId}');

    if (callId != null && !callId.isEmpty){
      fragments.add('call_id=${callId}');
    }

    _url = _buildUrl(base, path, fragments);
    _request = new HttpRequest()
        ..open(POST, _url);
  }

  /**
   * TODO comment
   */
  void onSuccess(void onData(String responseText)){
    assert(_request != null);
    assert(_notSent);

    _request.onLoad.listen((_){
      if (_request.status == 200){
        onData(_request.responseText);
      }
    });
  }

  /**
   * TODO comment
   */
  void onNoCall(void onData()){
    assert(_request != null);
    assert(_notSent);

    _request.onLoad.listen((_){
      if (_request.status == 204){
        onData();
      }
    });
  }

  /**
   * TODO comment
   */
  void onError(void onData()) {
    assert(_request != null);
    assert(_notSent);

    _request.onError.listen((_) {
      log.critical(_errorLogMessage('Protocol pickupCall failed.'));
      onData();
    });

    _request.onLoad.listen((_) {
      if (_request.status != 200 && _request.status != 204){
        log.critical(_errorLogMessage('Protocol pickupCall failed.'));
        onData();
      }
    });
  }
}

/**
 * TODO FiX doc or code. Doc says that call_id is optional, Alice says that it's not. 20 Feb 2013
 * TODO comment
 */
class HangupCall extends Protocol{
  /**
   * TODO comment
   */
  HangupCall({String callId}){
    assert(configuration.loaded);

    var base = configuration.aliceBaseUrl.toString();
    var path = '/call/hangup';
    var fragments = new List<String>();

    if (callId != null && !callId.isEmpty){
      fragments.add('call_id=${callId}');
    }

    _url = _buildUrl(base, path, fragments);
    _request = new HttpRequest()
        ..open(POST, _url);
  }

  /**
   * TODO comment
   */
  void onSuccess(void onData(String responseText)){
    assert(_request != null);
    assert(_notSent);

    _request.onLoad.listen((_){
      if (_request.status == 200){
        onData(_request.responseText);
      }
    });
  }

  /**
   * TODO comment
   */
  void onNoCall(void onData()){
    assert(_request != null);
    assert(_notSent);

    _request.onLoad.listen((_){
      if (_request.status == 404){
        onData();
      }
    });
  }

  /**
   * TODO comment
   */
  void onError(void onData()) {
    assert(_request != null);
    assert(_notSent);

    _request.onError.listen((_) {
      log.critical(_errorLogMessage('Protocol HangupCall failed.'));
      onData();
    });

    _request.onLoad.listen((_) {
      if (_request.status != 200 && _request.status != 404){
        log.critical(_errorLogMessage('Protocol HangupCall failed.'));
        onData();
      }
    });
  }
}

/**
 * TODO Check up on Docs. It says nothing about call_id. 2013-02-27 Thomas P.
 * TODO comment
 */
class HoldCall extends Protocol{
  /**
   * TODO comment
   */
  HoldCall(int callId){
    assert(configuration.loaded);

    var base = configuration.aliceBaseUrl.toString();
    var path = '/call/hold';
    var fragments = new List<String>();

    if (callId == null){
      log.critical('Protocol.HoldCall: callId is null');
      throw new Exception();
    }

    fragments.add('call_id=${callId}');

    _url = _buildUrl(base, path, fragments);
    _request = new HttpRequest()
        ..open(POST, _url);
  }

  /**
   * TODO comment
   */
  void onSuccess(void onData(String responseText)){
    assert(_request != null);
    assert(_notSent);

    _request.onLoad.listen((_){
      if (_request.status == 200){
        onData(_request.responseText);
      }
    });
  }

  /**
   * TODO comment
   */
  void onNoCall(void onData()){
    assert(_request != null);
    assert(_notSent);

    _request.onLoad.listen((_){
      if (_request.status == 400){
        onData();
      }
    });
  }

  /**
   * TODO comment
   */
  void onError(void onData()) {
    assert(_request != null);
    assert(_notSent);

    _request.onError.listen((_) {
      log.critical(_errorLogMessage('Protocol HoldCall failed.'));
      onData();
    });

    _request.onLoad.listen((_) {
      if (_request.status != 200 && _request.status != 400){
        log.critical(_errorLogMessage('Protocol HoldCall failed.'));
        onData();
      }
    });
  }
}
/**
 * TODO comment
 */
class TransferCall extends Protocol{
  /**
   * TODO Comment
   */
  TransferCall(int callId){
    assert(configuration.loaded);

    var base = configuration.aliceBaseUrl.toString();
    var path = '/call/transfer';
    var fragments = new List<String>();

    if (callId == null){
      log.critical('Protocol.TransferCall: callId is null');
    }

    fragments.add('source=${callId}');

    _url = _buildUrl(base, path, fragments);
    _request = new HttpRequest()
        ..open(GET, _url);
  }

  /**
   * TODO Comment
   */
  void onSuccess(void onData(String Text)){
    assert(_request != null);
    assert(_notSent);

    _request.onLoad.listen((_){
      if (_request.status == 200){
        onData(_request.responseText);
      }
    });
  }

  /**
   * TODO Comment
   */
  void onError(void onData()){
    assert(_request != null);
    assert(_notSent);

    _request.onError.listen((_) {
      log.critical(_errorLogMessage('Protocol TransferCall failed.'));
      onData();
    });

    _request.onLoad.listen((_) {
      if (_request.status != 200){
        log.critical(_errorLogMessage('Protocol TransferCall failed.'));
        onData();
      }
    });
  }
}

/**
 * TODO comment
 */
class CallQueue extends Protocol{
  /**
   * TODO Comment
   */
  CallQueue(){
    assert(configuration.loaded);

    var base = configuration.aliceBaseUrl.toString();
    var path = '/call/queue';

    _url = _buildUrl(base, path);
    _request = new HttpRequest()
        ..open(GET, _url);
  }

  /**
   * TODO Comment
   */
  void onSuccess(void onData(String Text)){
    assert(_request != null);
    assert(_notSent);

    _request.onLoad.listen((_){
      if (_request.status == 200){
        onData(_request.responseText);
      }
    });
  }

  /**
   * TODO Comment
   */
  void onEmptyList(void onData()){
    assert(_request != null);
    assert(_notSent);

    _request.onLoad.listen((_){
      if (_request.status == 204){
        onData();
      }
    });
  }

  /**
   * TODO Comment
   */
  void onError(void onData()){
    assert(_request != null);
    assert(_notSent);

    _request.onError.listen((_) {
      log.critical(_errorLogMessage('Protocol CallQueue failed.'));
      onData();
    });

    _request.onLoad.listen((_) {
      if (_request.status != 200 && _request.status != 204){
        log.critical(_errorLogMessage('Protocol CallQueue failed.'));
        onData();
      }
    });
  }
}

/**
 * TODO comment
 */
class CallList extends Protocol{
  /**
   * TODO Comment
   */
  CallList(){
    assert(configuration.loaded);

    var base = configuration.aliceBaseUrl.toString();
    var path = '/call/list';

    _url = _buildUrl(base, path);
    _request = new HttpRequest()
        ..open(GET, _url);
  }

  /**
   * TODO Comment
   */
  void onSuccess(void onData(String Text)){
    assert(_request != null);
    assert(_notSent);

    _request.onLoad.listen((_){
      if (_request.status == 200){
        onData(_request.responseText);
      }
    });
  }

  /**
   * TODO Comment
   */
  void onEmptyList(void onData()){
    assert(_request != null);
    assert(_notSent);

    _request.onLoad.listen((_){
      if (_request.status == 204){
        onData();
      }
    });
  }

  /**
   * TODO Comment
   */
  void onError(void onData()){
    assert(_request != null);
    assert(_notSent);

    _request.onError.listen((_) {
      log.critical(_errorLogMessage('Protocol CallList failed.'));
      onData();
    });

    _request.onLoad.listen((_) {
      if (_request.status != 200 && _request.status != 204){
        log.critical(_errorLogMessage('Protocol CallList failed.'));
        onData();
      }
    });
  }
}

/**
 * TODO Not implemented in Alice, as fare as i can see. 2013-02-27 Thomas P.
 * TODO comment
 */
class StatusCall extends Protocol{
  /**
   * TODO Comment
   */
  StatusCall(int callId){
    assert(configuration.loaded);

    var base = configuration.aliceBaseUrl.toString();
    var path = '/call/state';
    var fragments = new List<String>();

    if (callId == null){
      log.critical('Protocol.StatusCall: callId is null');
      throw new Exception();
    }

    fragments.add('call_id=${callId}');

    _url = _buildUrl(base, path, fragments);
    _request = new HttpRequest()
        ..open(GET, _url);
  }

  /**
   * TODO Comment
   */
  void onSuccess(void onData(String Text)){
    assert(_request != null);
    assert(_notSent);

    _request.onLoad.listen((_){
      if (_request.status == 200){
        onData(_request.responseText);
      }
    });
  }

  /**
   * TODO Comment
   */
  void onError(void onData()){
    assert(_request != null);
    assert(_notSent);

    _request.onError.listen((_) {
      log.critical(_errorLogMessage('Protocol StatusCall failed.'));
      onData();
    });

    _request.onLoad.listen((_) {
      if (_request.status != 200){
        log.critical(_errorLogMessage('Protocol StatusCall failed.'));
        onData();
      }
    });
  }
}


/**
 * Place a new call to an Agent, a Contact (via contact method, ), an arbitrary PSTn number or a SIP phone.
 *
 * TODO Comment
 */
class OriginateCall extends Protocol{
  /**
   * TODO Comment
   */
  OriginateCall(int agentId,{ int cmId, String pstnNumber, String sip}){
    assert(configuration.loaded);

    var base = configuration.aliceBaseUrl.toString();
    var path = '/call/originate';
    var fragments = new List<String>();

    if (agentId == null){
      log.critical('Protocol.OriginateCall: agentId is null');
      throw new Exception();
    }

    fragments.add('agent_id=${agentId}');

    if (?cmId && cmId != null){
      fragments.add('cm_id=${cmId}');
    }

    if (?pstnNumber && pstnNumber != null){
      fragments.add('pstn_number=${pstnNumber}');
    }

    if (?sip && sip != null && !sip.isEmpty){
      fragments.add('sip=${sip}');
    }

    _url = _buildUrl(base, path, fragments);
    _request = new HttpRequest()
        ..open(POST, _url);
  }

  /**
   * TODO Comment
   */
  void onSuccess(void onData(String Text)){
    assert(_request != null);
    assert(_notSent);

    _request.onLoad.listen((_){
      if (_request.status == 200){
        onData(_request.responseText);
      }
    });
  }

  /**
   * TODO Comment
   */
  void onError(void onData()){
    assert(_request != null);
    assert(_notSent);

    _request.onError.listen((_) {
      log.critical(_errorLogMessage('Protocol OriginateCall failed.'));
      onData();
    });

    _request.onLoad.listen((_) {
      if (_request.status != 200){
        log.critical(_errorLogMessage('Protocol OriginateCall failed.'));
        onData();
      }
    });
  }
}
