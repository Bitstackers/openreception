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

library openreception.framework.validation;

import 'package:openreception.framework/model.dart';
import 'package:openreception.framework/util.dart';

/**
 * Validate a [Message] object before and after both serializing and
 * deserializing.
 * Put any constraints that must hold at these times in this function.
 */
List<FormatException> validateMessage(Message msg) {
  List<FormatException> errors = [];

  if (msg.id == null) {
    errors.add(new FormatException('Id is null'));
  }

  if (msg.recipients.isEmpty) {
    errors.add(new FormatException('msg.recipients is Empty'));
  }

  if (msg.state == MessageState.unknown) {
    errors.add(new FormatException('MessageState is unknown'));
  }

  if (msg.body.isEmpty) {
    errors.add(new FormatException('Message body is empty'));
  }

  if (msg.createdAt.isAtSameMomentAs(never)) {
    errors.add(new FormatException('Message date is set to "never"'));
  }

  errors.addAll(validateMessageContext(msg.context));
  errors.addAll(validateMessageRecipients(msg.recipients));

  errors.addAll(validateMessageCallerInfo(msg.callerInfo));
  errors.addAll(validateUser(msg.sender));

  return errors;
}

/**
 *
 */
List<FormatException> validateMessageCallerInfo(CallerInfo callerInfo) {
  List<FormatException> errors = [];

  if (callerInfo.name.isEmpty) {
    errors.add(new FormatException('Empty caller name'));
  }

  return errors;
}

/**
 *
 */
List<FormatException> validateMessageRecipients(
    Iterable<MessageEndpoint> recipients) {
  List<FormatException> errors = [];

  for (MessageEndpoint recipient in recipients) {
    if (!MessageEndpointType.types.contains(recipient.type)) {
      errors
          .add(new FormatException('Invalid endpoint type ${recipient.type}'));
    }

    if (recipient.name.isEmpty) {
      errors.add(new FormatException('Empty recipient name'));
    }

    if (recipient.address.isEmpty) {
      errors.add(new FormatException('Empty recipient address'));
    }
  }

  return errors;
}

/**
 *
 */
List<FormatException> validateMessageContext(MessageContext context) {
  List<FormatException> errors = [];

  if (context.cid <= BaseContact.noId) {
    errors.add(new FormatException('Cid must be positive'));
  }

  if (context.rid <= Reception.noId) {
    errors.add(new FormatException('Rid must be positive'));
  }

  if (context.contactName.isEmpty) {
    errors.add(new FormatException('Contact name is empty'));
  }

  if (context.receptionName.isEmpty) {
    errors.add(new FormatException('Reception name is empty'));
  }

  return errors;
}

/**
 * Validate an owner before and after both serializing and deserializing.
 * Put any constraints that must hold at these times in this function.
 */
List<FormatException> validateOwner(Owner owner) {
  List<FormatException> errors = [];

  if (owner.id == null) {
    errors.add(new FormatException('Id is null'));
  }

  if (owner.id == 0) {
    errors.add(new FormatException('Owner id must be set'));
  }

  return errors;
}

/**
 *
 */
List<FormatException> validatePhonenumber(PhoneNumber pn) {
  List<FormatException> errors = [];

  if (pn.normalizedDestination.isEmpty) {
    errors.add(new FormatException('Destination must not be empty'));
  }

  return errors;
}

/**
 *
 */
List<FormatException> validateReceptionAttribute(ReceptionAttributes attr) {
  List<FormatException> errors = [];

  if (attr.cid <= BaseContact.noId) {
    errors.add(new FormatException('Cid must be a positive number'));
  }

  if (attr.receptionId < Reception.noId) {
    errors.add(new FormatException('Rid must not be a negative number'));
  }

  return errors;
}

/**
 *
 */
List<FormatException> validateReception(Reception rec) {
  List<FormatException> errors = [];

  if (rec.name.isEmpty) {
    errors.add(new FormatException('Name should not be empty'));
  }

  if (rec.oid <= Organization.noId) {
    errors.add(new FormatException('Oid must be a positive number'));
  }

  if (rec.id < Reception.noId) {
    errors.add(new FormatException('Id must not be a negative number'));
  }

  if (rec.greeting.isEmpty) {
    errors.add(new FormatException('Greeting should not be empty'));
  }

  return errors;
}

/**
 * Validate a [User] object before and after both  serializing and
 * deserializing.
 * Put any constraints that must hold at these times in this function.
 */
List<FormatException> validateOrganization(Organization org) {
  List<FormatException> errors = [];

  if (org.id == null) {
    errors.add(new FormatException('uuid is null'));
  }

  if (org.name == null) {
    errors.add(new FormatException('name is null'));
  }

  if (org.name.isEmpty) {
    errors.add(new FormatException('name is empty'));
  }

  if (org.notes == null) {
    errors.add(new FormatException('flags is null'));
  }

  return errors;
}

/**
 *
 */
List<FormatException> validateUser(User user) {
  List<FormatException> errors = [];

  if (user.name.isEmpty) {
    errors.add(new FormatException('User name should not be empty'));
  }

  if (user.address.isEmpty) {
    errors.add(new FormatException('User address should not be empty'));
  }

  if (user.id < User.noId) {
    errors.add(new FormatException('User id must not be a negative number'));
  }

  user.groups.forEach((String group) {
    if (UserGroups.isValid(group)) {
      errors.add(new FormatException('Invalid group: $group'));
    }
  });

  user.identities.forEach((String identity) {
    if (identity.isEmpty) {
      errors.add(new FormatException('Empty identity detected'));
    }
  });

  return errors;
}

/**
 * Validate a [CalendarEntry] object before and after both serializing and
 * deserializing.
 * Put any constraints that must hold at these times in this function.
 */
List<FormatException> validateCalendarEntry(CalendarEntry entry) {
  List<FormatException> errors = [];

  if (entry.id == null) {
    errors.add(new FormatException('Id is null'));
  }

  if (entry.id < CalendarEntry.noId) {
    errors.add(new FormatException('Id must not be negative'));
  }

  if (entry.content.isEmpty) {
    errors.add(new FormatException('No content'));
  }

  if (entry.start.isAfter(entry.stop)) {
    errors.add(new FormatException('Start time is after stop time'));
  }

  return errors;
}

/**
 * Validate a [BaseContact] object before and after both serializing and
 * deserializing.
 * Put any constraints that must hold at these times in this function.
 */
List<FormatException> validateBaseContact(BaseContact bc) {
  List<FormatException> errors = [];

  if (bc.id == null) {
    errors.add(new FormatException('Id is null'));
  }

  if (bc.id < BaseContact.noId) {
    errors.add(new FormatException('Id must not be negative'));
  }

  if (bc.name.isEmpty) {
    errors.add(new FormatException('Name must not be empty'));
  }

  if (!ContactType.types.contains(bc.type)) {
    errors.add(new FormatException('Invalid contact type ${bc.type}'));
  }

  return errors;
}

/**
 *
 */
List<FormatException> validateReceptionDialplan(ReceptionDialplan rdp) {
  List<FormatException> errors = [];

  if (rdp.extension.isEmpty) {
    errors.add(new FormatException('Name should not be empty'));
  }

  return errors;
}
