part of model;

class DistributionList {
  List<DistributionListEntry> to  = new List<DistributionListEntry>();
  List<DistributionListEntry> cc  = new List<DistributionListEntry>();
  List<DistributionListEntry> bcc = new List<DistributionListEntry>();

  DistributionList();

  DistributionList.fromJson(Map json) {
    if(json['to'] != null && json['to'] is List) {
      List list = json['to'];
      this.to = list.map(_createEntryFromJson).toList();
    }

    if(json['cc'] != null && json['cc'] is List) {
      List list = json['cc'];
      this.cc = list.map(_createEntryFromJson).toList();
    }

    if(json['bcc'] != null && json['bcc'] is List) {
      List list = json['bcc'];
      this.bcc = list.map(_createEntryFromJson).toList();
    }
  }

  DistributionListEntry _createEntryFromJson(Map map) =>
      new DistributionListEntry()
        ..contactId   = map['contact_id']
        ..receptionId = map['reception_id']
        ..id          = map['id'];

  Map toJson() =>
    {'to' : to .map(_entryToJson).toList(),
     'cc' : cc .map(_entryToJson).toList(),
     'bcc': bcc.map(_entryToJson).toList()
    };

  Map _entryToJson(DistributionListEntry entry) =>
      {'reception_id': entry.receptionId,
       'contact_id'  : entry.contactId,
       'id'          : entry.id};

  //TODO Delete
  bool equals(DistributionList other) {
    if(to.length != other.to.length ||
       cc.length != other.cc.length ||
       bcc.length != other.bcc.length) {
      return false;
    }

    for(DistributionListEntry entry in to) {
      if(!other.to.any((DistributionListEntry otherEntry) => entry.contactId == otherEntry.contactId && entry.receptionId == otherEntry.receptionId)) {
        return false;
      }
    }

    for(DistributionListEntry entry in cc) {
      if(!other.cc.any((DistributionListEntry otherEntry) => entry.contactId == otherEntry.contactId && entry.receptionId == otherEntry.receptionId)) {
        return false;
      }
    }

    for(DistributionListEntry entry in bcc) {
      if(!other.bcc.any((DistributionListEntry otherEntry) => entry.contactId == otherEntry.contactId && entry.receptionId == otherEntry.receptionId)) {
        return false;
      }
    }
    return true;
  }
}

class DistributionListEntry {
  int id;
  int receptionId;
  int contactId;
  String role;

  Map toJson() => {
    'contact_id': contactId,
    'reception_id': receptionId,
    'id': id,
    'role': role
  };
}

