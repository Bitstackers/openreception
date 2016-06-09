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
        key.addresses: addresses,
        key.alternateNames: alternateNames,
        key.bankingInfo: bankingInformation,
        key.customerTypes: customerTypes,
        key.emailAdresses: emailAddresses,
        key.greeting: greeting,
        key.handlingInstructions: handlingInstructions,
        key.openingHours: openingHours,
        key.other: otherData,
        key.product: product,
        key.salesMarketingHandling: salesMarketingHandling,
        key.shortGreeting: _shortGreeting,
        key.vatNumbers: vatNumbers,
        key.phoneNumbers: new List<Map>.from(
            phoneNumbers.map((PhoneNumber number) => number.toJson())),
        key.websites: websites,
        key.miniWiki: miniWiki
      };

  void set attributes(Map attributes) {
    this.customerTypes = attributes[key.customerTypes] as List<String>;

    //Temporary workaround for telephonenumbers to telephoneNumbers transition.
    if (attributes.containsKey(key.phoneNumbers)) {
      Iterable values = attributes[key.phoneNumbers];
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
      ..addresses = attributes[key.addresses] as List<String>
      ..alternateNames = attributes[key.alternateNames] as List<String>
      ..bankingInformation = attributes[key.bankingInfo] as List<String>
      ..emailAddresses = attributes[key.emailAdresses] as List<String>
      ..greeting = attributes[key.greeting] as String
      ..handlingInstructions =
          attributes[key.handlingInstructions] as List<String>
      ..openingHours = attributes[key.openingHours] as List<String>
      ..otherData = attributes[key.other] as String
      ..product = attributes[key.product] as String
      ..salesMarketingHandling =
          attributes[key.salesMarketingHandling] as List<String>
      .._shortGreeting = attributes[key.shortGreeting] != null
          ? attributes[key.shortGreeting]
          : ''
      ..vatNumbers = attributes[key.vatNumbers] as List<String>
      ..websites = attributes[key.websites] as List<String>
      ..miniWiki = attributes[key.miniWiki];
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
        ..id = receptionMap[key.id]
        ..oid = receptionMap[key.oid]
        ..name = receptionMap[key.name]
        ..enabled = receptionMap[key.enabled]
        ..dialplan = receptionMap[key.dialplan];

      if (receptionMap[key.attributes] != null) {
        attributes = receptionMap[key.attributes];
      }
    } catch (error) {
      throw new ArgumentError('Invalid data in map');
    }
  }

  /**
   * Returns a Map representation of the Reception.
   */
  Map toJson() => {
        key.id: id,
        key.enabled: enabled,
        key.oid: oid,
        key.dialplan: dialplan,
        key.name: name,
        key.attributes: attributes
      };

  @override
  bool operator ==(Object other) => other is Reception && this.id == other.id;

  bool get isNotEmpty => !this.isEmpty;
  bool get isEmpty => this.id == noReception.id;

  ReceptionReference get reference => new ReceptionReference(id, name);
}
