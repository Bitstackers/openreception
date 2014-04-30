part of model;

class Agent {
  
  static final int NULL_AGENT_ID = 0;
  
  int    _id   = NULL_AGENT_ID;
  String _name = "<null agent>";
  
  int    get ID  => this._id;
  String get name => this._name;
  
  Agent (this._id, this._name);
  
  factory Agent.fromMap (Map map) {
    return new Agent (map['id'], map['name']);
  }
}