part of model;

class DistributionList {
  List<ContactAttribute> to = new List<ContactAttribute>();
  List<ContactAttribute> cc = new List<ContactAttribute>();
  List<ContactAttribute> bcc = new List<ContactAttribute>();

  DistributionList();

  DistributionList.fromJson(Map json) {
    if(json['to'] != null && json['to'] is List) {
      List list = json['to'];
      this.to = list.map(_createReceptionContact).toList();
    }

    if(json['cc'] != null && json['cc'] is List) {
      List list = json['cc'];
      this.cc = list.map(_createReceptionContact).toList();
    }

    if(json['bcc'] != null && json['bcc'] is List) {
      List list = json['bcc'];
      this.bcc = list.map(_createReceptionContact).toList();
    }
  }

  ContactAttribute _createReceptionContact(Map map) =>
      new ContactAttribute()
        ..contactId   = map['contact_id']
        ..receptionId = map['reception_id'];

  Map toJson() =>
    {'to' : to .map(_contactToJson).toList(),
     'cc' : cc .map(_contactToJson).toList(),
     'bcc': bcc.map(_contactToJson).toList()
    };

  Map _contactToJson(ContactAttribute contactAttribute) =>
      {'reception_id': contactAttribute.receptionId,
       'contact_id'  : contactAttribute.contactId};
}
