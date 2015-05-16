part of openreception.model;

abstract class MessageEndpointType {
  static const String SMS   = 'sms';
  static const String EMAIL = 'email';
}

class MessageEndpoint {

  String type;
  String address;
  String description;
  bool   confidential;
  bool   enabled;

  //TODO: Check if this is still needed.
  MessageRecipient recipient = null;

  MessageEndpoint.fromMap(Map map) {
    /// Map validation.
    assert(['type','address'].every((String key) => map.containsKey(key)));
    this.type    = map['type'];

    this.address = map['address'];
    this.confidential = map['confidential'];
    this.description = map['description'];

    this.enabled = map['enabled'];
    if (map.containsKey('recipient')) {
      this.recipient = new MessageRecipient.fromMap(map['recipient']);
    }

  }

  Map toJson() => this.asMap;

  Map get asMap => {
        'type' : this.type,
        'address' : this.address,
        'confidential' : this.confidential,
        'enabled' : this.enabled,
        'description' : this.description
        };

  @override
  String toString() => '${this.type}:${this.address}';

}