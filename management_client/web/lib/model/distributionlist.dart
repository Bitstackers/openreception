part of model;

class DistributionList {
  List<ReceptionContact> to = new List<ReceptionContact>();
  List<ReceptionContact> cc = new List<ReceptionContact>();
  List<ReceptionContact> bcc = new List<ReceptionContact>();

  DistributionList();

  DistributionList.fromJson(Map json) {
    if(json['to'] != null && json['to'] is List) {
      List list = json['to'];
      this.to = list.map(_makeReceptionContact).toList();
    }

    if(json['cc'] != null && json['cc'] is List) {
      List list = json['cc'];
      this.cc = list.map(_makeReceptionContact).toList();
    }

    if(json['bcc'] != null && json['bcc'] is List) {
      List list = json['bcc'];
      this.bcc = list.map(_makeReceptionContact).toList();
    }
  }

  ReceptionContact _makeReceptionContact(Map map) => new ReceptionContact()
                                          ..receptionId = map['reception_id']
                                          ..contactId = map['contact_id'];

  Map toJson() {
    return {'to': to.map(_contactToJson).toList(),
            'cc': cc.map(_contactToJson).toList(),
            'bcc': bcc.map(_contactToJson).toList()};
  }

  Map _contactToJson(ReceptionContact rc) {
    return {'reception_id': rc.receptionId,
            'contact_id': rc.contactId};
  }
}
