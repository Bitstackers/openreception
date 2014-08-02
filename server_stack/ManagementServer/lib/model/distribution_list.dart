part of model;

class DistributionList {
  List<ReceptionContact> to = new List<ReceptionContact>();
  List<ReceptionContact> cc = new List<ReceptionContact>();
  List<ReceptionContact> bcc = new List<ReceptionContact>();

  DistributionList();

  DistributionList.fromJson(Map json) {
    const context = '${libraryName}.DistributionList.fromJson';

    try {
      if(json['to'] != null && json['to'] is List) {
        List list = json['to'];
        this.to = list.map((Map map) => new ReceptionContact.empty()
                                            ..receptionId = map['reception_id']
                                            ..contactId   = map['contact_id']).toList();
      }
    } catch(error) {
      orf.logger.errorContext('Error: "${error}" from ${json['to']} ', context);
    }

    try {
      if(json['cc'] != null && json['cc'] is List) {
        List list = json['cc'];
        this.cc = list.map((Map map) => new ReceptionContact.empty()
                                            ..receptionId = map['reception_id']
                                            ..contactId   = map['contact_id']).toList();
      }
    } catch(error) {
      orf.logger.errorContext('Error: "${error}" from ${json['cc']} ', context);
    }

    try {
      if(json['bcc'] != null && json['bcc'] is List) {
        List list = json['bcc'];
        this.bcc = list.map((Map map) => new ReceptionContact.empty()
                                            ..receptionId = map['reception_id']
                                            ..contactId   = map['contact_id']).toList();
      }
    } catch(error) {
      orf.logger.errorContext('Error: "${error}" from ${json['bcc']} ', context);
    }
  }
}
