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

part of openreception.framework.model;

class Reception {
  static const int noId = 0;

  int id = Reception.noId;
  String name = '';

  int oid = Organization.noId;

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
  List<PhoneNumber> phoneNumbers = [];
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
        Key.phoneNumbers: new List<Map>.from(
            phoneNumbers.map((PhoneNumber number) => number.toJson())),
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
        pns = values
            .map((String number) =>
                new PhoneNumber.empty()..destination = number)
            .toList();
      }

      phoneNumbers.addAll(pns);
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
  Reception.empty();

  static Reception decode(Map map) => new Reception.fromMap(map);

  Reception.fromMap(Map receptionMap) {
    try {
      this
        ..id = receptionMap[Key.id]
        ..oid = receptionMap[Key.oid]
        ..name = receptionMap[Key.name]
        ..enabled = receptionMap[Key.enabled]
        ..dialplan = receptionMap[Key.dialplan];

      if (receptionMap[Key.attributes] != null) {
        attributes = receptionMap[Key.attributes];
      }
    } catch (error) {
      throw new ArgumentError('Invalid data in map');
    }
  }

  /**
   * Returns a Map representation of the Reception.
   */
  Map toJson() => {
        Key.id: id,
        Key.enabled: enabled,
        Key.oid: oid,
        Key.dialplan: dialplan,
        Key.name: name,
        Key.attributes: attributes
      };

  @override
  bool operator ==(Reception other) => this.id == other.id;

  bool get isNotEmpty => !this.isEmpty;
  bool get isEmpty => this.id == noReception.id;

  ReceptionReference get reference => new ReceptionReference(id, name);
}
