part of openreception.model;

/**
 * TODO: Figure out whether to use phone or endpoints.
 */

abstract class ContactJSONKey {
  static const receptionID   = 'reception_id';
  static const contactID     = 'contact_id';
  static const departments    = 'departments';
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
  static const infos = 'infos';
  static const titles = 'titles';
  static const relations = 'relations';
  static const responsibilities = 'responsibilities';

  static const Contact_LIST = 'contacts';
  static const messagePrerequisites = 'messagePrerequisites';
}

abstract class ContactDefault {
  static get phones => new List<String>();
}

class Contact {

  static const int     noID        = 0;
  static final Contact noContact = new Contact.empty();
  static const String  className   = '${libraryName}.Contact';
  static final Logger  log         = new Logger(Contact.className);

  final StreamController<Event.Event> _streamController = new StreamController.broadcast();

  Stream get event => this._streamController.stream;

  static Contact _selectedContact = Contact.noContact;

  static Bus<Contact> _contactChange = new Bus<Contact>();
  static Stream<Contact> get onContactChange => _contactChange.stream;

  static Contact get selectedContact => _selectedContact;
  static set selectedContact(Contact contact) {
    _selectedContact = contact;
    _contactChange.fire(_selectedContact);
  }

  int ID            = noID;
  int receptionID   = Reception.noID;

  bool wantsMessage = true;
  bool enabled      = true;

  String fullName = '';
  String contactType = '';

  List<PhoneNumber> phones = [];
  List<String> backupContacts = [];
  List<String> messagePrerequisites = [];

  List<MessageEndpoint> endpoints = [];
  List<String> tags = new List<String>();
  List<String> emailaddresses = new List<String>();
  List<String> handling = new List<String>();
  List<String> workhours = new List<String>();
  List<String> titles = [];
  List<String> responsibilities = [];
  List<String> relations = [];
  List<String> departments = [];
  List<String> infos = [];


  MessageRecipientList _distributionList    = new MessageRecipientList.empty();
  MessageRecipientList get distributionList => this._distributionList;
  void set distributionList (MessageRecipientList newList) {
    this._distributionList = newList;
  }

  Map toJson() => this.asMap;

  Map get asMap =>
      {
        ContactJSONKey.contactID        : this.ID,
        ContactJSONKey.receptionID      : this.receptionID,
        ContactJSONKey.departments      : this.departments,
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
        ContactJSONKey.infos            : this.infos,
        ContactJSONKey.titles           : this.titles,
        ContactJSONKey.relations        : this.relations,
        ContactJSONKey.responsibilities : this.responsibilities,
        ContactJSONKey.messagePrerequisites : messagePrerequisites
      };

  Contact.fromMap(Map map) {
    /// PhoneNumber deserializing.
    Iterable<Map> phoneMaps = map[ContactJSONKey.phones];
    Iterable<PhoneNumber> phones = phoneMaps.map((Map phoneMap) {
      return new PhoneNumber.fromMap(phoneMap);});

    this.phones.addAll(phones.toList());

    this.ID                = mapValue(ContactJSONKey.contactID, map);
    this.receptionID       = mapValue(ContactJSONKey.receptionID, map);
    this.departments       = mapValue(ContactJSONKey.departments, map);
    this.wantsMessage      = mapValue(ContactJSONKey.wantsMessages, map);
    this.enabled           = mapValue(ContactJSONKey.enabled, map);
    this.fullName          = mapValue(ContactJSONKey.fullName, map);
    this._distributionList = new MessageRecipientList.fromMap(mapValue(ContactJSONKey.distributionList, map));
    this.contactType       = mapValue(ContactJSONKey.contactType, map);

    this.messagePrerequisites =
      mapValue(ContactJSONKey.messagePrerequisites, map, defaultValue : []);

    this.backupContacts    = mapValue(ContactJSONKey.backup, map);
    this.emailaddresses    = mapValue(ContactJSONKey.emailaddresses, map);
    this.handling          = mapValue(ContactJSONKey.handling, map);
    this.workhours         = mapValue(ContactJSONKey.workhours, map);
    this.handling          = mapValue(ContactJSONKey.handling, map);
    this.tags              = mapValue(ContactJSONKey.tags, map);
    this.infos             = mapValue(ContactJSONKey.infos, map);
    this.titles            = mapValue(ContactJSONKey.titles, map);
    this.relations         = mapValue(ContactJSONKey.relations, map);
    this.responsibilities  = mapValue(ContactJSONKey.responsibilities, map);

    Iterable ep = mapValue(ContactJSONKey.endpoints, map);
    this.endpoints = ep.map((Map map) =>
      new MessageEndpoint.fromMap(map)).toList();
  }

  static dynamic mapValue (String key, Map map, {dynamic defaultValue : null}) {
    if (!map.containsKey(key) && defaultValue == null) {
      throw new StateError('No value for required key "$key"');
    }

    return map.containsKey(key) ? map[key] : defaultValue;
  }

  /**
   * [Contact] as String, for debug/log purposes.
   */
  String toString() => '${this.fullName}-${this.ID}-${this.contactType}';

  /**
   * [Contact] null constructor.
   */
  Contact.empty();

  bool get isEmpty    => this.ID == noContact.ID;
  bool get isNotEmpty => this.ID != noContact.ID;
}
