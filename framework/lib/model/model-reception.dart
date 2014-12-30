part of openreception.model;


/**
 * Serialization values.
 * TODO: Check where the "shortgreeting" field comes from in the serialization data. It seems unused.
 */
abstract class ReceptionJSONKey {
  static const String ID                    = 'id';
  static const String ORGANIZATION_ID       = 'organization_id';
  static const String FULL_NAME             = 'full_name';
  static const String ENABLED               = 'enabled';
  static const String EXTRADATA_URI         = 'extradatauri';
  static const String EXTENSION             = 'reception_telephonenumber';
  static const String LAST_CHECK            = 'last_check';
  static const String SHORT_GREETING        = 'shortgreeting'; //TODO WRONG Should be short_greeting
  static const String GREETING              = 'greeting';
  static const String ADDRESSES             = 'addresses';
  static const String ATTRIBUTES            = 'attributes';

  static const String ALT_NAMES             = 'alternatenames';
  static const String CUSTOMER_TYPE         = 'customertype';
  static const String PRODUCT               = 'product';
  static const String BANKING_INFO          = 'bankinginformation';
  static const String SALES_MARKET_HANDLING = 'crapcallhandling';
  static const String EMAIL_ADDRESSES       = 'emailaddresses';
  static const String HANDLING_INSTRUCTIONS = 'handlings';
  static const String OPENING_HOURS         = 'openinghours';
  static const String VAT_NUMBERS           = 'registrationnumbers';
  static const String OTHER                 = 'other';
  static const String PHONE_NUMBERS         = 'telephonenumbers';
  static const String WEBSITES              = 'websites';

  static const String RECEPTION_LIST        = 'receptions';

  ///FIXME: This value should be removed as soon as the lists in the JSON data format is changed everywhere.
  static const String FIXME_VALUE           = 'value';
  }

class Reception {

  static const String className = '$libraryName.Reception';
  static final Logger log       = new Logger(Reception.className);
  static const int    noID      =    0;


  int          ID                     = noID;
  int          organizationId         = noID;
  Uri          extraData              = null;
  DateTime     lastChecked            = new DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  List<String> addresses              = [];
  List<String> alternateNames         = [];
  List<String> bankingInformation     = [];
  List<String> salesMarketingHandling = [];
  List<String> emailAddresses         = [];
  List<String> handlingInstructions   = [];
  List<String> openingHours           = [];
  List<String> vatNumbers             = [];
  List<String> telephonenumbers       = [];
  List<String> websites               = [];


  String fullName;
  String extension;
  String greeting;
  String otherData;
  String shortGreeting;
  String customertype;
  String product;
  bool   enabled = false;

  Map attributes = {};

  Reception();

  Reception.fromMap(Map receptionMap) {
    if (receptionMap == null) throw new ArgumentError('Null map');


    //TODO Remove extractValuesFromList and extractValues once the format is corrected.
    List<String> extractValuesFromList(List<Map> list)
        => []..addAll(list.map((Map tuple) => tuple[ReceptionJSONKey.FIXME_VALUE]));

    List<String> extractValues(List list) {
      if (list == null)         return [];
      if (list.isEmpty)         return [];
      if (list.first is Map)    return extractValuesFromList(list);
      if (list.first is String) return list;

      throw new ArgumentError('Bad list type: ${list.runtimeType}');
    }

    try {
      this..ID                     = receptionMap[ReceptionJSONKey.ID]
          ..organizationId         = receptionMap[ReceptionJSONKey.ORGANIZATION_ID]
          ..fullName               = receptionMap[ReceptionJSONKey.FULL_NAME]
          ..enabled                = receptionMap[ReceptionJSONKey.ENABLED]
          ..extension              = receptionMap[ReceptionJSONKey.EXTENSION]
          ..extraData              = receptionMap[ReceptionJSONKey.EXTRADATA_URI] != null ? Uri.parse(receptionMap[ReceptionJSONKey.EXTRADATA_URI]) : null;
          //TODO: Reintroduce this field when the date format has converged.
          //..lastChecked            = new DateTime.fromMillisecondsSinceEpoch(receptionMap[ReceptionJSONKey.LAST_CHECK], isUtc: true)

       if (receptionMap[ReceptionJSONKey.ATTRIBUTES] != null) {
         attributes = receptionMap[ReceptionJSONKey.ATTRIBUTES];

         this..addresses              = extractValues(attributes[ReceptionJSONKey.ADDRESSES])
             ..alternateNames         = extractValues(attributes[ReceptionJSONKey.ALT_NAMES])
             ..bankingInformation     = extractValues(attributes[ReceptionJSONKey.BANKING_INFO])
             ..customertype           = attributes[ReceptionJSONKey.CUSTOMER_TYPE]
             ..emailAddresses         = extractValues(attributes[ReceptionJSONKey.EMAIL_ADDRESSES])
             ..greeting               = attributes[ReceptionJSONKey.GREETING]
             ..handlingInstructions   = extractValues(attributes[ReceptionJSONKey.HANDLING_INSTRUCTIONS])
             ..openingHours           = extractValues(attributes[ReceptionJSONKey.OPENING_HOURS])
             ..otherData              = attributes[ReceptionJSONKey.OTHER]
             ..product                = attributes[ReceptionJSONKey.PRODUCT]
             ..salesMarketingHandling = extractValues(attributes[ReceptionJSONKey.SALES_MARKET_HANDLING])
             ..shortGreeting          = attributes[ReceptionJSONKey.SHORT_GREETING]
             ..vatNumbers             = extractValues(attributes[ReceptionJSONKey.VAT_NUMBERS])
             ..telephonenumbers       = extractValues(attributes[ReceptionJSONKey.PHONE_NUMBERS])
             ..websites               = extractValues(attributes[ReceptionJSONKey.WEBSITES]);
       }

    } catch (error, stacktrace) {
      log.severe('Parsing of reception failed.', error, stacktrace);
      throw new ArgumentError('Invalid data in map');
    }

    this.validate();
  }

