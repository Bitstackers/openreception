part of model;

class Reception {
  int id;
  int organization_id;
  String full_name;
  String product;
  String other;
  String greeting;
  String customertype;
  String extradatauri;
  bool enabled;
  String number;

  List<String> addresses;
  List<String> alternatenames;
  List<String> bankinginformation;
  List<String> crapcallhandling;
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

  factory Reception.fromJson(Map json) {
    Reception reception = new Reception()
        ..id = json['id']
        ..organization_id = json['organization_id']
        ..full_name = stringFromJson(json, 'full_name')
        ..enabled = json['enabled']
        ..number = json['number'];

    if (json.containsKey('attributes')) {
      Map attributes = json['attributes'];

      reception
          ..product = stringFromJson(attributes, 'product')
          ..other = stringFromJson(attributes, 'other')
          ..greeting = stringFromJson(attributes, 'greeting')
          ..customertype = stringFromJson(attributes, 'customertype')

          ..addresses = priorityListFromJson(attributes, 'addresses')
          ..alternatenames = priorityListFromJson(attributes, 'alternatenames')
          ..bankinginformation = priorityListFromJson(attributes, 'bankinginformation')
          ..crapcallhandling = priorityListFromJson(attributes, 'crapcallhandling')
          ..emailaddresses = priorityListFromJson(attributes, 'emailaddresses')
          ..handlings = priorityListFromJson(attributes, 'handlings')
          ..openinghours = priorityListFromJson(attributes, 'openinghours')
          ..registrationnumbers = priorityListFromJson(attributes, 'registrationnumbers')
          ..telephonenumbers = priorityListFromJson(attributes, 'telephonenumbers')
          ..websites = priorityListFromJson(attributes, 'websites');
    }

    return reception;
  }

  String toJson() {
    Map attributes = {
      'product': product,
      'other': other,
      'greeting': greeting,
      'customertype': customertype,
      'addresses': priorityListToJson(addresses),
      'alternatenames': priorityListToJson(alternatenames),
      'bankinginformation': priorityListToJson(bankinginformation),
      'crapcallhandling': priorityListToJson(crapcallhandling),
      'emailaddresses': priorityListToJson(emailaddresses),
      'handlings': priorityListToJson(handlings),
      'openinghours': priorityListToJson(openinghours),
      'registrationnumbers': priorityListToJson(registrationnumbers),
      'telephonenumbers': priorityListToJson(telephonenumbers),
      'websites': priorityListToJson(websites)
    };

    Map data = {
      'id': id,
      'orgaanization_id': organization_id,
      'full_name': full_name,
      'enabled': enabled,
      'attributes': attributes,
      'number': number
    };

    return JSON.encode(data);
  }
}
