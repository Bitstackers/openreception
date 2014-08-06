part of model;

class Colleague {
  bool   enabled;
  int    id;
  String full_name;
  String type;

  Colleague.fromJson(Map json) {
    id        = json['id'];
    full_name = json['full_name'];
    enabled   = json['enabled'];
    type      = json['contact_type'];
  }
}
