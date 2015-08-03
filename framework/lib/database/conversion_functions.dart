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
  ..groups = row.groups
  ..identities = row.identities;
