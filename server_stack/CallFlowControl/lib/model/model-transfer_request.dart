part of callflowcontrol.model;

class TransferRequest {
  
  static Set<_ChannelPair> _storage = new Set<_ChannelPair>();
  
  static create (String sourceCallID, String destinationCallID) {
    _storage.add(new _ChannelPair (sourceCallID, destinationCallID));
  }
  
  static bool contains (String sourceCallID, String destinationCallID) =>
     _storage.contains(new _ChannelPair (sourceCallID, destinationCallID));
  

  static void confirm (String sourceCallID, String destinationCallID) {
    _storage.remove(new _ChannelPair (sourceCallID, destinationCallID));
  }
}

class _ChannelPair {
  final String _sourceCallID;
  final String _destinationCallID;
  
  _ChannelPair(this._sourceCallID, this._destinationCallID);
  
  @override
  operator == (_ChannelPair other) {
    return (this._destinationCallID == other._destinationCallID &&
            this._sourceCallID      == other._sourceCallID)
         ||
           (this._destinationCallID == other._sourceCallID      &&
            this._sourceCallID      == other._destinationCallID);
  }
  
  @override 
  int get hashCode  {
    return this._lexicallyOrdered.join().hashCode;
    
  }
  List<String> get _lexicallyOrdered {
    List<String> ordered = [this._sourceCallID, this._destinationCallID];
    ordered.sort();
    return ordered;
  }
    
}