part of model;

class ContactAttribute implements Comparable<ContactAttribute> {
  Map         _attributes;
  int         contactId;
  bool        enabled;
  List        distributionList;
  List<Phone> phoneNumbers;
  int         receptionId;
  bool        statusEmail;
  bool        wantsMessages;

  //TODO Quick fix..
  String receptionName;
  bool receptionEnabled;

  Map get attributes => _attributes;

  List<String> get backup => priorityListFromJson(_attributes, 'backup');
  void set backup(List<String> list) {
    if(_attributes == null) {
      _attributes = {};
    }
    _attributes['backup'] = priorityListToJson(list);
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

  ContactAttribute();

  ContactAttribute.fromJson(Map json) {
    contactId = json['contact_id'];
    enabled = json['enabled'];
    wantsMessages = json['wants_messages'];
    distributionList = json['distribution_list'];
    List<Map> phoneList = json['phonenumbers'] as List<Map>;
    if(phoneList != null) {
      phoneNumbers = phoneList.map((Map json) => new Phone.fromJson(json)).toList();
    }
    _attributes = json['attributes'];
    statusEmail = json['status_email'];
    receptionId = json['reception_id'];

    receptionName = json['reception_full_name'];
    receptionEnabled = json['reception_enabled'];
  }

  Map toJson() => {
    'contact_id': contactId,
    'reception_id': receptionId,
    'wants_messages': wantsMessages,
    'enabled': enabled,
    'phonenumbers' : phoneNumbers,
    'attributes': attributes
  };

  @override
  int compareTo(ContactAttribute other) => this.receptionName.compareTo(other.receptionName);
}
