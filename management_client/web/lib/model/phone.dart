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
    Phone object = new Phone();
    object.id = json['id'];
    object.value = json['value'];
    object.kind = json['kind'];
    object.description = json['description'];
    object.bill_type = json['bill_type'];
    object.tag = json['tag'];
    object.confidential = json.containsKey('confidential') ? json['confidential'] : false;

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
