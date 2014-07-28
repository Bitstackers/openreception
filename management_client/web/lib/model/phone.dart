part of model;

class Phone {
  int id;
  String value;
  String kind;
  String description;
  String bill_type; //Landline, mobile, which foreign country
  String tag; //tags
  bool confidential = false;

  Phone();

  factory Phone.fromJson(Map json) {
    Phone object = new Phone()
      ..id = json['id']
      ..value = json['value']
      ..kind = json['kind']
      ..description = json['description']
      ..bill_type = json['bill_type']
      ..tag = json['tag']
      ..confidential = json.containsKey('confidential') ? json['confidential'] : false;

    return object;
  }

  Map toJson() => {
    'id': id,
    'value': value,
    'kind': kind,
    'description': description,
    'bill_type': bill_type,
    'tag': tag,
    'confidential': confidential};
}
