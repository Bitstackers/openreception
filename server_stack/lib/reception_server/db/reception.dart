part of receptionserver.database;

abstract class Reception {


  static Future<Iterable<Model.Reception>> list () {
    String sql = '''
      SELECT id, full_name, attributes, enabled, extradatauri, reception_telephonenumber, last_check
      FROM receptions
    ''';

    return connection.query(sql).then((rows) =>
      (rows as Iterable).map(_rowToReception));
  }

  static Future<Model.Reception> get(int id) {
    String sql = '''
      SELECT id, full_name, attributes, enabled, extradatauri, reception_telephonenumber, last_check
      FROM receptions
      WHERE id = @id 
    ''';

    Map parameters = {'id' : id};

    return connection.query(sql, parameters).then((Iterable rows) {

      if (rows.isEmpty) {
        throw new Storage.NotFound('No reception with ID $id');
      }

      return _rowToReception(rows.first);
    });
  }

  static Model.Reception _rowToReception(var row) =>
    new Model.Reception.fromMap(
   {'id'           : row.id,
    'full_name'    : row.full_name,
    'enabled'      : row.enabled,
    'extradatauri' : row.extradatauri,
    'reception_telephonenumber': row.reception_telephonenumber,
    'last_check'   : row.last_check.toString(),
    'attributes'   : row.attributes});
}