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

/**
 * Conversion functions for transforming database rows into model classes.
 */
part of openreception.database;



/**
 * Convert a database row into a [Reception].
 */
Model.Reception _rowToReception(var row) => new Model.Reception.empty()
  ..ID = row.id
  ..fullName = row.full_name
  ..organizationId = row.organization_id
  ..enabled = row.enabled
  ..extraData = row.extradatauri != null ? Uri.parse(row.extradatauri) : null
  ..extension = row.reception_telephonenumber
  ..lastChecked = row.last_check
  ..attributes = row.attributes;

/**
 * Convert a database row into a [BaseContact].
 */
Model.BaseContact _rowToBaseContact(var row) => new Model.BaseContact.empty()
  ..id = row.id
  ..fullName = row.full_name
  ..contactType = row.contact_type
  ..enabled = row.enabled;

/**
 * Convert a database row into an [Organization].
 */
Model.Organization _rowToOrganization(var row) => new Model.Organization.empty()
  ..billingType = row.billing_type
  ..flag = row.flag
  ..id = row.id
  ..fullName = row.full_name;

/**
 * Convert a database row into an [User].
 */
Model.User _rowToUser(var row) => new Model.User.empty()
  ..ID = row.id
  ..name = row.name
  ..address = row.send_from
  ..peer = row.extension
  ..groups = row.groups != null ? row.groups : []
  ..identities = row.identities != null ? row.identities : [];


/**
 * Convert a database row into an [Message].
 */
Model.Message _rowToMessage(var row) {
  return new Model.Message.empty()
    ..ID = row.id
    ..body = row.message
    ..recipients.addAll(
        (row.recipients as Iterable).map(Model.MessageRecipient.decode))
    ..context = (new Model.MessageContext.empty()
      ..contactID = row.context_contact_id
      ..contactName = row.context_contact_name
      ..receptionID = row.context_reception_id
      ..receptionName = row.context_reception_name)
    ..senderId = row.taken_by_agent_id
    ..callerInfo = (new Model.CallerInfo.empty()
      ..name = row.taken_from_name
      ..company = row.taken_from_company
      ..phone = row.taken_from_phone
      ..cellPhone = row.taken_from_cellphone
      ..localExtension = row.taken_from_localexten)
    ..flag = (new Model.MessageFlag(row.flags))
    ..enqueued = row.enqueued
    ..createdAt = row.created_at
    ..sent = row.sent;
}