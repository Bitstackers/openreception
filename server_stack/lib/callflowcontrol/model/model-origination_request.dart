part of callflowcontrol.model;

abstract class OriginationRequest {

  static final Logger log = new Logger('${libraryName}.OriginationRequest');

  static Set<String> _storage = new Set<String>();

  static create (String sourceCallID) {
    _storage.add(sourceCallID);
    log.finest('Creating origination request with ID $sourceCallID');
  }

  static bool contains (Call sourceCall) => _storage.contains(sourceCall.ID);

  static void confirm (Call sourceCall) {

    if (!_storage.contains(sourceCall.ID)) {
      return;
    }

    log.finest('Confirming origination request for ID ${sourceCall.ID}');
    _storage.remove(sourceCall.ID);
    }

}
