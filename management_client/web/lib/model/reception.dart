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
    id = json[ReceptionJSONKey.ID];
    organizationId = json[ReceptionJSONKey.ORGANIZATION_ID];
    fullName = stringFromJson(json, ReceptionJSONKey.FULL_NAME);
    enabled = json[ReceptionJSONKey.ENABLED];
    receptionNumber = json[ReceptionJSONKey.EXTENSION];
    extradatauri = json[ReceptionJSONKey.EXTRADATA_URI];

    if (json.containsKey(ReceptionJSONKey.ATTRIBUTES)) {
      attributes = json[ReceptionJSONKey.ATTRIBUTES];

      product = stringFromJson(attributes, ReceptionJSONKey.PRODUCT);
      other = stringFromJson(attributes, ReceptionJSONKey.OTHER);
      greeting = stringFromJson(attributes, ReceptionJSONKey.GREETING);
      shortGreeting = stringFromJson(attributes, ReceptionJSONKey.SHORT_GREETING);
      customertype = stringFromJson(attributes, ReceptionJSONKey.CUSTOMER_TYPE);

      addresses = attributes[ReceptionJSONKey.ADDRESSES];
      alternateNames = attributes[ReceptionJSONKey.ALT_NAMES];
      bankinginformation = attributes[ReceptionJSONKey.BANKING_INFO];
      salesCalls = attributes[ReceptionJSONKey.SALES_MARKET_HANDLING];
      emailaddresses = attributes[ReceptionJSONKey.EMAIL_ADDRESSES];
      handlings = attributes[ReceptionJSONKey.HANDLING_INSTRUCTIONS];
      openinghours = attributes[ReceptionJSONKey.OPENING_HOURS];
      registrationnumbers = attributes[ReceptionJSONKey.VAT_NUMBERS];
      telephonenumbers = attributes[ReceptionJSONKey.PHONE_NUMBERS];
      websites = attributes[ReceptionJSONKey.WEBSITES];
    }
  }

  Map toJson() {
    attributes[ReceptionJSONKey.PRODUCT] = product;
    attributes[ReceptionJSONKey.OTHER] = other;
    attributes[ReceptionJSONKey.GREETING] = greeting;
    attributes[ReceptionJSONKey.SHORT_GREETING] = shortGreeting;

    attributes[ReceptionJSONKey.ADDRESSES] = addresses;
    attributes[ReceptionJSONKey.ALT_NAMES] = alternateNames;
    attributes[ReceptionJSONKey.BANKING_INFO] = bankinginformation;
    attributes[ReceptionJSONKey.SALES_MARKET_HANDLING] = salesCalls;
    attributes[ReceptionJSONKey.EMAIL_ADDRESSES] = emailaddresses;
    attributes[ReceptionJSONKey.HANDLING_INSTRUCTIONS] = handlings;
    attributes[ReceptionJSONKey.OPENING_HOURS] = openinghours;
    attributes[ReceptionJSONKey.VAT_NUMBERS] = registrationnumbers;
    attributes[ReceptionJSONKey.PHONE_NUMBERS] = telephonenumbers;
    attributes[ReceptionJSONKey.WEBSITES] = websites;

    Map data = {
      ReceptionJSONKey.ID: id,
      ReceptionJSONKey.ORGANIZATION_ID: organizationId,
      ReceptionJSONKey.FULL_NAME: fullName,
      ReceptionJSONKey.ENABLED: enabled,
      ReceptionJSONKey.ATTRIBUTES: attributes,
      ReceptionJSONKey.EXTENSION: receptionNumber,
      ReceptionJSONKey.EXTRADATA_URI: extradatauri,
      'contacts': contacts
    };
    return data;
  }

  @override
  int compareTo(Reception other) => this.fullName.compareTo(other.fullName);
}
