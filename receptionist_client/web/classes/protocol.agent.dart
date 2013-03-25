part of protocol;

/**
 * TODO Comment
 */
class AgentState extends Protocol{
  /**
   * TODO Comment
   */
  AgentState.Get(int agentId){
    assert(configuration.loaded);

    var base = configuration.aliceBaseUrl.toString();
    var path = '/agent/state';
    var fragments = new List<String>();

    if (agentId == null){
      log.critical('Protocol.AgentState.Get: agentId is null');
      throw new Exception();
    }

    fragments.add('agent_id=${agentId}');

    _url = _buildUrl(base, path, fragments);
    _request = new HttpRequest()
        ..open(GET, _url);
  }

  /**
   * TODO Comment
   */
  AgentState.Set(String state, int agentId){
    assert(configuration.loaded);

    var base = configuration.aliceBaseUrl.toString();
    var path = '/agent/state';
    var fragments = new List<String>();

    if (agentId == null){
      log.critical('Protocol.AgentState.Set: agentId is null');
      throw new Exception();
    }

    if (state == null){
      log.critical('Protocol.AgentState.Set: state is null');
      throw new Exception();
    }

    fragments.add('new_state=${state}');
    fragments.add('agent_id=${agentId}');


    _url = _buildUrl(base, path, fragments);
    _request = new HttpRequest()
        ..open(POST, _url);
  }

  /**
   * TODO Comment
   */
  void onSuccess(void onData(String response)){
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
      log.critical(_errorLogMessage('Protocol AgentState failed.'));
      onData();
    });

    _request.onLoad.listen((_) {
      if (_request.status != 200 && _request.status != 204){
        log.critical(_errorLogMessage('Protocol AgentState failed.'));
        onData();
      }
    });
  }
}
