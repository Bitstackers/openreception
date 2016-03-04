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

part of openreception.test;

void testModelPhoneNumber() {
  group('Model.PhoneNumber', () {
    test('buildObject', ModelPhoneNumber.buildObject);
  });
}

abstract class ModelPhoneNumber {
  static void buildObject() {
    final String description = 'Cell Phone - work';
    final String value = '+45 44 88 1231';

    final bool confidential = false;

    final List<String> tags = ['work', 'official'];

    Model.PhoneNumber phoneNumber = new Model.PhoneNumber.empty()
      ..confidential = confidential
      ..description = description
      ..destination = value;

    expect(phoneNumber.confidential, equals(confidential));
    expect(phoneNumber.description, equals(description));

    expect(phoneNumber.destination, equals(value));
  }
}
