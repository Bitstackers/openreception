part of openreception.model;


/**
 * Serialization values.
 */
abstract class ReceptionJSONKey {
  static const String ID                    = 'id';
  static const String FIXME_ALT_ID          = 'reception_id';
  static const String ORGANIZATION_ID       = 'organization_id';
  static const String FULL_NAME             = 'full_name';
  static const String ENABLED               = 'enabled';
  static const String EXTRADATA_URI         = 'extradatauri';
  static const String EXTENSION             = 'reception_telephonenumber';
  static const String LAST_CHECK            = 'last_check';
  static const String SHORT_GREETING        = 'short_greeting';
  static const String GREETING              = 'greeting';
  static const String ADDRESSES             = 'addresses';
  static const String ATTRIBUTES            = 'attributes';

  static const String ALT_NAMES             = 'alternatenames';
  @deprecated
  static const String CUSTOMER_TYPE         = 'customertype';
  static const String CUSTOMER_TYPES        = 'customertypes';
  static const String PRODUCT               = 'product';
  static const String BANKING_INFO          = 'bankinginformation';
  static const String SALES_MARKET_HANDLING = 'salescalls';
  static const String EMAIL_ADDRESSES       = 'emailaddresses';
  static const String HANDLING_INSTRUCTIONS = 'handlings';
  static const String OPENING_HOURS         = 'openinghours';
  static const String VAT_NUMBERS           = 'registrationnumbers';
  static const String OTHER                 = 'other';
  static const String PHONE_NUMBERS         = 'telephonenumbers';
  static const String WEBSITES              = 'websites';

  static const String RECEPTION_LIST        = 'receptions';

}

class ReceptionStub {

  int    ID       = Reception.noID;
  String fullName = null;

  String get name => this.fullName;

  /**
   * Enables a [ReceptionStub] to sort itself based on its [name].
   */
   int compareTo(ReceptionStub other) => this.name.compareTo(other.name);

  /**
   * [Reception] as String, for debug/log purposes.
   */
   String toString() => '${name}-${ID}';

  ReceptionStub.fromMap (Map map) {
    if (map == null) throw new ArgumentError.notNull('Null map');

    if (map.containsKey(ReceptionJSONKey.FIXME_ALT_ID)) {
      this.ID       = map[ReceptionJSONKey.FIXME_ALT_ID];
    } else {
      this.ID       = map[ReceptionJSONKey.ID];
    }

    this.fullName = map[ReceptionJSONKey.FULL_NAME];
  }

  ReceptionStub.none() : this._null();

  ReceptionStub._null();

}



class Reception extends ReceptionStub {

  static const String className = '$libraryName.Reception';
  static final Logger log       = new Logger(Reception.className);
  static const int    noID      =    0;


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
  List<String> customerTypes          = [];

  String get shortGreeting => this._shortGreeting.isNotEmpty
                                ? this._shortGreeting
                                : this.greeting;
  void   set shortGreeting (String newGreeting)
                           {this._shortGreeting = newGreeting;}

  String extension;
  String greeting;
  String otherData;
  String _shortGreeting = '';
  @deprecated
  String customertype; //Use customertypes
  String product;
  bool   enabled = false;

  Map attributes = {};

  // Default intiliazing contructor
  Reception() : super._null();

  Reception.fromMap(Map receptionMap) : super.fromMap(receptionMap) {

    List<String> extractValues(List list) {
      if (list == null)         return [];
      if (list.isEmpty)         return [];
      if (list.first is Map)    return throw new ArgumentError('Maps are no longer supported. Please upgrade data model.');
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

         //Temporary workaround for customertype to customerTypes transition.
         if (attributes.containsKey(ReceptionJSONKey.CUSTOMER_TYPE)) {
           this.customerTypes = [attributes[ReceptionJSONKey.CUSTOMER_TYPE]];
         } else {
           this.customerTypes = attributes[ReceptionJSONKey.CUSTOMER_TYPES];
         }

         this..addresses              = extractValues(attributes[ReceptionJSONKey.ADDRESSES])
             ..alternateNames         = extractValues(attributes[ReceptionJSONKey.ALT_NAMES])
             ..bankingInformation     = extractValues(attributes[ReceptionJSONKey.BANKING_INFO])
             ..emailAddresses         = extractValues(attributes[ReceptionJSONKey.EMAIL_ADDRESSES])
             ..greeting               = attributes[ReceptionJSONKey.GREETING]
             ..handlingInstructions   = extractValues(attributes[ReceptionJSONKey.HANDLING_INSTRUCTIONS])
             ..openingHours           = extractValues(attributes[ReceptionJSONKey.OPENING_HOURS])
             ..otherData              = attributes[ReceptionJSONKey.OTHER]
             ..product                = attributes[ReceptionJSONKey.PRODUCT]
             ..salesMarketingHandling = extractValues(attributes[ReceptionJSONKey.SALES_MARKET_HANDLING])
             .._shortGreeting         = attributes[ReceptionJSONKey.SHORT_GREETING] != null ? attributes[ReceptionJSONKey.SHORT_GREETING] : ''
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

  Map toJson() => this.asMap;

  /**
   * Returns a Map representation of the Reception.
   */
  Map get asMap {
    Map attributes = {
      ReceptionJSONKey.ADDRESSES :  this.addresses,
    ReceptionJSONKey.ALT_NAMES :this.alternateNames,
    ReceptionJSONKey.BANKING_INFO          : this.bankingInformation,
    ReceptionJSONKey.CUSTOMER_TYPES        : this.customerTypes,
    ReceptionJSONKey.EMAIL_ADDRESSES       : this.emailAddresses,
    ReceptionJSONKey.GREETING              : this.greeting,
    ReceptionJSONKey.HANDLING_INSTRUCTIONS : this.handlingInstructions,
    ReceptionJSONKey.OPENING_HOURS         : this.openingHours,
    ReceptionJSONKey.OTHER                 : this.otherData,
    ReceptionJSONKey.PRODUCT               : this.product,
    ReceptionJSONKey.SALES_MARKET_HANDLING : this.salesMarketingHandling,
    ReceptionJSONKey.SHORT_GREETING        : this.shortGreeting,
    ReceptionJSONKey.VAT_NUMBERS           : this.vatNumbers,
    ReceptionJSONKey.PHONE_NUMBERS         : this.telephonenumbers,
    ReceptionJSONKey.WEBSITES              : this.websites};

    return {
      ReceptionJSONKey.ID              : this.ID,
      ReceptionJSONKey.ORGANIZATION_ID : this.organizationId,
      ReceptionJSONKey.FULL_NAME       : this.fullName,
      ReceptionJSONKey.ENABLED         : this.enabled,
      ReceptionJSONKey.EXTRADATA_URI   : this.extraData == null ? null : this.extraData.toString(),
      ReceptionJSONKey.EXTENSION       : this.extension,
      ReceptionJSONKey.LAST_CHECK      : this.lastChecked.millisecondsSinceEpoch,
      ReceptionJSONKey.ATTRIBUTES      : attributes
    };
  }


  void validate() {
    if (this.greeting == null || this.greeting.isEmpty)
      throw new StateError('Greeting not allowed to be empty. '
        'Value: "${this.greeting}" Id: "${this.ID}" ReceptionName: "${this.fullName}"');
  }

  @override
  operator == (Reception other) => this.ID == other.ID;


  /**
   * [Reception] null constructor.
   */
  Reception.none() : super._null();

}
