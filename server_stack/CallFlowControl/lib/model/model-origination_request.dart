part of callflowcontrol.model;

abstract class OriginationRequest {

  static Set<String> _storage = new Set<String>();
  
  static create (String sourceCallID) {
    _storage.add(sourceCallID);
  }
  
  static bool contains (String sourceCallID) => _storage.contains(sourceCallID);

  static void confirm (String sourceCallID) { _storage.remove(sourceCallID); }
  
}
