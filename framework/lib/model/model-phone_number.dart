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

class PhoneNumber {
  String description = '';
  String value = '';
  String type = '';
  bool confidential = false;
  String billing_type = '';
  List<String> tags = [];

  PhoneNumber.fromMap(Map map) {
    description = map[Key.description];
    value = map[Key.value];
    confidential = map[Key.confidential];
    type = map[Key.type];
    billing_type = map[Key.billingType];

    var newTags = map[Key.tags];

    if (newTags is Iterable<String>) {
      tags.addAll(newTags);
    }
    else if (newTags is String) {
      tags.add(newTags);
    }

  }

  @override
  operator == (PhoneNumber other) =>
    this.value == other.value &&
    this.type== other.type
    ;

  PhoneNumber.empty();

  Map toJson () => this.asMap;

  Map get asMap => {
    Key.value: value,
    Key.type: type,
    Key.description: description,
    Key.billingType: billing_type,
    Key.tags: tags,
    Key.confidential: confidential
  };
}
