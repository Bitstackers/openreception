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
 * Convert a database row into a [DistributionListEntry].
 */
Model.MessageEndpoint _rowToMessageEndpoint(PG.Row row) =>
    new Model.MessageEndpoint.empty()
      ..id = row.id
      ..address = row.address
      ..type = row.address_type
      ..confidential = row.confidential
      ..enabled = row.enabled
      ..description = row.description;

/**
 * Convert a database row into a [DistributionListEntry].
 */
Model.DistributionListEntry _rowToDistributionListEntry(PG.Row row) =>
    new Model.DistributionListEntry()
      ..receptionID = row.recipient_reception_id
      ..receptionName = row.recipient_reception_name
      ..contactID = row.recipient_contact_id
      ..contactName = row.recipient_contact_name
      ..role = row.role
      ..id = row.id;

/**
 * Convert a database row into a [Reception].
 */
Model.Reception _rowToReception(PG.Row row) => new Model.Reception.empty()
  ..ID = row.id
  ..fullName = row.full_name
  ..dialplan = row.dialplan
  ..organizationId = row.organization_id
  ..enabled = row.enabled
  ..extraData = row.extradatauri.isNotEmpty ? Uri.parse(row.extradatauri) : null
  ..lastChecked = row.last_check
  ..attributes = row.attributes;

/**
 * Convert a database row into a [BaseContact].
 */
Model.BaseContact _rowToBaseContact(PG.Row row) => new Model.BaseContact.empty()
  ..id = row.id
  ..fullName = row.full_name
  ..contactType = row.contact_type
  ..enabled = row.enabled;

/**
 * Convert a database row into an [Organization].
 */
Model.Organization _rowToOrganization(PG.Row row) =>
    new Model.Organization.empty()
      ..billingType = row.billing_type
      ..flag = row.flag
      ..id = row.id
      ..fullName = row.full_name;

/**
 * Convert a database row into an [User].
 */
Model.User _rowToUser(PG.Row row) => new Model.User.empty()
  ..id = row.id
  ..name = row.name
  ..googleUsername = row.google_username
  ..googleAppcode = row.google_appcode
  ..enabled = row.enabled
  ..address = row.send_from
  ..peer = row.extension;

/**
   * Convert a database row into an [UserGroup].
   */
Model.UserGroup _rowToUserGroup(PG.Row row) => new Model.UserGroup.empty()
  ..id = row.id
  ..name = row.name;

/**
     * Convert a database row into an [UserIdentity].
     */
Model.UserIdentity _rowToUserIdentity(PG.Row row) =>
    new Model.UserIdentity.empty()
      ..identity = row.identity
      ..userId = row.user_id;

/**
 * Convert a database row into an [Message].
 */
Model.Message _rowToMessage(PG.Row row) {
  final Iterable<Map> rMaps = row.recipients as Iterable<Map>;
  final Iterable<Model.MessageRecipient> rs =
      rMaps.map((Map map) => new Model.MessageRecipient.fromMap(map))
      as Iterable<Model.MessageRecipient>;

  return new Model.Message.empty()
    ..ID = row.id
    ..body = row.message
    ..callId = row.call_id
    ..recipients.addAll(rs)
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
    ..flag = (new Model.MessageFlag(row.flags as Iterable<String>))
    ..enqueued = row.enqueued
    ..createdAt = row.created_at
    ..sent = row.sent;
}

/**
 * Converts a database row into a [Model.Contact] object.
 *
 * FIXME: Fix the format of the distribution list. It is utterly broken, and
 * the SQL query is hell.
 */
