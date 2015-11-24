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
  ..dialplanId = row.dialplanId
  ..organizationId = row.organization_id
  ..enabled = row.enabled
  ..extraData = row.extradatauri.isNotEmpty
      ? Uri.parse(row.extradatauri)
      : Uri.parse('.')
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
Model.Organization _rowToOrganization(var row) =>
  new Model.Organization.empty()
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
  ..enabled = row.enabled
  ..address = row.send_from
  ..peer = row.extension
  ..groups = row.groups.isNotEmpty
    ? row.groups.map (Model.UserGroup.decode).toList()
    : []
  ..identities = row.identities.isNotEmpty
    ? row.identities.map (Model.UserIdentity.decode).toList()
    : [];


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

/**
 * Converts a database row into a [Model.Contact] object.
 *
 * FIXME: Fix the format of the distribution list. It is utterly broken, and
 * the SQL query is hell.
 */
Model.Contact _rowToContact (var row) {
  var distributionList = new Model.DistributionList.empty();

  Model.Role.RECIPIENT_ROLES.forEach((String role) {
     Iterable nextVal = row.distribution_list[role] == null
       ? []
       : row.distribution_list[role];

     nextVal.forEach((Map dlistMap) {
                      distributionList.add(

                          new Model.DistributionListEntry.empty()
                      ..contactID = dlistMap['contact_id']
                      ..contactName = dlistMap['contact_name']
                      ..receptionID = dlistMap['reception_id']
                      ..receptionName = dlistMap['reception_name']
                      ..role = role);

                  });
    });

  Iterable<Model.MessageEndpoint> endpointIterable =
    row.endpoints.map((Map map) =>
      new Model.MessageEndpoint.fromMap(map));

  Iterable<Model.PhoneNumber> phoneIterable = row.phone.isEmpty
     ? []
     : row.phone.map ((Map map) =>
         new Model.PhoneNumber.fromMap(map));

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

  if(row.attributes.isNotEmpty) {
    if (row.attributes.containsKey (Key.backup)) {
      backupContacts = row.attributes[Key.backup];
    }

    if (row.attributes.containsKey (Key.emailaddresses)) {
      emailaddresses = row.attributes[Key.emailaddresses];
    }

    if(row.attributes.containsKey (Key.handling)) {
      handling = row.attributes[Key.handling];
    }

    // Tags
    if (row.attributes.containsKey (Key.tags)) {
      tags = row.attributes[Key.tags];
    }

    // Work hours
    if (row.attributes.containsKey (Key.workhours)) {
      workhours = row.attributes[Key.workhours];
    }

    // Department
    if (row.attributes.containsKey (Key.departments)) {
      departments = row.attributes[Key.departments];
    }

    // Info's
    if (row.attributes.containsKey (Key.infos)) {
      infos = row.attributes[Key.infos];
    }

    // Titles
    if (row.attributes.containsKey (Key.titles)) {
      titles = row.attributes[Key.titles];
    }

    // Relations
    if (row.attributes.containsKey (Key.relations)) {
      var relationValue = row.attributes[Key.relations];

      if (relationValue is String) {
        relations = [row.attributes[Key.relations]];
      }
      else if (relationValue is Iterable) {
        relations = row.attributes[Key.relations];
      }
      else {
        throw new StateError ('Bad relations value: $relationValue');
      }
    }

    // Responsiblities
    if(row.attributes.containsKey (Key.responsibilities)) {
      responsibilities = row.attributes[Key.responsibilities];
    }

    // messagePrerequisites
    if (row.attributes.containsKey (Key.messagePrerequisites)) {
      messagePrerequisites = row.attributes[Key.messagePrerequisites];
    }

  }

  Model.Contact contact = new Model.Contact.empty()
    ..receptionID = row.reception_id
    ..ID = row.contact_id
    ..wantsMessage = row.wants_messages
    ..enabled = row.rcpenabled && row.conenabled
    ..fullName = row.full_name
    ..contactType = row.contact_type
    ..phones.addAll(phoneIterable)
    ..endpoints.addAll(endpointIterable)
    ..distributionList = distributionList
    ..backupContacts = backupContacts
    ..departments = departments
    ..emailaddresses = emailaddresses
    ..handling = handling
    ..infos = infos
    ..titles = titles
    ..relations.addAll(relations)
    ..responsibilities = responsibilities
    ..tags = tags
    ..workhours = workhours
    ..messagePrerequisites = messagePrerequisites;

  return contact;
}

Model.PhoneNumber _mapToPhone (Map map) {

  Model.PhoneNumber p =
    new Model.PhoneNumber.empty()
      ..billing_type = map['billing_type']
      ..description = map['description']
      ..value = map['value']
      ..type = map['kind'];
  if(map['tag'] != null) {
    p.tags.add(map['tag']);
  }

  return p;
}

/**
 * Creates a [CalendarEventChange] from a database row.
 */
Model.CalendarEntryChange _rowToCalendarEventChange(var row) =>
    new Model.CalendarEntryChange()
    ..userID = row.user_id
    ..changedAt = row.updated_at
    ..username = row.name;

/**
 * Creates an owner-less [CalendarEntry] from a database row.
 */
Model.CalendarEntry _rowToCalendarEntry(var row) =>
    new Model.CalendarEntry.empty()
  ..ID = row.id
  ..beginsAt = row.start
  ..until = row.stop
  ..content = row.message;

/**
 * Creates [CalendarEntry] owned by a [Reception] from a database row.
 */
Model.CalendarEntry _rowToReceptionCalendarEntry(var row) =>
    new Model.CalendarEntry.reception(row.reception_id)
  ..ID = row.id
  ..beginsAt = row.start
  ..until = row.stop
  ..content = row.message;

/**
 * Creates [CalendarEntry] owned by a [Contact] from a database row.
 */
Model.CalendarEntry _rowToContactCalendarEntry(var row) =>
    new Model.CalendarEntry.contact(row.contact_id, row.reception_id)
  ..ID = row.id
  ..beginsAt = row.start
  ..until = row.stop
  ..content = row.message;