/*                  This file is part of OpenReception
                   Copyright (C) 2015-, BitStackers K/S

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

/**
 * Does not check for null values.
 */
List<FormatException> validateOriginationContext(OriginationContext context) {
  List<FormatException> errors = [];

  if (context.contactId > Contact.noID) {
    errors.add(new FormatException('context.contactId <= Contact.noID'));
  }

  if (context.receptionId > Reception.noID) {
    errors.add(new FormatException('context.receptionId <= Reception.noID'));
  }

  if (context.dialplan.isEmpty) {
    errors.add(new FormatException('context.dialplan should be non-empty'));
  }

  return errors;
}

class OriginationContext {
  int contactId = Contact.noID;
  int receptionId = Reception.noID;
  String dialplan = '';
  String callId = '';
}
