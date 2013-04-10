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
 * Class to get a list of every active call.
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
   * If there are no call in the system.
   */
  void onEmptyList(Callback onData){
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
  void onError(Callback onData){
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
 * Gives a list of calls that are waiting in a queue.
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
  void onEmptyQueue(Callback onData){
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
  void onError(Callback onData){
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
 * TODO FiX doc or code. Doc says that call_id is optional, Alice says that it's not. 20 Feb 2013
 * Makes a request to hangup a call.
 */
class HangupCall extends Protocol{
  /**
   * Hangups a call based on it's [callId].
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
   * If there are no call to hangup.
   */
  void onNoCall(Callback onData){
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
  void onError(Callback onData) {
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
 * Sets the call OnHold or park it, if the ask Asterisk.
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
  void onNoCall(Callback onData){
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
  void onError(Callback onData) {
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
 * Place a new call to an Agent, a Contact (via contact method, ), an arbitrary PSTn number or a SIP phone.
 *
 * Sends a request to make a new call.
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
  void onError(Callback onData){
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

/**
 * Sends a request to pickup a call.
 */
class PickupCall extends Protocol{
  /**
   * Sends a call based on the [callId], if present, to the agent with [AgentId].
   * If no callId is specified, then the next call in line will be dispatched
   * to the agent.
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
  void onNoCall(Callback onData){
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
  void onError(Callback onData) {
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
 * TODO Not implemented in Alice, as fare as i can see. 2013-02-27 Thomas P.
 * Gives the status of a call.
 */
class StatusCall extends Protocol{
  /**
   * Gives the status of a call based on the [callId].
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
  void onError(Callback onData){
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
 * TODO write better comment.
 * Sends a request to transfer a call.
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
  void onError(Callback onData){
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
