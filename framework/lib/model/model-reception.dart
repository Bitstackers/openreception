/*                  This file is part of OpenReception
                   Copyright (C) 2014-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of openreception.model;

class ReceptionStub {
  int ID = Reception.noID;
  String fullName = null;

  String get name => this.fullName;

  /**
   * [Reception] as String, for debug/log purposes.
   */
  String toString() => '${name}-${ID}';

  ReceptionStub.fromMap(Map map) {
    if (map == null) throw new ArgumentError.notNull('Null map');

    this.ID = map[Key.ID];

    this.fullName = map[Key.fullName];
  }

  ReceptionStub.empty();
}

class Reception extends ReceptionStub {
  static const String className = '$libraryName.Reception';
  static final Logger log = new Logger(Reception.className);
  static const int noID = 0;

  int organizationId = noID;
  Uri extraData = null;
  DateTime lastChecked =
      new DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  List<String> addresses = [];
  List<String> alternateNames = [];
  List<String> bankingInformation = [];
  List<String> salesMarketingHandling = [];
  List<String> emailAddresses = [];
  List<String> handlingInstructions = [];
  List<String> openingHours = [];
  List<String> vatNumbers = [];
  List<String> websites = [];
  List<String> customerTypes = [];
  List<PhoneNumber> telephoneNumbers = [];
  String miniWiki = '';

  String get shortGreeting =>
      this._shortGreeting.isNotEmpty ? this._shortGreeting : this.greeting;
  void set shortGreeting(String newGreeting) {
    this._shortGreeting = newGreeting;
  }

  String dialplan;
  String greeting;
  String otherData;
  String _shortGreeting = '';
  String product;
  bool enabled = false;

  Map get attributes => {
        Key.addresses: addresses,
        Key.alternateNames: alternateNames,
        Key.bankingInfo: bankingInformation,
        Key.customerTypes: customerTypes,
        Key.emailAdresses: emailAddresses,
        Key.greeting: greeting,
        Key.handlingInstructions: handlingInstructions,
        Key.openingHours: openingHours,
        Key.other: otherData,
        Key.product: product,
        Key.salesMarketingHandling: salesMarketingHandling,
        Key.shortGreeting: _shortGreeting,
        Key.vatNumbers: vatNumbers,
        Key.phoneNumbers:
            telephoneNumbers.map((PhoneNumber number) => number.asMap).toList(),
        Key.websites: websites,
        Key.miniWiki: miniWiki
      };

  void set attributes(Map attributes) {
    this.customerTypes = attributes[Key.customerTypes] as List<String>;

    //Temporary workaround for telephonenumbers to telephoneNumbers transition.
    if (attributes.containsKey(Key.phoneNumbers)) {
      Iterable values = attributes[Key.phoneNumbers];
      List<PhoneNumber> pns = [];

      try {
        pns = values.map((Map map) => new PhoneNumber.fromMap(map)).toList();
      } catch (_) {
        log.warning('Failed to extract phoneNumber map, trying String');
        pns = values
            .map((String number) => new PhoneNumber.empty()..endpoint = number)
            .toList();
      }

      this.telephoneNumbers.addAll(pns);
    }

    this
      ..addresses = attributes[Key.addresses] as List<String>
      ..alternateNames = attributes[Key.alternateNames] as List<String>
      ..bankingInformation = attributes[Key.bankingInfo] as List<String>
      ..emailAddresses = attributes[Key.emailAdresses] as List<String>
      ..greeting = attributes[Key.greeting] as String
      ..handlingInstructions =
          attributes[Key.handlingInstructions] as List<String>
      ..openingHours = attributes[Key.openingHours] as List<String>
      ..otherData = attributes[Key.other] as String
      ..product = attributes[Key.product] as String
      ..salesMarketingHandling =
          attributes[Key.salesMarketingHandling] as List<String>
      .._shortGreeting = attributes[Key.shortGreeting] != null
          ? attributes[Key.shortGreeting]
          : ''
      ..vatNumbers = attributes[Key.vatNumbers] as List<String>
      ..websites = attributes[Key.websites] as List<String>
      ..miniWiki = attributes[Key.miniWiki];
  }

  static final Reception noReception = new Reception.empty();

  static Reception _selectedReception = noReception;

  static Bus<Reception> _receptionChange = new Bus<Reception>();
  static Stream<Reception> get onReceptionChange => _receptionChange.stream;

  static Reception get selectedReception => _selectedReception;
  static set selectedReception(Reception reception) {
    _selectedReception = reception;
    _receptionChange.fire(_selectedReception);
  }

  /// Default initializing contructor
  Reception.empty() : super.empty();

  Reception.fromMap(Map receptionMap) : super.fromMap(receptionMap) {
    try {
      this
        ..ID = receptionMap[Key.ID]
        ..organizationId = receptionMap[Key.organizationId]
        ..fullName = receptionMap[Key.fullName]
        ..enabled = receptionMap[Key.enabled]
        ..dialplan = receptionMap[Key.dialplan]
        ..extraData = receptionMap[Key.extradataUri] != null
            ? Uri.parse(receptionMap[Key.extradataUri])
            : null
        ..lastChecked =
            Util.unixTimestampToDateTime(receptionMap[Key.lastCheck]);

      if (receptionMap[Key.attributes] != null) {
        attributes = receptionMap[Key.attributes];
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
  Map get asMap => {
        Key.ID: this.ID,
        Key.organizationId: this.organizationId,
        Key.dialplan: this.dialplan,
        Key.fullName: this.fullName,
        Key.enabled: this.enabled,
        Key.extradataUri:
            this.extraData == null ? null : this.extraData.toString(),
        Key.lastCheck: Util.dateTimeToUnixTimestamp(lastChecked),
        Key.attributes: attributes
      };

  void validate() {
    if (this.greeting == null || this.greeting.isEmpty) throw new StateError(
        'Greeting not allowed to be empty. '
        'Value: "${this.greeting}" Id: "${this.ID}" ReceptionName: "${this.fullName}"');
  }

  @override
  bool operator ==(Reception other) => this.ID == other.ID;

  bool get isNotEmpty => !this.isEmpty;
  bool get isEmpty => this.ID == noReception.ID;
}
