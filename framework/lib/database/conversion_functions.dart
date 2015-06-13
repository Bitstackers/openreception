part of openreception.database;

Model.Reception _rowToReception(var row) =>
  new Model.Reception.fromMap(
 {'id'           : row.id,
  'full_name'    : row.full_name,
  'enabled'      : row.enabled,
  'extradatauri' : row.extradatauri,
  'reception_telephonenumber': row.reception_telephonenumber,
  'last_check'   : row.last_check.toString(),
  'attributes'   : row.attributes});

Model.BaseContact _rowToBaseContact (var row) =>
    new Model.BaseContact.empty()
      ..id = row.id
      ..fullName = row.full_name
      ..contactType = row.contact_type
      ..enabled = row.enabled;

/**
 * Conversion function.
 */
Model.Organization _rowToOrganization(var row) =>
    new Model.Organization.empty()
  ..billingType = row.billing_type
  ..flag = row.flag
  ..id = row.id
  ..fullName = row.full_name;