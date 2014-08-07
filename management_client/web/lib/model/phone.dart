part of model;

class Phone {
  int    id;
  String billingType; //Landline, mobile, which foreign country
  bool   confidential = false;
  String description;
  String kind;
  String tag; //tags
  String value;

  Phone();

  Phone.fromJson(Map json) {
    id           = json['id'];
    value        = json['value'];
    kind         = json['kind'];
    description  = json['description'];
    billingType  = json['billing_type'];
    tag          = json['tag'];
    confidential = json.containsKey('confidential') ? json['confidential'] : false;
  }

  Map toJson() => {
    'id'          : id,
    'value'       : value,
    'kind'        : kind,
    'description' : description,
    'billing_type': billingType,
    'tag'         : tag,
    'confidential': confidential};
}
