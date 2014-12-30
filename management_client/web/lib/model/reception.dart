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

    if (json.containsKey('attributes')) {
      Map attributes = json['attributes'];

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
    Map attributes = {
      'product': product,
      'other': other,
      'greeting': greeting,
      'shortgreeting': shortGreeting,
      'customertype': customertype,
      'addresses': priorityListToJson(addresses),
      'alternatenames': priorityListToJson(alternateNames),
      'bankinginformation': priorityListToJson(bankinginformation),
      'salescalls': priorityListToJson(salesCalls),
      'emailaddresses': priorityListToJson(emailaddresses),
      'handlings': priorityListToJson(handlings),
      'openinghours': priorityListToJson(openinghours),
      'registrationnumbers': priorityListToJson(registrationnumbers),
      'telephonenumbers': priorityListToJson(telephonenumbers),
      'websites': priorityListToJson(websites)
    };

    Map data = {
      'id': id,
      'organization_id': organizationId,
      'full_name': fullName,
      'enabled': enabled,
      'attributes': attributes,
      'reception_telephonenumber': receptionNumber,
      'contacts': contacts
    };
    return data;
  }

  @override
  int compareTo(Reception other) => this.fullName.compareTo(other.fullName);
}
