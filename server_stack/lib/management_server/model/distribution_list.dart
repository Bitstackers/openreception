part of model;

class DistributionList {
  List<DistributionListEntry> to = new List<DistributionListEntry>();
  List<DistributionListEntry> cc = new List<DistributionListEntry>();
  List<DistributionListEntry> bcc = new List<DistributionListEntry>();

  DistributionList();

  DistributionList.fromJson(Map json) {
    const context = '${libraryName}.DistributionList.fromJson';

    try {
      if(json['to'] != null && json['to'] is List) {
        List list = json['to'];
        this.to = list.map((Map map) => new DistributionListEntry()
                                            ..receptionId = map['reception_id']
                                            ..contactId   = map['contact_id']
                                            ..id          = map['id']).toList();
      }
    } catch(error) {
      orf.logger.errorContext('Error: "${error}" from ${json['to']} ', context);
    }

    try {
      if(json['cc'] != null && json['cc'] is List) {
        List list = json['cc'];
        this.cc = list.map((Map map) => new DistributionListEntry()
                                            ..receptionId = map['reception_id']
                                            ..contactId   = map['contact_id']
                                            ..id          = map['id']).toList();
      }
    } catch(error) {
      orf.logger.errorContext('Error: "${error}" from ${json['cc']} ', context);
    }

    try {
      if(json['bcc'] != null && json['bcc'] is List) {
        List list = json['bcc'];
        this.bcc = list.map((Map map) => new DistributionListEntry()
                                            ..receptionId = map['reception_id']
                                            ..contactId   = map['contact_id']
                                            ..id          = map['id']).toList();
      }
    } catch(error) {
      orf.logger.errorContext('Error: "${error}" from ${json['bcc']} ', context);
    }
  }
}

class DistributionListEntry {
  int id;
  int receptionId;
  int contactId;
}
