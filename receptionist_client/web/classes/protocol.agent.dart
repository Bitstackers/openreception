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
 * Protocol class to make the request for agent state.
 */
class AgentState extends Protocol{
  /**
   * Contructor to make a request to __get__ information about an agent,
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
   * Contructor to make a request to __set__ information about an agent,
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
   * If the request gives a 200 Ok status code.
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
   * if the request gives anything else but a 200 Ok back.
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
