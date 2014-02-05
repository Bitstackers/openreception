part of messageserver.database;

/**
 * [receptionContacts] is a list of strings like "contact_id@reception_id"
 */
Future<Map> getSendMessageContacts(List<String> receptionContacts) {
  assert(receptionContacts.isNotEmpty);
  String ContactList = receptionContacts
      .map((String raw) => raw.split('@'))
      .map((List<String> simpleDivide) {
          int contactId = int.parse(simpleDivide[0]);
          int receptionId = int.parse(simpleDivide[1]);
          return'($contactId, $receptionId)';
        }) 
      .join(','); //Transform ["1@2", "3@4"] into "(1,2),(3,4)"
  
  String sql = '''
    SELECT 
      mep.contact_id, 
      mep.reception_id, 
      mep.address_id, 
      mep.confidential, 
      mep.enabled AND rc.enabled AND c.enabled as enabled, 
      mep.priority,
      rc.wants_messages,
      ma.address,
      ma.address_type
    FROM messaging_end_points mep
      JOIN (VALUES $ContactList) alias(contact_id, reception_id) ON alias.contact_id = mep.contact_id AND alias.reception_id = mep.reception_id
      JOIN messaging_addresses ma ON mep.address_id = ma.id
      JOIN reception_contacts rc ON mep.contact_id = rc.contact_id AND mep.reception_id = rc.reception_id
      JOIN contacts c ON rc.contact_id = c.id;''';
  
  return database.query(_pool, sql).then((rows) {
    List contacts = new List();
    for(var row in rows) {
      Map contact =
        {'reception_id'    : row.reception_id,
         'contact_id'      : row.contact_id,
         'address_id'      : row.address_id,
         'confidential'    : row.confidential,
         'enabled'         : row.enabled,
         'priority'        : row.priority,
         'wants_messages'  : row.wants_messages};
      contacts.add(contact);
    }
    
    Map data = {'contacts': contacts};
    
    return data;
  }).catchError((error) {
    log(sql);
    throw error;
  });
}