Model.Contact _rowToContact(PG.Row row) {
  Iterable<Map> pMaps = row.phone as Iterable<Map>;
  Iterable<Model.PhoneNumber> ps =
      pMaps.map((Map map) => new Model.PhoneNumber.fromMap(map))
      as Iterable<Model.PhoneNumber>;

  List backupContacts = [];
  List emailaddresses = [];
  List handling = [];
  List tags = [];
  List workhours = [];

  List departments = [];
  List infos = [];
  List titles = [];
  List relations = [];
  List responsibilities = [];
  List messagePrerequisites = [];

  if (row.attributes.isNotEmpty) {
    if (row.attributes.containsKey(Key.backup)) {
      backupContacts = row.attributes[Key.backup];
    }

    if (row.attributes.containsKey(Key.emailaddresses)) {
      emailaddresses = row.attributes[Key.emailaddresses];
    }

    if (row.attributes.containsKey(Key.handling)) {
      handling = row.attributes[Key.handling];
    }

    // Tags
    if (row.attributes.containsKey(Key.tags)) {
      tags = row.attributes[Key.tags];
    }

    // Work hours
    if (row.attributes.containsKey(Key.workhours)) {
      workhours = row.attributes[Key.workhours];
    }

    // Department
    if (row.attributes.containsKey(Key.departments)) {
      departments = row.attributes[Key.departments];
    }

    // Info's
    if (row.attributes.containsKey(Key.infos)) {
      infos = row.attributes[Key.infos];
    }

    // Titles
    if (row.attributes.containsKey(Key.titles)) {
      titles = row.attributes[Key.titles];
    }

    // Relations
    if (row.attributes.containsKey(Key.relations)) {
      var relationValue = row.attributes[Key.relations];

      if (relationValue is String) {
        relations = [row.attributes[Key.relations]];
      } else if (relationValue is Iterable) {
        relations = row.attributes[Key.relations];
      } else {
        throw new StateError('Bad relations value: $relationValue');
      }
    }

    // Responsiblities
    if (row.attributes.containsKey(Key.responsibilities)) {
      responsibilities = row.attributes[Key.responsibilities];
    }

    // messagePrerequisites
    if (row.attributes.containsKey(Key.messagePrerequisites)) {
      messagePrerequisites = row.attributes[Key.messagePrerequisites];
    }
  }

  Model.Contact contact = new Model.Contact.empty()
    ..receptionID = row.reception_id
    ..ID = row.contact_id
    ..enabled = row.enabled
    ..fullName = row.full_name
    ..contactType = row.contact_type
    ..phones.addAll(ps)
    ..backupContacts = backupContacts as Iterable<String>
    ..departments = departments as Iterable<String>
    ..emailaddresses = emailaddresses as Iterable<String>
    ..handling = handling as Iterable<String>
    ..infos = infos as Iterable<String>
    ..titles = titles as Iterable<String>
    ..relations.addAll(relations as Iterable<String>)
    ..responsibilities = responsibilities as Iterable<String>
    ..tags = tags as Iterable<String>
    ..statusEmail = row.status_email
    ..workhours = workhours as Iterable<String>
    ..messagePrerequisites = messagePrerequisites as Iterable<String>;

  return contact;
}

Model.PhoneNumber _mapToPhone(Map map) {
  Model.PhoneNumber p = new Model.PhoneNumber.empty()
    ..billing_type = map['billing_type']
    ..description = map['description']
    ..value = map['value']
    ..type = map['kind'];
  if (map['tag'] != null) {
    p.tags.add(map['tag']);
  }

  return p;
}

/**
 * Creates a [CalendarEventChange] from a database row.
 */
Model.CalendarEntryChange _rowToCalendarEventChange(PG.Row row) =>
    new Model.CalendarEntryChange()
      ..userID = row.user_id
      ..lastEntry = Model.CalendarEntry.decode(row.last_entry)
      ..changedAt = row.updated_at
      ..username = row.name;

/**
 * Creates an owner-less [CalendarEntry] from a database row.
 */
Model.CalendarEntry _rowToCalendarEntry(PG.Row row) =>
    new Model.CalendarEntry.empty()
      ..ID = row.id
      ..owner = row.reception_id != null
          ? new Model.OwningReception(row.reception_id)
          : row.contact_id != null
              ? new Model.OwningContact(row.contact_id)
              : throw new ArgumentError('Undefined owner type row$row')
      ..beginsAt = row.start
      ..until = row.stop
      ..content = row.message;
