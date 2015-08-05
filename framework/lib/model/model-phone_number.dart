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

abstract class PhoneNumberJSONKey {
  static const String Description = 'description';
  static const String Value = 'value';
  static const String Confidential = 'confidential';
  static const String Type = 'kind';
  static const String Billing_type = 'billing_type';
  static const String Tag = 'tag';

}

class PhoneNumber {
  String description = '';
  String value = '';
  String type = '';
  bool confidential = false;
  String billing_type = '';
  List<String> tags = [];

  PhoneNumber.fromMap(Map map) {
    description = map[PhoneNumberJSONKey.Description];
    value = map[PhoneNumberJSONKey.Value];
    confidential = map[PhoneNumberJSONKey.Confidential];
    type = map[PhoneNumberJSONKey.Type];
    billing_type = map[PhoneNumberJSONKey.Billing_type];

    var newTags = map[PhoneNumberJSONKey.Tag];

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
    PhoneNumberJSONKey.Value: value,
    PhoneNumberJSONKey.Type: type,
    PhoneNumberJSONKey.Description: description,
    PhoneNumberJSONKey.Billing_type: billing_type,
    PhoneNumberJSONKey.Tag: tags,
    PhoneNumberJSONKey.Confidential: confidential
  };
}
