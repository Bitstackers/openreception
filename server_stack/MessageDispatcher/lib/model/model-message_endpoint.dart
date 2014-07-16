part of model;

class MessageEndpoint {
  
  Map _data = {};
  
  String get name     => this._data['name'];
  String get role     => this._data['role'];
  String get type     => this._data['type'];
  String get address  => this._data['address'];
  
  MessageEndpoint.fromMap(Map map) {
    /// Map validation.
    assert(['name','role','type','address'].every((String key) => map.containsKey(key)));
    this._data = map;
  }
  
  @override
  String toString() => '${this.role} ${this.type}:${this.address}'; 
  
}