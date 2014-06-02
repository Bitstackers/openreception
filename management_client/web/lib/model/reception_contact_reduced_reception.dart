part of model;

class ReceptionContact_ReducedReception {
  int contactId;
  bool wantsMessages;
  bool contactEnabled;
  List<Phone> phoneNumbers;

  int receptionId;
  bool receptionEnabled;
  String receptionName;
  String receptionUri;

  int organizationId;

  Map _attributes;

  Map get attributes => _attributes;

  void set attributes (Map value) {
    _attributes = value;
  }

  List<String> get backup => priorityListFromJson(_attributes, 'backup');
  void set backup(List<String> list) {
    if(_attributes == null) {
      _attributes = {};
    }
    _attributes['backup'] = priorityListToJson(list);
  }

  List<String> get emailaddresses => priorityListFromJson(_attributes, 'emailaddresses');
  void set emailaddresses(List<String> list) {
    if(_attributes == null) {
      _attributes = {};
    }
    _attributes['emailaddresses'] = priorityListToJson(list);
  }

  List<String> get handling => priorityListFromJson(_attributes, 'handling');
  void set handling(List<String> list) {
    if(_attributes == null) {
      _attributes = {};
    }
    _attributes['handling'] = priorityListToJson(list);
  }

  List<String> get workhours => priorityListFromJson(_attributes, 'workhours');
  void set workhours(List<String> list) {
    if(_attributes == null) {
      _attributes = {};
    }
    _attributes['workhours'] = priorityListToJson(list);
  }

  List<String> get tags => _attributes['tags'];
  void set tags(List<String> list) {
    if(_attributes == null) {
      _attributes = {};
    }
    _attributes['tags'] = list;
  }

  String get department => _attributes['department'];
  void set department(String value) {
    if(_attributes == null) {
      _attributes = {};
    }
    _attributes['department'] = value;
  }

  String get info => _attributes['info'];
  void set info(String value) {
    if(_attributes == null) {
      _attributes = {};
    }
    _attributes['info'] = value;
  }

  String get position => _attributes['position'];
  void set position(String value) {
    if(_attributes == null) {
      _attributes = {};
    }
    _attributes['position'] = value;
  }

  String get relations => _attributes['relations'];
  void set relations(String value) {
    if(_attributes == null) {
      _attributes = {};
    }
    _attributes['relations'] = value;
  }

  String get responsibility => _attributes['responsibility'];
  void set responsibility(String value) {
    if(_attributes == null) {
      _attributes = {};
    }
    _attributes['responsibility'] = value;
  }


  ReceptionContact_ReducedReception();

  factory ReceptionContact_ReducedReception.fromJson(Map json) {
    ReceptionContact_ReducedReception object = new ReceptionContact_ReducedReception()
      ..contactId = json['contact_id']
      ..wantsMessages = json['contact_wants_messages']
      ..contactEnabled = json['contact_enabled']
      ..receptionId = json['reception_id']
      ..receptionEnabled = json['reception_enabled']
      ..receptionName = json['reception_full_name']
      ..receptionUri = json['reception_uri']

      ..organizationId = json['organization_id']

      ..phoneNumbers = (json['contact_phonenumbers'] as List<Map>).map((Map phonenumber) => new Phone.fromJson(phonenumber)).toList();

    if (json.containsKey('contact_attributes')) {
      object.attributes = json['contact_attributes'];
    }

    return object;
  }
}
