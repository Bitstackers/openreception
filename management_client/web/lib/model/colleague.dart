part of model;

class Colleague {
  int id;
  String full_name;
  bool enabled;
  String type;

  Colleague();

  factory Colleague.fromJson(Map json) {
    Colleague object = new Colleague();
    object.id = json['id'];
    object.full_name = json['full_name'];
    object.enabled = json['enabled'];
    object.type = json['contact_type'];

    return object;
  }

  String toJson() {
    Map data = {
      'id': id,
      'full_name': full_name,
      'enabled': enabled,
      'contact_type': type
    };

    return JSON.encode(data);
  }
}
class ReceptionColleague {
  int id;
  int organization_id;
  String full_name;
  bool enabled;
  List<Colleague> contacts;

  ReceptionColleague();

  factory ReceptionColleague.fromJson(Map json) {
    ReceptionColleague object = new ReceptionColleague();
    object.id = json['id'];
    object.organization_id = json['organization_id'];
    object.full_name = json['full_name'];
    object.enabled = json['enabled'];
    object.contacts = (json['contacts'] as List).map((Map c) => new Colleague.fromJson(c)).toList();

    return object;
  }

  String toJson() {
    Map data = {
      'id': id,
      'organization_id': organization_id,
      'full_name': full_name,
      'enabled': enabled,
      'contacts': contacts
    };

    return JSON.encode(data);
  }

  static int sortByName(ReceptionColleague a, ReceptionColleague b) => a.full_name.compareTo(b.full_name);
}
