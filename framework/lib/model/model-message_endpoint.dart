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
  }

  @override
  String toString() => '${this.type}:${this.address}';

}