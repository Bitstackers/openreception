part of openreception.model;


/**
 * Serialization values.
 * TODO: Check where the "shortgreeting" field comes from in the serialization data. It seems unused.
 */
abstract class ReceptionJSONKey {
  static const String ID                    = 'reception_id';
  static const String FULL_NAME             = 'full_name';
  static const String ENABLED               = 'enabled';
  static const String EXTRADATA_URI         = 'extradatauri';
  static const String EXTENSION             = 'reception_telephonenumber';
  static const String LAST_CHECK            = 'last_check';
  static const String SHORT_GREETING        = 'short_greeting';
  static const String GREETING              = 'greeting';
  static const String ADDRESSES             = 'addresses';

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

  ///FIXME: This value should be removed as soon as the lists in the JSON data format is changed everywhere.
  static const String FIXME_VALUE           = 'value';
  }

class Reception {

  static const String className = '$libraryName.Reception';
  static final Logger log       = new Logger(Reception.className);
  static const int    noID  =    0;


  int          ID                     = noID;
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


  String get name          => this.values[ReceptionJSONKey.FULL_NAME];
  String get extension     => this.values[ReceptionJSONKey.EXTENSION];
  String get greeting      => this.values[ReceptionJSONKey.GREETING];
  String get otherData     => this.values[ReceptionJSONKey.OTHER];
  String get shortGreeting => this.values[ReceptionJSONKey.SHORT_GREETING];
  String get customertype  => this.values[ReceptionJSONKey.CUSTOMER_TYPE];
  String get product       => this.values[ReceptionJSONKey.PRODUCT];
  bool   get enabled       => this.values[ReceptionJSONKey.ENABLED];

  Map values = {};

  Reception.fromMap(Map receptionMap) {
    if (receptionMap == null) throw new ArgumentError('Null map');



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
          ..extraData              = Uri.parse(receptionMap[ReceptionJSONKey.EXTRADATA_URI])
         ..addresses              = extractValues(receptionMap[ReceptionJSONKey.ADDRESSES])
         ..alternateNames         = extractValues(receptionMap[ReceptionJSONKey.ALT_NAMES])
         //TODO: Reintroduce this field when the date format has converged.
         //..lastChecked            = new DateTime.fromMillisecondsSinceEpoch(receptionMap[ReceptionJSONKey.LAST_CHECK], isUtc: true)
         ..bankingInformation     = extractValues(receptionMap[ReceptionJSONKey.BANKING_INFO])
         ..salesMarketingHandling = extractValues(receptionMap[ReceptionJSONKey.SALES_MARKET_HANDLING])
         ..emailAddresses         = extractValues(receptionMap[ReceptionJSONKey.EMAIL_ADDRESSES])
         ..handlingInstructions   = extractValues(receptionMap[ReceptionJSONKey.HANDLING_INSTRUCTIONS])
         ..openingHours           = extractValues(receptionMap[ReceptionJSONKey.OPENING_HOURS])
         ..vatNumbers             = extractValues(receptionMap[ReceptionJSONKey.VAT_NUMBERS])
         ..telephonenumbers       = extractValues(receptionMap[ReceptionJSONKey.PHONE_NUMBERS])
         ..websites               = extractValues(receptionMap[ReceptionJSONKey.WEBSITES])
         // Finallly add the remaining values.
         ..values.addAll(receptionMap);
    } catch (error, stacktrace) {
      log.severe(error,stacktrace);
      throw new ArgumentError('Invalid data in map');
    }

    this.validate();
  }

  /**
   * Returns a Map representation of the Reception.
   */
  Map get asMap =>
    {
      ReceptionJSONKey.ID                    : this.ID,
      ReceptionJSONKey.FULL_NAME             : this.name,
      ReceptionJSONKey.ENABLED               : this.enabled,
      ReceptionJSONKey.EXTRADATA_URI         : this.extraData.toString(),
      ReceptionJSONKey.EXTENSION             : this.extension,
      ReceptionJSONKey.LAST_CHECK            : this.lastChecked.toUtc().millisecondsSinceEpoch,
      ReceptionJSONKey.SHORT_GREETING        : this.shortGreeting,
      ReceptionJSONKey.GREETING              : this.greeting,
      ReceptionJSONKey.ADDRESSES             : this.addresses,
      ReceptionJSONKey.ALT_NAMES             : this.alternateNames,
      ReceptionJSONKey.CUSTOMER_TYPE         : this.customertype,
      ReceptionJSONKey.PRODUCT               : this.product,
      ReceptionJSONKey.BANKING_INFO          : this.bankingInformation,
      ReceptionJSONKey.SALES_MARKET_HANDLING : this.salesMarketingHandling,
      ReceptionJSONKey.EMAIL_ADDRESSES       : this.emailAddresses,
      ReceptionJSONKey.HANDLING_INSTRUCTIONS : this.handlingInstructions,
      ReceptionJSONKey.OPENING_HOURS         : this.openingHours,
      ReceptionJSONKey.VAT_NUMBERS           : this.vatNumbers,
      ReceptionJSONKey.OTHER                 : this.otherData,
      ReceptionJSONKey.PHONE_NUMBERS         : this.telephonenumbers,
      ReceptionJSONKey.WEBSITES              : this.websites
    };

  void validate() {
    log.severe ('Implement me - i\'m not finished!');
    if (this.shortGreeting.isEmpty) throw new StateError('Short greeting not allowed to be empty');
    if (this.greeting.isEmpty)      throw new StateError('Greeting not allowed to be empty');
  }
}
