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
