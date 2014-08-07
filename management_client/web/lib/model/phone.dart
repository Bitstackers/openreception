part of model;

class Phone {
  int    id;
  String billType; //Landline, mobile, which foreign country
  bool   confidential = false;
  String description;
  String kind;
  String tag; //tags
  String value;

  Phone();

  Phone.fromJson(Map json) {
    id = json['id'];
    value = json['value'];
    kind = json['kind'];
    description = json['description'];
    billType = json['bill_type'];
    tag = json['tag'];
    confidential = json.containsKey('confidential') ? json['confidential'] : false;
  }

  Map toJson() => {
    'id': id,
    'value': value,
    'kind': kind,
    'description': description,
    'bill_type': billType,
    'tag': tag,
    'confidential': confidential};
}
