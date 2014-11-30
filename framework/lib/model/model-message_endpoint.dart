part of openreception.model;

abstract class MessageEndpointType {
  static const String SMS   = 'sms';
  static const String EMAIL = 'email';
}

class MessageEndpoint {

  String           type      = null;
  String           address   = null;
  MessageRecipient recipient = null;

  MessageEndpoint.fromMap(Map map) {
    /// Map validation.
    assert(['type','address'].every((String key) => map.containsKey(key)));
    this.type    = map['type'];
    this.address = map['address'];

    if (map.containsKey('recipient')) {
      this.recipient = new MessageRecipient.fromMap(map['recipient']);
    }

  }

  Map toJson() => this.asMap;

  Map get asMap => {
        'type' : this.type,
        'address' : this.address
        };

  @override
  String toString() => '${this.type}:${this.address}';

}