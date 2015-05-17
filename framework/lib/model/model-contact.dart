part of openreception.model;

/**
 * TODO: Figure out whether to use phone or endpoints.
 */

abstract class ContactJSONKey {
  static const receptionID   = 'reception_id';
  static const contactID     = 'contact_id';
  static const department    = 'department';
  static const wantsMessages = 'wants_messages';
  static const enabled       = 'enabled';
  static const fullName      = 'full_name';

  static const distributionList = 'distribution_list';
  static const contactType = 'contact_type';
  static const phones = 'phones';
  static const endpoints = 'endpoints';
  static const backup = 'backup';
  static const emailaddresses = 'emailaddresses';
  static const handling = 'handling';
  static const workhours = 'workhours';
  static const tags = 'tags';
  static const info = 'info';
  @deprecated
  static const position = 'position';
  static const titles = 'titles';
  static const relations = 'relations';
  static const responsibility = 'responsibility';

  static const Contact_LIST = 'contacts';
}

abstract class ContactDefault {
  static get phones => new List<String>();
}

class Contact {

  static const int     noID        = 0;
  static final Contact nullContact = new Contact.none();
  static const String  className   = '${libraryName}.Contact';
  static final Logger  log         = new Logger(Contact.className);

  final StreamController<Event.Event> _streamController = new StreamController.broadcast();

  Stream get event => this._streamController.stream;

  int ID            = noID;
  int receptionID   = Reception.noID;

  String department = '';
  bool wantsMessage = true;
  bool enabled      = true;


  String  info = '';
  String  fullName = '';
  String  contactType = '';

  List<PhoneNumber> phones = [];
  List<String> backupContacts = [];

  @deprecated
  String position = '';
  String relations = '';
  String responsibility = '';

  List<MessageEndpoint>    endpoints = [];
  List<String> tags = new List<String>();
  List<String> emailaddresses = new List<String>();
  List<String> handling = new List<String>();
  List<String> workhours = new List<String>();
  List<String> titles = [];

  MessageRecipientList _distributionList    = new MessageRecipientList.empty();
  MessageRecipientList get distributionList => this._distributionList;
  void set distributionList (MessageRecipientList newList) {
    this._distributionList = newList;
  }

  static final Contact noContact = nullContact;

  Map toJson() => this.asMap;

  Map get asMap =>
      {
        ContactJSONKey.contactID        : this.ID,
        ContactJSONKey.receptionID      : this.receptionID,
        ContactJSONKey.department       : this.department,
        ContactJSONKey.wantsMessages    : this.wantsMessage,
        ContactJSONKey.enabled          : this.enabled,
        ContactJSONKey.fullName         : this.fullName,
        ContactJSONKey.distributionList : this.distributionList.asMap,
        ContactJSONKey.contactType      : this.contactType,
        ContactJSONKey.phones           : this.phones.map((PhoneNumber p) => p.asMap).toList(growable: false),
        ContactJSONKey.endpoints        : this.endpoints.map((MessageEndpoint ep) => ep.asMap).toList(growable: false),
        ContactJSONKey.backup           : this.backupContacts,
        ContactJSONKey.emailaddresses   : this.emailaddresses,
        ContactJSONKey.handling         : this.handling,
        ContactJSONKey.workhours        : this.workhours,
        ContactJSONKey.tags             : this.tags,
        ContactJSONKey.info             : this.info,
        ContactJSONKey.titles           : this.titles,
        ContactJSONKey.relations        : this.relations,
        ContactJSONKey.responsibility   : this.responsibility
      };

  Contact.fromMap(Map map) {
    /// PhoneNumber deserializing.
    Iterable<Map> phoneMaps = map[ContactJSONKey.phones];
    Iterable<PhoneNumber> phones = phoneMaps.map((Map phoneMap) {
      return new PhoneNumber.fromMap(phoneMap);});

    this.phones.addAll(phones.toList());

    this.ID                = mapValue(ContactJSONKey.contactID, map);
    this.receptionID       = mapValue(ContactJSONKey.receptionID, map);
    this.department        = mapValue(ContactJSONKey.department, map);
    this.wantsMessage      = mapValue(ContactJSONKey.wantsMessages, map);
    this.enabled           = mapValue(ContactJSONKey.enabled, map);
    this.fullName          = mapValue(ContactJSONKey.fullName, map);
    this._distributionList = new MessageRecipientList.fromMap(mapValue(ContactJSONKey.distributionList, map));
    this.contactType       = mapValue(ContactJSONKey.contactType, map);



    this.backupContacts    = mapValue(ContactJSONKey.backup, map);
    this.emailaddresses    = mapValue(ContactJSONKey.emailaddresses, map);
    this.handling          = mapValue(ContactJSONKey.handling, map);
    this.workhours         = mapValue(ContactJSONKey.workhours, map);
    this.handling          = mapValue(ContactJSONKey.handling, map);
    this.tags              = mapValue(ContactJSONKey.tags, map);
    this.info              = mapValue(ContactJSONKey.info, map);
    this.titles            = mapValue(ContactJSONKey.titles, map);
    this.relations         = mapValue(ContactJSONKey.relations, map);
    this.responsibility    = mapValue(ContactJSONKey.responsibility, map);

    Iterable ep = mapValue(ContactJSONKey.endpoints, map);
    this.endpoints = ep.map((Map map) =>
      new MessageEndpoint.fromMap(map)).toList();
  }

  static dynamic mapValue (String key, Map map, {dynamic defaultValue : null}) {
    if (!map.containsKey(key) && defaultValue == null) {
      throw new StateError('No value for required key "$key"');
    }

    return map[key];
  }

  /**
   * [Contact] null constructor.
   */
  Contact.none() {
    ID          = noID;
    contactType = null;
  }
}
