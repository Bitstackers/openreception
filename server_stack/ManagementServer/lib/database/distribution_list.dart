part of adaheads.server.database;

Future<model.DistributionList> _getDistributionList(Pool pool, int receptionId, int contactId) {
  String sql = '''
    SELECT distribution_list
    FROM reception_contacts
    WHERE reception_id = @reception_id AND contact_id = @contact_id;
  ''';

  Map parameters =
    {'reception_id': receptionId,
     'contact_id': contactId};

  return query(pool, sql, parameters).then((rows) {
    if(rows.length != 1) {
      return null;
    } else {
      Row row = rows.first;
      Map distributionListMap = JSON.decode(row.distribution_list != null ? row.distribution_list : '{}');
      model.DistributionList distributionList = new model.DistributionList.fromJson(distributionListMap);

      return distributionList;
    }
  });
}

Future _updateDistributionList(Pool pool, int receptionId, int contactId, Map distributionList) {
  String sql = '''
    UPDATE reception_contacts
    SET distribution_list = @distribution_list
    WHERE reception_id = @reception_id AND contact_id = @contact_id;
  ''';

  Map parameters =
    {'distribution_list': JSON.encode(distributionList),
     'reception_id': receptionId,
     'contact_id': contactId};

  return execute(pool, sql, parameters);
}
