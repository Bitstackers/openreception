/*                  This file is part of OpenReception
                   Copyright (C) 2016-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

/// Shared errors and exceptions.
library openreception.framework.config;

class ValidationException implements Exception {
  final String message;
  const ValidationException([this.message = '']);

  @override
  String toString() => 'ParseException: $message';
}

class InvalidId implements ValidationException {
  @override
  final String message;

  final String field;
  const InvalidId(this.field, [this.message = '']);

  @override
  String toString() => 'IdIsNoId: $field - $message';
}

class InvalidCharacters implements ValidationException {
  @override
  final String message;

  final String field;
  const InvalidCharacters(this.field, [this.message = '']);

  @override
  String toString() => 'InvalidCharacters: $field - $message';
}

class NullValue implements ValidationException {
  @override
  final String message;

  final String field;
  const NullValue(this.field, [this.message = '']);

  @override
  String toString() => 'NullValue: $field - $message';
}

class IsEmpty implements ValidationException {
  @override
  final String message;

  final String field;
  const IsEmpty(this.field, [this.message = '']);

  @override
  String toString() => 'IsEmpty: $field - $message';
}

class BadType implements ValidationException {
  @override
  final String message;

  final String field;
  const BadType(this.field, this.message);

  @override
  String toString() => 'BadType: $field - $message';
}

class TimeOrderConstraint implements ValidationException {
  @override
  final String message;

  final String time;
  final String isBefore;
  const TimeOrderConstraint(this.time, this.isBefore, [this.message = '']);

  @override
  String toString() =>
      'TimeOrderConstraint: $time is before $isBefore - $message';
}

class DuplicateDigits implements ValidationException {
  @override
  final String message;

  final String value;
  final String duplicated;
  const DuplicateDigits(this.value, this.duplicated, [this.message = '']);

  @override
  String toString() => 'DuplicateDigits: $value - $message';
}
