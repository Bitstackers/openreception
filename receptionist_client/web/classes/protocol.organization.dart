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
  void onNotFound(void onData()) {
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
  void onError(void onData()) {
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
