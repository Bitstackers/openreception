part of openreception.database;

abstract class MessageDraft {

  static const String className = '${libraryName}.MessageDraft';

  static final Logger log = new Logger(className);

  /**
   * Creates a draft (JSON encoded document) in the database.
   *
   * [userID]   The user ID of the user owning the draft.
   * [jsonBody] The draft object to store in the database.
   *
   */
  static Future<Map> create(int userID, Map jsonBody, Connection connection) {

    String sql = '''
        INSERT INTO message_draft
        (owner, json) 
        VALUES 
        (@userID, @jsonBody)
        RETURNING id;''';

    Map parameters = {
      'userID': userID,
      'jsonBody': jsonBody
    };

    return connection.query(sql, parameters).then((rows) {
      log.finest('Created a new draft for user with ID $userID');

      Map data = {};

      if (rows.length > 0) {
        data = {
          'draft_id': rows.first.id
        };
      } else {
        throw new Storage.SaveFailed("Failed to insert the draft into database.");
      }

      return data;

    }).catchError((error, stackTrace) {
      log.severe('Create failed', error, stackTrace);
      throw new Storage.ServerError('Database failure.');
    });
  }

  /**
   * Deletes a draft from the database.
   *
   */
  static Future<Map> delete(int draftID, Connection connection) {

    String sql = '''
    DELETE FROM 
           message_draft 
    WHERE id    = $draftID''';

    return connection.execute(sql).then((int rowsAffected) {
      if (rowsAffected == 0) {
        log.severe('Could not find a draft with ID $draftID');
        throw new Storage.NotFound ('Could not find a draft with ID $draftID');
      } else {
        log.finest('Deleted draft with ID $draftID');
      }
      return rowsAffected;
    }).catchError((error, stackTrace) {
      log.severe('Delete failed', error, stackTrace);
      throw new Storage.ServerError('Database failure.');
    });
  }

  /**
   * Lists drafts from the database.
   */
  static Future<Map> list(int offset, int count, Connection connection) {

    String sql = '''
    SELECT id, owner, json
    FROM message_draft
    ORDER BY id
    LIMIT ${count} OFFSET ${offset};''';

    Map parameters = {};

    return connection.query(sql, parameters).then((rows) {

      log.finest ('Returned ${rows.length} draft items');

      List draftList = [];
      for (var row in rows) {
        Map draft = {
          'contact_id': row.id,
          'owner': row.owner,
          'json': row.json
        };
        draftList.add(draft);
      }

      return {
        'drafts': draftList
      };
    }).catchError((error, stackTrace) {
      log.severe('Listing failed', error, stackTrace);
      throw new Storage.ServerError('Database failure.');
    });
  }

  /**
   * Retrieves a single draft from the database.
   */
  static Future<Map> get(int ID, Connection connection) {
    String sql = '''
    SELECT id, owner, json
    FROM message_draft
    WHERE    id = $ID
    ORDER BY id DESC;''';

    Map parameters = {};

    return connection.query(sql, parameters).then((rows) {
      Map data = {};

      if (rows.length == 0 ) {
        throw new Storage.NotFound('No draft found with ID ${ID}.');
      }

        var row = rows.first;
        data =
          {'contact_id' : row.id,
           'owner'      : row.owner,
           'json'       : row.json};

      return data;
    });
  }

  /**
   * Updates a single draft from the database.
   */
  static Future<Map> update(int ID, String jsonBody, Connection connection) {
    String sql = '''
   UPDATE message_draft
      SET json = @jsonBody
    WHERE    id = @draftID;''';

    Map parameters = {'draftID'  : ID,
                      'jsonBody' : jsonBody};

    return connection.query(sql, parameters).then((rows) {
      Map data = {};
      if(rows.length == 1) {
        var row = rows.first;
        data =
          {'contact_id' : row.id,
           'owner'      : row.owner,
           'json'       : row.json};
      }

      return data;
    });
  }
}
