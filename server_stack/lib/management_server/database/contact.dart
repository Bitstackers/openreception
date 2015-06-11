part of adaheads.server.database;

Future<List<model.ReceptionColleague>> _getContactColleagues(ORDatabase.Connection connection, int contactId) {
  String sql = '''
     SELECT
        r.organization_id as organizationid,
        r.id as receptionid,
        r.full_name as receptionname,
        r.enabled as receptionenabled,
        c.id as contactid,
        c.full_name as contactname,
        c.enabled as contactenabled,
        c.contact_type as contacttype
     FROM reception_contacts rc
        JOIN receptions r on rc.reception_id = r.id
        JOIN contacts c on rc.contact_id = c.id
        JOIN (SELECT reception_id
              FROM reception_contacts
              WHERE contact_id = @contactid) cr on cr.reception_id = rc.reception_id
     ORDER BY r.full_name, c.full_name
    ''';

  Map parameters = {'contactid': contactId};

  return connection.query(sql, parameters).then((List rows) {
    Map<int, model.ReceptionColleague> receptions = new Map<int, model.ReceptionColleague>();

    for(var row in rows) {
      int receptionId = row.receptionid;
      if(!receptions.containsKey(receptionId)) {
        model.ReceptionColleague reception = new model.ReceptionColleague(row.receptionid, row.organizationid, row.receptionname, row.receptionenabled);
        receptions[receptionId] = reception;
      }

      model.Colleague colleague = new model.Colleague(row.contactid, row.contactname, row.contactenabled, row.contacttype);
      receptions[receptionId].Colleagues.add(colleague);
    }

    return receptions.values.toList();
  });
}



Future<List<String>> _getContactTypeList(ORDatabase.Connection connection) {
  String sql = '''
    SELECT value
    FROM contact_types;
  ''';

  return connection.query(sql).then((List Rows) => Rows.map((row) => row.value).toList());
}

Future<List<String>> _getAddressTypeList(ORDatabase.Connection connection) {
  String sql = '''
    SELECT value
    FROM messaging_address_types;
  ''';

  return connection.query(sql).then((List Rows) => Rows.map((row) => row.value).toList());
}



