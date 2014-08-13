part of openreception.model;

class MessageRecipient extends MessageContext {

  final String className = libraryName + "MessageRecipient";

  String                role      = null;
  List<MessageEndpoint> endpoints = [];

  /**
   * Parsing constructor. Takes in an object similar to MessageContext, with the
   * exception of having an extra 'role' field.
   */
  MessageRecipient.fromMap(Map map, {String role : Role.TO}) : super.fromMap(map) {
    assert(Role.RECIPIENT_ROLES.contains(role));
    this.role = role;

    if (map.containsKey('endpoints')) {
      this.endpoints = (map['endpoints'] as List).map ((Map endpointMap) =>
          new MessageEndpoint.fromMap(endpointMap)..recipient = this).toList();
    }
  }

  String toString() => '${this.role}: ${super.toString()}, endpoints: ${this.endpoints}';
}