  /**
   * Returns a Map representation of the Reception.
   */
  Map get asMap {
    List priorityListToJson(List<String> list) {
      List<Map> result = new List<Map>();

      int priority = 1;
      for (String item in list) {
        result.add({
          'priority': priority,
          'value': item
        });
      }

      return result;
    }

    attributes[ReceptionJSONKey.ADDRESSES]             = priorityListToJson(this.addresses);
    attributes[ReceptionJSONKey.ALT_NAMES]             = priorityListToJson(this.alternateNames);
    attributes[ReceptionJSONKey.BANKING_INFO]          = priorityListToJson(this.bankingInformation);
    attributes[ReceptionJSONKey.CUSTOMER_TYPE]         = this.customertype;
    attributes[ReceptionJSONKey.EMAIL_ADDRESSES]       = priorityListToJson(this.emailAddresses);
    attributes[ReceptionJSONKey.GREETING]              = this.greeting;
    attributes[ReceptionJSONKey.HANDLING_INSTRUCTIONS] = priorityListToJson(this.handlingInstructions);
    attributes[ReceptionJSONKey.OPENING_HOURS]         = priorityListToJson(this.openingHours);
    attributes[ReceptionJSONKey.OTHER]                 = this.otherData;
    attributes[ReceptionJSONKey.PRODUCT]               = this.product;
    attributes[ReceptionJSONKey.SALES_MARKET_HANDLING] = priorityListToJson(this.salesMarketingHandling);
    attributes[ReceptionJSONKey.SHORT_GREETING]        = this.shortGreeting;
    attributes[ReceptionJSONKey.VAT_NUMBERS]           = priorityListToJson(this.vatNumbers);
    attributes[ReceptionJSONKey.PHONE_NUMBERS]         = priorityListToJson(this.telephonenumbers);
    attributes[ReceptionJSONKey.WEBSITES]              = priorityListToJson(this.websites);

    Map map = {
      ReceptionJSONKey.ID              : this.ID,
      ReceptionJSONKey.ORGANIZATION_ID : this.organizationId,
      ReceptionJSONKey.FULL_NAME       : this.fullName,
      ReceptionJSONKey.ENABLED         : this.enabled,
      ReceptionJSONKey.EXTRADATA_URI   : this.extraData.toString(),
      ReceptionJSONKey.EXTENSION       : this.extension,
      ReceptionJSONKey.LAST_CHECK      : this.lastChecked.toUtc().millisecondsSinceEpoch,
      ReceptionJSONKey.ATTRIBUTES      : attributes
    };
    return map;
  }


  void validate() {
    log.severe ('Implement me - i\'m not finished!');
    if (this.shortGreeting == null || this.shortGreeting.isEmpty) throw new StateError('Short greeting not allowed to be empty. Value: "${this.shortGreeting}" Id: "${this.ID}" ReceptionName: "${this.fullName}"');
    if (this.greeting      == null || this.greeting.isEmpty)      throw new StateError('Greeting not allowed to be empty. Value: "${this.greeting}" Id: "${this.ID}" ReceptionName: "${this.fullName}"');
  }
}
