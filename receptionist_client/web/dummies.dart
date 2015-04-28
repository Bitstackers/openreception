library dummies;

/**
 * A dummy telephone number.
 * TODO: Move to framework.
 */
class TelNum {
  String description;
  String value;
  bool confidential;

  TelNum(String this.value, String this.description, this.confidential);

  TelNum.fromJson(Map json) {
    description = json['description'];
    value = json['value'];
    confidential = json['confidential'];
  }

  TelNum.empty();

  Map toJson() => {
    'description': description,
    'value': value,
    'confidential': confidential
  };
}
