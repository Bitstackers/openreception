part of callflowcontrol.model;

abstract class OriginationRequest {

  static const classname = '${libraryName}.OriginationRequest';

  static Set<String> _storage = new Set<String>();

  static create (String sourceCallID) {
    const String context = '${classname}.create';

    _storage.add(sourceCallID);
    logger.debugContext(sourceCallID, context);
  }

  static bool contains (Call sourceCall) => _storage.contains(sourceCall.ID);

  static void confirm (Call sourceCall) {
    const String context = '${classname}.confirm';

    if (!_storage.contains(sourceCall.ID)) {
      return;
    }

    logger.debugContext(sourceCall.ID, context);
    _storage.remove(sourceCall.ID);
    }

}
