part of model;

class Recipient {
  
  Map _map = {'contact'   : { 'id'   : nullContact.id,
                              'name' : "<null contact>",
                             }, 
              'reception' : { 'id'   : nullReception.id,
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
  String get receptionName               => this._map['reception']['id'];
         set receptionName (String name) => this._map['reception']['name'] = name; 
  String get role                        => this._map['role'];
         set role (String role)          => this._map['role'] = role;
  
  Recipient (String contact_reception, String role) {
    List<String> split = contact_reception.split('@');
    this.contactID = int.parse(split[0]);
    this.receptionID = int.parse(split[1]);
    this.role = role;
  }

  Recipient.fromJSONString (String item) {
    Map json = JSON.decode (item);

    this.contactID     = json['contact']['id'];
    this.contactName   = json['contact']['name'];
    this.receptionID   = json['reception']['id'];
    this.receptionName = json['reception']['name'];
    this.role          = json['role'];
  }
  
  @override
  int get hashCode {
    return (this.ContactString()).hashCode;
  }
  
  @override
  bool operator == (Recipient other) {
    return this.ContactString() == other.ContactString();
  }
  
  Map toMap() {
    return this._map;
  }

  String toJson() {
    return JSON.encode(this._map);
  }
  
  String ContactString() {
    return contactID.toString() + "@" + receptionID.toString(); 
  }
}
