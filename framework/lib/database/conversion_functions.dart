part of openreception.database;

Model.Reception _rowToReception(var row) =>
  new Model.Reception.empty()
    ..ID = row.id
    ..fullName = row.full_name
    ..organizationId = row.organization_id
    ..enabled = row.enabled
    ..extraData = row.extradatauri != null ? Uri.parse(row.extradatauri) : null
    ..extension = row.reception_telephonenumber
    ..lastChecked = row.last_check
    ..attributes = row.attributes;

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