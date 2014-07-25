part of model;

class Recipient {
  
  Map _map = {'contact'   : { 'id'   : nullContact.id,
                              'name' : "<null contact>",
                             }, 
              'reception' : { 'id'   : nullReception.ID,
                              'name' : "<null reception>",
                             },
              'role' : null};
  
  /* Data map mappings */
  int    get contactID                   => this._map['contact']['id'];
         set contactID (int ID)          => this._map['contact']['id'] = ID;
  String get contactName                 => this._map['contact']['name'];
         set contactName (String name)   => this._map['contact']['name'] = name;
  int    get receptionID                 => this._map['reception']['id'];
         set receptionID (int ID)        => this._map['reception']['id'] = ID; 
  String get receptionName               => this._map['reception']['name'];
         set receptionName (String name) => this._map['reception']['name'] = name; 
  String get role                        => this._map['role'];
         set role (String role)          => this._map['role'] = role;
  
  Recipient (String contact_reception, String role) {
    List<String> split = contact_reception.split('@');
    this.contactID = int.parse(split[0]);
    this.receptionID = int.parse(split[1]);
    this.role = role;
  }

  factory Recipient.fromJSONString (String json) => new  Recipient.fromMap(JSON.decode (json));
  
  Recipient.fromMap (Map map) {
    this.contactID     = map['contact']['id'];
    this.contactName   = map['contact']['name'];
    this.receptionID   = map['reception']['id'];
    this.receptionName = map['reception']['name'];
    this.role          = map['role'];
  }

  @override
  int get hashCode => (this.ContactString()).hashCode;
  
  @override
  bool operator == (Recipient other) => this.ContactString() == other.ContactString();
  
  Map get asMap => this._map;

  Map    toJson()   => this.asMap;
  
  @override
  String toString() => '${this.contactName}@${this.receptionName}';
  
  String ContactString() => contactID.toString() + "@" + receptionID.toString(); 
}
