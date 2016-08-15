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

/// Validation tools for data model object.
///
/// The functions provided by this library is suitable for both client- and
/// serverside validation of objects. The error lists returned by the
/// validation functions may serve as may serve as both pre-storage checks,
/// but also as "fix these" error lists in a client UI.
library openreception.framework.validation;

import 'package:openreception.framework/model.dart';
import 'package:openreception.framework/util.dart';
import 'package:openreception.framework/exceptions.dart';

/// Determines if [string] contains only alphanumeric characters with no
/// spaces.
bool isAlphaNumeric(String string) =>
    new RegExp(r"^[a-zA-Z0-9]*$").hasMatch(string);

/// Performs object validation of an [OriginationContext] object.
///
/// Returns a list of errors found in the validation and does not throw
/// any exceptions.
List<ValidationException> validateOriginationContext(
    OriginationContext context) {
  List<ValidationException> errors = [];

  if (context.contactId == BaseContact.noId) {
    errors.add(new InvalidId('cid'));
  }

  if (context.receptionId == Reception.noId) {
    errors.add(new InvalidId('rid'));
  }

  if (context.dialplan.isEmpty) {
    errors.add(new IsEmpty('dialplan'));
  }

  return errors;
}

/// Performs object validation of an [IvrMenu] object.
///
/// Returns a list of errors found in the validation and does not throw
/// any exceptions.
List<ValidationException> validateIvrMenu(IvrMenu menu) {
  List<ValidationException> errors = [];

  if (menu.name.isEmpty) {
    errors.add(new IsEmpty('name'));
  }

  if (!isAlphaNumeric(menu.name)) {
    errors.add(new InvalidCharacters(
        'name', 'Menu name must contain only alphanumeric characters.'));
  }

  if (menu.entries == null) {
    errors.add(new NullValue('entries', 'Menu entries may not be null'));
  }

  if (menu.greetingLong.filename.isEmpty) {
    errors.add(new IsEmpty('greeting'));
  }

  menu.entries.forEach((entry) {
    Iterable<IvrEntry> duplicated = menu.entries.where((e) =>
        e.digits.runes.any((r) => entry.digits.runes.contains(r)) ||
        entry.digits.runes.any((r) => e.digits.runes.contains(r)));

    if (duplicated.length > 1) {
      errors.add(new DuplicateDigits('digits', duplicated.first.digits,
          'Duplicate digit ${entry.digits}'));
    }
  });

  errors.addAll(menu.submenus.map(validateIvrMenu).fold(
      new List<ValidationException>(),
      (List<ValidationException> list, e) => list..addAll(e)));

  return errors;
}

/// Performs object validation of a [Message] object.
///
/// Returns a list of errors found in the validation and does not throw
/// any exceptions.
List<ValidationException> validateMessage(Message msg) {
  List<ValidationException> errors = [];

  if (msg.id == null) {
    errors.add(new NullValue('id'));
  }

  if (msg.recipients.isEmpty) {
    errors.add(new IsEmpty('recipients'));
  }

  if (msg.state == MessageState.unknown || msg.state == null) {
    errors.add(new BadType('state', msg.state.toString()));
  }

  if (msg.body.isEmpty) {
    errors.add(new IsEmpty('body'));
  }

  if (msg.createdAt.isAtSameMomentAs(never)) {
    errors.add(new TimeOrderConstraint('date', 'never'));
  }

  errors.addAll(validateMessageContext(msg.context));
  errors.addAll(validateMessageRecipients(msg.recipients));

  errors.addAll(validateMessageCallerInfo(msg.callerInfo));
  errors.addAll(validateUser(msg.sender));

  return errors;
}

/// Performs object validation of a [CallerInfo] object.
///
/// Returns a list of errors found in the validation and does not throw
/// any exceptions.
List<ValidationException> validateMessageCallerInfo(CallerInfo callerInfo) {
  List<ValidationException> errors = [];

  if (callerInfo.name.isEmpty) {
    errors.add(new IsEmpty('name'));
  }

  return errors;
}

/// Performs object validation of an [Iterable] of [MessageEndpoint]
/// objects.
///
/// Returns a list of errors found in the validation and does not throw
/// any exceptions.
List<ValidationException> validateMessageRecipients(
    Iterable<MessageEndpoint> recipients) {
  List<ValidationException> errors = [];

  for (MessageEndpoint recipient in recipients) {
    if (!MessageEndpointType.types.contains(recipient.type)) {
      errors.add(new BadType('type', recipient.type));
    }

    if (recipient.name.isEmpty) {
      errors.add(new IsEmpty('name'));
    }

    if (recipient.address.isEmpty) {
      errors.add(new IsEmpty('address'));
    }
  }

  return errors;
}

/// Performs object validation of a [MessageContext] object.
///
/// Returns a list of errors found in the validation and does not throw
/// any exceptions.
List<ValidationException> validateMessageContext(MessageContext context) {
  List<ValidationException> errors = [];

  if (context.cid <= BaseContact.noId) {
    errors.add(new InvalidId('cid'));
  }

  if (context.rid <= Reception.noId) {
    errors.add(new InvalidId('rid'));
  }

  if (context.contactName.isEmpty) {
    errors.add(new IsEmpty('contactName'));
  }

  if (context.receptionName.isEmpty) {
    errors.add(new IsEmpty('receptionName'));
  }

  return errors;
}

