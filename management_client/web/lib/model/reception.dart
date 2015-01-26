part of model;

class Reception implements Comparable<Reception> {
  List<Contact> contacts;
  int id;
  int organizationId;
  String fullName;
  String product;
  String other;
  String greeting;
  String shortGreeting;
  String customertype;
  String extradatauri;
  bool enabled;
  String receptionNumber;

  List<String> addresses;
  List<String> alternateNames;
  List<String> bankinginformation;
  List<String> salesCalls;
  List<String> emailaddresses;
  List<String> handlings;
  List<String> openinghours;
  List<String> registrationnumbers;
  List<String> telephonenumbers;
  List<String> websites;

  Map attributes = {};
  /**
   * Default constructor
   */
  Reception();

  Reception.fromJson(Map json) {
    List<Map> contacts = json['contacts'] as List;
    if(contacts != null) {
      this.contacts = contacts.map((Map c) => new Contact.fromJson(c)).toList();
    }
    id = json['id'];
    organizationId = json['organization_id'];
    fullName = stringFromJson(json, 'full_name');
    enabled = json['enabled'];
    receptionNumber = json['reception_telephonenumber'];
    extradatauri = json['extradatauri'];

    if (json.containsKey('attributes')) {
      attributes = json['attributes'];

      product = stringFromJson(attributes, 'product');
      other = stringFromJson(attributes, 'other');
      greeting = stringFromJson(attributes, 'greeting');
      shortGreeting = stringFromJson(attributes, 'shortgreeting');
      customertype = stringFromJson(attributes, 'customertype');

      addresses = attributes['addresses'];
      alternateNames = attributes['alternatenames'];
      bankinginformation = attributes['bankinginformation'];
      salesCalls = attributes['salescalls'];
      emailaddresses = attributes['emailaddresses'];
      handlings = attributes['handlings'];
      openinghours = attributes['openinghours'];
      registrationnumbers = attributes['registrationnumbers'];
      telephonenumbers = attributes['telephonenumbers'];
      websites = attributes['websites'];
    }
  }

  Map toJson() {
    attributes['product'] = product;
    attributes['other'] = other;
    attributes['greeting'] = greeting;
    attributes['shortgreeting'] = shortGreeting;

    attributes['addresses'] = addresses;
    attributes['alternatenames'] = alternateNames;
    attributes['bankinginformation'] = bankinginformation;
    attributes['salescalls'] = salesCalls;
    attributes['emailaddresses'] = emailaddresses;
    attributes['handlings'] = handlings;
    attributes['openinghours'] = openinghours;
    attributes['registrationnumbers'] = registrationnumbers;
    attributes['telephonenumbers'] = telephonenumbers;
    attributes['websites'] = websites;

    Map data = {
      'id': id,
      'organization_id': organizationId,
      'full_name': fullName,
      'enabled': enabled,
      'attributes': attributes,
      'reception_telephonenumber': receptionNumber,
      'extradatauri': extradatauri,
      'contacts': contacts
    };
    return data;
  }

  @override
  int compareTo(Reception other) => this.fullName.compareTo(other.fullName);
}
