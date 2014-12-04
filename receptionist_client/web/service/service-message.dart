part of service;

abstract class MessageResource {

}

abstract class Message {

  static ORStorage.Message _store = null;

  static ORStorage.Message get store {
    if (_store == null) {
      _store = new ORService.RESTMessageStore
          (configuration.messageBaseUrl,
           configuration.token,
           new ORServiceHTML.Client());
    }

    return _store;
  }
}
