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
    id = json[ORF.ReceptionJSONKey.ID];
    organizationId = json[ORF.ReceptionJSONKey.ORGANIZATION_ID];
    fullName = stringFromJson(json, ORF.ReceptionJSONKey.FULL_NAME);
    enabled = json[ORF.ReceptionJSONKey.ENABLED];
    receptionNumber = json[ORF.ReceptionJSONKey.EXTENSION];
    extradatauri = json[ORF.ReceptionJSONKey.EXTRADATA_URI];

    if (json.containsKey(ORF.ReceptionJSONKey.ATTRIBUTES)) {
      attributes = json[ORF.ReceptionJSONKey.ATTRIBUTES];

      product = stringFromJson(attributes, ORF.ReceptionJSONKey.PRODUCT);
      other = stringFromJson(attributes, ORF.ReceptionJSONKey.OTHER);
      greeting = stringFromJson(attributes, ORF.ReceptionJSONKey.GREETING);
      shortGreeting = stringFromJson(attributes, ORF.ReceptionJSONKey.SHORT_GREETING);
      customertype = stringFromJson(attributes, ORF.ReceptionJSONKey.CUSTOMER_TYPE);

      addresses = attributes[ORF.ReceptionJSONKey.ADDRESSES];
      alternateNames = attributes[ORF.ReceptionJSONKey.ALT_NAMES];
      bankinginformation = attributes[ORF.ReceptionJSONKey.BANKING_INFO];
      salesCalls = attributes[ORF.ReceptionJSONKey.SALES_MARKET_HANDLING];
      emailaddresses = attributes[ORF.ReceptionJSONKey.EMAIL_ADDRESSES];
      handlings = attributes[ORF.ReceptionJSONKey.HANDLING_INSTRUCTIONS];
      openinghours = attributes[ORF.ReceptionJSONKey.OPENING_HOURS];
      registrationnumbers = attributes[ORF.ReceptionJSONKey.VAT_NUMBERS];
      telephonenumbers = attributes[ORF.ReceptionJSONKey.PHONE_NUMBERS];
      websites = attributes[ORF.ReceptionJSONKey.WEBSITES];
    }
  }

  Map toJson() {
    attributes[ORF.ReceptionJSONKey.PRODUCT] = product;
    attributes[ORF.ReceptionJSONKey.OTHER] = other;
    attributes[ORF.ReceptionJSONKey.GREETING] = greeting;
    attributes[ORF.ReceptionJSONKey.SHORT_GREETING] = shortGreeting;

    attributes[ORF.ReceptionJSONKey.ADDRESSES] = addresses;
    attributes[ORF.ReceptionJSONKey.ALT_NAMES] = alternateNames;
    attributes[ORF.ReceptionJSONKey.BANKING_INFO] = bankinginformation;
    attributes[ORF.ReceptionJSONKey.SALES_MARKET_HANDLING] = salesCalls;
    attributes[ORF.ReceptionJSONKey.EMAIL_ADDRESSES] = emailaddresses;
    attributes[ORF.ReceptionJSONKey.HANDLING_INSTRUCTIONS] = handlings;
    attributes[ORF.ReceptionJSONKey.OPENING_HOURS] = openinghours;
    attributes[ORF.ReceptionJSONKey.VAT_NUMBERS] = registrationnumbers;
    attributes[ORF.ReceptionJSONKey.PHONE_NUMBERS] = telephonenumbers;
    attributes[ORF.ReceptionJSONKey.WEBSITES] = websites;

    Map data = {
      ORF.ReceptionJSONKey.ID: id,
      ORF.ReceptionJSONKey.ORGANIZATION_ID: organizationId,
      ORF.ReceptionJSONKey.FULL_NAME: fullName,
      ORF.ReceptionJSONKey.ENABLED: enabled,
      ORF.ReceptionJSONKey.ATTRIBUTES: attributes,
      ORF.ReceptionJSONKey.EXTENSION: receptionNumber,
      ORF.ReceptionJSONKey.EXTRADATA_URI: extradatauri,
      'contacts': contacts
    };
    return data;
  }

  @override
  int compareTo(Reception other) => this.fullName.compareTo(other.fullName);
}
