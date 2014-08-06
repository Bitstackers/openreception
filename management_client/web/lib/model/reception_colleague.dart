part of model;

class ReceptionColleague {
  int id;
  int organization_id;
  String full_name;
  bool enabled;
  List<Colleague> contacts;

  ReceptionColleague();

  factory ReceptionColleague.fromJson(Map json) {
    ReceptionColleague object = new ReceptionColleague()
      ..id = json['id']
      ..organization_id = json['organization_id']
      ..full_name = json['full_name']
      ..enabled = json['enabled']
      ..contacts = (json['contacts'] as List).map((Map c) => new Colleague.fromJson(c)).toList();

    return object;
  }

  Map toJson() {
    Map data = {
      'id': id,
      'organization_id': organization_id,
      'full_name': full_name,
      'enabled': enabled,
      'contacts': contacts
    };

    return data;
  }

  static int sortByName(ReceptionColleague a, ReceptionColleague b) => a.full_name.compareTo(b.full_name);
}
