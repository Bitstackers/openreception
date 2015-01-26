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

      addresses = priorityListFromJson(attributes, 'addresses');
      alternateNames = priorityListFromJson(attributes, 'alternatenames');
      bankinginformation = priorityListFromJson(attributes, 'bankinginformation');
      salesCalls = priorityListFromJson(attributes, 'salescalls');
      emailaddresses = priorityListFromJson(attributes, 'emailaddresses');
      handlings = priorityListFromJson(attributes, 'handlings');
      openinghours = priorityListFromJson(attributes, 'openinghours');
      registrationnumbers = priorityListFromJson(attributes, 'registrationnumbers');
      telephonenumbers = priorityListFromJson(attributes, 'telephonenumbers');
      websites = priorityListFromJson(attributes, 'websites');
    }
  }

  Map toJson() {
    attributes['product'] = product;
    attributes['other'] = other;
    attributes['greeting'] = greeting;
    attributes['shortgreeting'] = shortGreeting;

    attributes['addresses'] = priorityListToJson(addresses);
    attributes['alternatenames'] = priorityListToJson(alternateNames);
    attributes['bankinginformation'] = priorityListToJson(bankinginformation);
    attributes['salescalls'] = priorityListToJson(salesCalls);
    attributes['emailaddresses'] = priorityListToJson(emailaddresses);
    attributes['handlings'] = priorityListToJson(handlings);
    attributes['openinghours'] = priorityListToJson(openinghours);
    attributes['registrationnumbers'] = priorityListToJson(registrationnumbers);
    attributes['telephonenumbers'] = priorityListToJson(telephonenumbers);
    attributes['websites'] = priorityListToJson(websites);

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