/// Performs object validation of an [Owner] object.
///
/// Returns a list of errors found in the validation and does not throw
/// any exceptions.
List<ValidationException> validateOwner(Owner owner) {
  final List<ValidationException> errors = [];

  if (owner.id == null) {
    errors.add(new NullValue('id'));
  }

  if (owner.id < BaseContact.noId) {
    errors.add(new InvalidId('id'));
  }

  return errors;
}

/// Performs object validation of a [PhoneNumber] object.
///
/// Returns a list of errors found in the validation and does not throw
/// any exceptions.
List<ValidationException> validatePhonenumber(PhoneNumber pn) {
  final List<ValidationException> errors = [];

  if (pn.normalizedDestination.isEmpty) {
    errors.add(new IsEmpty('destination'));
  }

  return errors;
}

/// Performs object validation of a [ReceptionAttributes] object.
///
/// Returns a list of errors found in the validation and does not throw
/// any exceptions.
List<ValidationException> validateReceptionAttribute(ReceptionAttributes attr) {
  final List<ValidationException> errors = [];

  if (attr.cid <= BaseContact.noId) {
    errors.add(new InvalidId('cid'));
  }

  if (attr.receptionId < Reception.noId) {
    errors.add(new InvalidId('rid'));
  }

  return errors;
}

/// Performs object validation of a [Reception] object.
///
/// Returns a list of errors found in the validation and does not throw
/// any exceptions.
List<ValidationException> validateReception(Reception rec) {
  List<ValidationException> errors = [];

  if (rec.name.isEmpty) {
    errors.add(new IsEmpty('name'));
  }

  if (rec.oid <= Organization.noId) {
    errors.add(new InvalidId('oid'));
  }

  if (rec.id < Reception.noId) {
    errors.add(new InvalidId('id'));
  }

  if (rec.greeting.isEmpty) {
    errors.add(new IsEmpty('greeting'));
  }

  return errors;
}

/// Performs object validation of a [Organization] object.
///
/// Returns a list of errors found in the validation and does not throw
/// any exceptions.
List<ValidationException> validateOrganization(Organization org) {
  List<ValidationException> errors = [];

  if (org.id == null) {
    errors.add(new NullValue('uuid'));
  }

  if (org.name == null) {
    errors.add(new NullValue('name'));
  }

  if (org.name.isEmpty) {
    errors.add(new IsEmpty('name'));
  }

  if (org.notes == null) {
    errors.add(new NullValue('flags'));
  }

  return errors;
}

/// Performs object validation of a [User] object.
///
/// Returns a list of errors found in the validation and does not throw
/// any exceptions.
List<ValidationException> validateUser(User user) {
  List<ValidationException> errors = [];

  if (user.name.isEmpty) {
    errors.add(new IsEmpty('name'));
  }

  if (user.address.isEmpty) {
    errors.add(new IsEmpty('address'));
  }

  if (user.id < User.noId) {
    errors.add(new InvalidId('id'));
  }

  user.groups.forEach((String group) {
    if (UserGroups.isValid(group)) {
      errors.add(new BadType('group', group));
    }
  });

  user.identities.forEach((String identity) {
    if (identity.isEmpty) {
      errors.add(new IsEmpty('identity'));
    }
  });

  return errors;
}

/// Performs object validation of a [CalendarEntry] object.
///
/// Returns a list of errors found in the validation and does not throw
/// any exceptions.
List<ValidationException> validateCalendarEntry(CalendarEntry entry) {
  List<ValidationException> errors = [];

  if (entry.id == null) {
    errors.add(new NullValue('id'));
  }

  if (entry.id < CalendarEntry.noId) {
    errors.add(new InvalidId('id'));
  }

  if (entry.content.isEmpty) {
    errors.add(new IsEmpty('content'));
  }

  if (entry.start.isAfter(entry.stop)) {
    errors.add(new TimeOrderConstraint('stop', 'start'));
  }

  return errors;
}

/// Performs object validation of a [BaseContact] object.
///
/// Returns a list of errors found in the validation and does not throw
/// any exceptions.
List<ValidationException> validateBaseContact(BaseContact bc) {
  List<ValidationException> errors = [];

  if (bc.id == null) {
    errors.add(new NullValue('id'));
  }

  if (bc.id < BaseContact.noId) {
    errors.add(new InvalidId('id'));
  }

  if (bc.name.isEmpty) {
    errors.add(new IsEmpty('name'));
  }

  if (!ContactType.types.contains(bc.type)) {
    errors.add(new BadType('type', bc.type));
  }

  return errors;
}

/// Performs object validation of a [ReceptionDialplan] object.
///
/// Returns a list of errors found in the validation and does not throw
/// any exceptions.
List<ValidationException> validateReceptionDialplan(ReceptionDialplan rdp) {
  List<ValidationException> errors = [];

  if (rdp.extension.isEmpty) {
    errors.add(new IsEmpty('name'));
  }

  return errors;
}
