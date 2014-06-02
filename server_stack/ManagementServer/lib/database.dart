library adaheads.server.database;

import 'dart:async';
import 'dart:convert';

import 'package:postgresql/postgresql_pool.dart';
import 'package:postgresql/postgresql.dart';
import 'package:libdialplan/libdialplan.dart';

import 'model.dart' as model;
import 'configuration.dart';

part 'database/contact.dart';
part 'database/dialplan.dart';
part 'database/organization.dart';
part 'database/reception.dart';
part 'database/reception_contact.dart';
part 'database/phone.dart';
part 'database/user.dart';

Future<Database> setupDatabase(Configuration config) {
  Database db = new Database(config.dbuser, config.dbpassword, config.dbhost, config.dbport, config.dbname);
  return db.start().then((_) => db);
}

class Database {
  Pool pool;
  String user, password, host, name;
  int port, minimumConnections, maximumConnections;

  Database(String this.user, String this.password, String this.host, int this.port, String this.name, {int this.minimumConnections: 1, int this.maximumConnections: 10});

  Future start() {
    String connectString = 'postgres://${user}:${password}@${host}:${port}/${name}';

    pool = new Pool(connectString, min: minimumConnections, max: maximumConnections);
    return pool.start().then((_) => _testConnection());
  }

  Future _testConnection() => pool.connect().then((Connection conn) => conn.close());

  /* ***********************************************
     ***************** Reception *******************
  */

  Future<int> createReception(int organizationId, String fullName, Map attributes, String extradatauri, bool enabled, String number) =>
      _createReception(pool, organizationId, fullName, attributes, extradatauri, enabled, number);

  Future<int> deleteReception(int organizationId, int id) =>
      _deleteReception(pool, organizationId, id);

  Future<List<model.Reception>> getContactReceptions(int contactId) =>
      _getContactReceptions(pool, contactId);

  Future<model.Reception> getReception(int organizationId, int receptionId) =>
      _getReception(pool, organizationId, receptionId);

  Future<List<model.Reception>> getReceptionList() => _getReceptionList(pool);

  Future<int> updateReception(int organizationId, int id, String fullName, Map attributes, String extradatauri, bool enabled, String number) =>
      _updateReception(pool, organizationId, id, fullName, attributes, extradatauri, enabled, number);

  Future<List<model.Reception>> getOrganizationReceptionList(int organizationId) =>
      _getOrganizationReceptionList(pool, organizationId);

  /* ***********************************************
     ****************** Contact ********************
  */

  Future<int> createContact(String fullName, String contact_type, bool enabled) =>
      _createContact(pool, fullName, contact_type, enabled);

  Future<int> deleteContact(int contactId) => _deleteContact(pool, contactId);

  Future<model.Contact> getContact(int contactId) => _getContact(pool, contactId);

  Future<List<model.Contact>> getContactList() => _getContactList(pool);

  Future<List<String>> getContactTypeList() => _getContactTypeList(pool);

  Future<List<model.Contact>> getOrganizationContactList(int organizationId) =>
      _getOrganizationContactList(pool, organizationId);

  Future<int> updateContact(int contactId, String fullName, String contact_type, bool enabled) =>
      _updateContact(pool, contactId, fullName, contact_type, enabled);

  /* ***********************************************
     ************ Reception Contacts ***************
   */

  Future<int> createReceptionContact(int receptionId, int contactId, bool wantMessages, List phonenumbers, Map attributes, bool enabled) =>
      _createReceptionContact(pool, receptionId, contactId, wantMessages, phonenumbers, attributes, enabled);

  Future<int> deleteReceptionContact(int receptionId, int contactId) =>
      _deleteReceptionContact(pool, receptionId, contactId);

  Future<List<model.Organization>> getAContactsOrganizationList(int contactId) =>
      _getAContactsOrganizationList(pool, contactId);

  Future<List<model.ReceptionContact_ReducedReception>> getAContactsReceptionContactList(int contactId) =>
      _getAContactsReceptionContactList(pool, contactId);

  Future<model.CompleteReceptionContact> getReceptionContact(int receptionId, int contactId) =>
      _getReceptionContact(pool, receptionId, contactId);

  Future<List<model.CompleteReceptionContact>> getReceptionContactList(int receptionId) =>
      _getReceptionContactList(pool, receptionId);

  Future<int> updateReceptionContact(int receptionId, int contactId, bool wantMessages, List phonenumbers, Map attributes, bool enabled) =>
      _updateReceptionContact(pool, receptionId, contactId, wantMessages, phonenumbers, attributes, enabled);

  /* ***********************************************
     *************** Organization ******************
   */

  Future<int> createOrganization(String fullName, String bill_type, String flag) =>
      _createOrganization(pool, fullName, bill_type, flag);

  Future<int> deleteOrganization(int organizationId) =>
      _deleteOrganization(pool, organizationId);

  Future<model.Organization> getOrganization(int organizationId) =>
      _getOrganization(pool, organizationId);

  Future<List<model.Organization>> getOrganizationList() =>
      _getOrganizationList(pool);

  Future<int> updateOrganization(int organizationId, String fullName, String billType, String flag) =>
      _updateOrganization(pool, organizationId, fullName, billType, flag);

  /* ***********************************************
     ****************** Dialplan *******************
   */

  Future<Dialplan> getDialplan(int receptionId) =>
      _getDialplan(pool, receptionId);

  Future<Dialplan> updateDialplan(int receptionId, Map dialplan) =>
      _updateDialplan(pool, receptionId, dialplan);

  Future<List<model.Audiofile>> getAudiofileList() =>
      _getAudiofileList(pool);

  /* ***********************************************
     ******************** Phone ********************
   */

//  Future<int> createPhoneNumber(int receptionId, int contactId, String value, String kind) =>
//      _createPhoneNumber(pool, receptionId, contactId, value, kind);
//
//  Future<int> deletePhoneNumber(int phonenumberId) =>
//      _deletePhoneNumber(pool, phonenumberId);

//  Future<List<model.Phone>> getPhoneNumbers(int receptionId, int contactId) =>
//      _getPhoneNumbers(pool, receptionId, contactId);

  /* ***********************************************
     ********************* User ********************
   */
  Future<int> createUser(String name, String extension) =>
      _createUser(pool, name, extension);

  Future<int> deleteUser(int userId) => _deleteUser(pool, userId);

  Future<model.User> getUser(int userId) => _getUser(pool, userId);

  Future<List<model.User>> getUserList() => _getUserList(pool);

  Future<int> updateUser(int userId, String name, String extension) =>
      _updateUser(pool, userId, name, extension);
}

/* ***********************************************
   ***************** Utilities *******************
 */

Future<List<Row>> query(Pool pool, String sql, [Map parameters = null]) =>  pool.connect()
  .then((Connection conn) => conn.query(sql, parameters).toList()
  .whenComplete(() => conn.close()));

Future<int> execute(Pool pool, String sql, [Map parameters = null]) => pool.connect()
  .then((Connection conn) => conn.execute(sql, parameters)
  .whenComplete(() => conn.close()));


