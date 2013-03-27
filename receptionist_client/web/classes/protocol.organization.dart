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
class Organization extends Protocol {
  /**
   * Todo Comment
   */
  Organization.get(int organizationId) {
    assert(configuration.loaded);

    var base = configuration.aliceBaseUrl.toString();
    var path = '/organization';

    var fragments = new List<String>()
        ..add('org_id=${organizationId}');

    _url = _buildUrl(base, path, fragments);
    _request = new HttpRequest()
        ..open(GET, _url);
  }

  /**
   * TODO Comment
   */
  void onSuccess(void onData(String responseText)) {
    assert(_request != null);
    assert(_notSent);

    _request.onLoad.listen((_) {
      if (_request.status == 200) {
        onData(_request.responseText);
      }
    });
  }

  /**
   * TODO Comment
   */
  void onNotFound(Callback onData) {
    assert(_request != null);
    assert(_notSent);

    _request.onLoad.listen((_) {
      if (_request.status == 404) {
        log.error('Protocol Organization. Status: [${_request.status}] URL: ${_url}');
        onData();
      }
    });
  }

  /**
   * TODO Comment
   * TODO find better function type.
   */
  void onError(Callback onData) {
    assert(_request != null);
    assert(_notSent);

    _request.onError.listen((e){
      log.critical('Protocol Organization failed. Status: [${_request.status}] URL: ${_url}');
      onData();
    });

    _request.onLoad.listen((e){
      if (_request.status != 200 && _request.status != 404) {
        log.critical('Protocol Organization failed. Status: [${_request.status}] URL: ${_url}');
        onData();
      }
    });
  }
}

/**
 * TODO Comment
 */
class OrganizationList extends Protocol {
  static const String MINI = 'mini';
  static const String MIDI = 'midi';

  /**
   * Todo Comment
   */
  OrganizationList({String view: MINI}) {
    assert(configuration.loaded);
    assert(view == MINI || view == MIDI);

    var base = configuration.aliceBaseUrl.toString();
    var path = '/organization/list';
    var fragments = new List<String>()
        ..add('view=${view}');

    _url = _buildUrl(base, path, fragments);
    _request = new HttpRequest()
        ..open(GET, _url);
  }

  /**
   * TODO Comment
   */
  void onSuccess(void onData(String responseText)) {
    assert(_request != null);
    assert(_notSent);

    _request.onLoad.listen((_) {
      if (_request.status == 200) {
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

    _request.onError.listen((e){
      log.critical('Protocol Organization failed. Status: [${_request.status}] URL: ${_url}');
      onData();
    });

    _request.onLoad.listen((e){
      if (_request.status != 200) {
        log.critical('Protocol Organization failed. Status: [${_request.status}] URL: ${_url}');
        onData();
      }
    });
  }
}
