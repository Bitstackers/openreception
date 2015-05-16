part of openreception.model;

abstract class PhoneNumberJSONKey {
  static const String Description = 'description';
  static const String Value = 'value';
  static const String Confidential = 'confidential';
  static const String Type = 'kind';
  static const String Billing_type = 'billing_type';
  static const String Tag = 'tag';

}

class PhoneNumber {
  String description;
  String value;
  String type;
  bool confidential;
  String billing_type;
  List<String> tags = [];

  PhoneNumber.fromMap(Map map) {
    description = map[PhoneNumberJSONKey.Description];
    value = map[PhoneNumberJSONKey.Value];
    confidential = map[PhoneNumberJSONKey.Confidential];
    type = map[PhoneNumberJSONKey.Type];
    billing_type = map[PhoneNumberJSONKey.Billing_type];

    var newTags = map[PhoneNumberJSONKey.Tag];

    if (newTags is Iterable<String>) {
      tags.addAll(newTags);
    }
    else if (newTags is String) {
      tags.add(newTags);
    }

  }

  PhoneNumber.empty();

  Map toJson () => this.asMap;

  Map get asMap => {
    PhoneNumberJSONKey.Value: value,
    PhoneNumberJSONKey.Type: type,
    PhoneNumberJSONKey.Description: description,
    PhoneNumberJSONKey.Billing_type: billing_type,
    PhoneNumberJSONKey.Tag: tags,
    PhoneNumberJSONKey.Confidential: confidential
  };
}
