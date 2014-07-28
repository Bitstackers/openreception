library adaheads.server.database;

import 'dart:async';
import 'dart:convert';

import 'package:postgresql/postgresql_pool.dart';
import 'package:postgresql/postgresql.dart';
import 'package:libdialplan/libdialplan.dart';
import 'package:libdialplan/ivr.dart';

import 'model.dart' as model;
import 'configuration.dart';

part 'database/contact.dart';
part 'database/dialplan.dart';
part 'database/distribution_list.dart';
part 'database/endpoint.dart';
part 'database/organization.dart';
part 'database/phone.dart';
part 'database/reception.dart';
part 'database/reception_contact.dart';
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

  Future<int> deleteReception(int id) =>
      _deleteReception(pool, id);

  Future<List<model.Reception>> getContactReceptions(int contactId) =>
      _getContactReceptions(pool, contactId);

  Future<model.Reception> getReception(int receptionId) =>
      _getReception(pool, receptionId);

  Future<List<model.Reception>> getReceptionList() => _getReceptionList(pool);

  Future<int> updateReception(int id, int organizationId, String fullName, Map attributes, String extradatauri, bool enabled, String number) =>
      _updateReception(pool, id, organizationId, fullName, attributes, extradatauri, enabled, number);

  Future<List<model.Reception>> getOrganizationReceptionList(int organizationId) =>
      _getOrganizationReceptionList(pool, organizationId);

  /* ***********************************************
     ****************** Contact ********************
  */

  Future<int> createContact(String fullName, String contact_type, bool enabled) =>
      _createContact(pool, fullName, contact_type, enabled);

  Future<int> deleteContact(int contactId) => _deleteContact(pool, contactId);

  Future<List<model.ReceptionColleague>> getContactColleagues(int contactId) => _getContactColleagues(pool, contactId);

  Future<model.Contact> getContact(int contactId) => _getContact(pool, contactId);

  Future<List<model.Contact>> getContactList() => _getContactList(pool);

  Future<List<String>> getContactTypeList() => _getContactTypeList(pool);
  Future<List<String>> getAddressTypeList() => _getAddressTypeList(pool);

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

  Future<model.ReceptionContact> getReceptionContact(int receptionId, int contactId) =>
      _getReceptionContact(pool, receptionId, contactId);

  Future<List<model.ReceptionContact>> getReceptionContactList(int receptionId) =>
      _getReceptionContactList(pool, receptionId);

  Future<int> updateReceptionContact(int receptionId, int contactId, bool wantMessages, List phonenumbers, Map attributes, bool enabled) =>
      _updateReceptionContact(pool, receptionId, contactId, wantMessages, phonenumbers, attributes, enabled);

  Future moveReceptionContact(int receptionid, int oldContactId, int newContactId) =>
      _moveReceptionContact(pool, receptionid, oldContactId, newContactId);

  /* ***********************************************
     ***************** Endpoints *******************
   */

  Future<int> createEndpoint(int receptionid, int contactid, String address, String type, bool confidential, bool enabled, int priority, String description) =>
      _createEndpoint(pool, receptionid, contactid, address, type, confidential, enabled, priority, description);

  Future<int> deleteEndpoint(int receptionid, int contactid, String address, String type) =>
      _deleteEndpoint(pool, receptionid, contactid, address, type);

  Future<model.Endpoint> getEndpoint(int receptionid, int contactid, String address, String type) =>
      _getEndpoint(pool, receptionid, contactid, address, type);

  Future<List<model.Endpoint>> getEndpointList(int receptionid, int contactid) =>
      _getEndpointList(pool, receptionid, contactid);

  Future<int> updateEndpoint(int fromReceptionid,
                             int fromContactid,
                             String fromAddress,
                             String fromType,
                             int receptionid,
                             int contactid,
                             String address,
                             String type,
                             bool confidential,
                             bool enabled,
                             int priority,
                             String description) =>

      _updateEndpoint(pool,
          fromReceptionid,
          fromContactid,
          fromAddress,
          fromType,
          receptionid,
          contactid,
          address,
          type,
          confidential,
          enabled,
          priority,
          description);

  /* ***********************************************
     ************** DistributionList ***************
   */
  Future<model.DistributionList> getDistributionList(int receptionId, int contactId) =>
      _getDistributionList(pool, receptionId, contactId);

  Future updateDistributionList(int receptionId, int contactId, Map distributionList) =>
      _updateDistributionList(pool, receptionId, contactId, distributionList);

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

  Future updateDialplan(int receptionId, Map dialplan) =>
      _updateDialplan(pool, receptionId, dialplan);

  Future<IvrList> getIvr(int receptionId) =>
      _getIvr(pool, receptionId);

  Future updateIvr(int receptionId, Map ivr) =>
      _updateIvr(pool, receptionId, ivr);

  Future<List<model.DialplanTemplate>> getDialplanTemplates() =>
      _getDialplanTemplates(pool);

  /* ***********************************************
     ****************** Playlist *******************
   */

  Future<int> createPlaylist(
      String       name,
      String       path,
      bool         shuffle,
      int          channels,
      int          interval,
      List<String> chimelist,
      int          chimefreq,
      int          chimemax) =>
      _createPlaylist(pool,
                      name,
                      path,
                      shuffle,
                      channels,
                      interval,
                      chimelist,
                      chimefreq,
                      chimemax);


  Future<int> deletePlaylist(int playlistId) => _deletePlaylist(pool, playlistId);

  Future<model.Playlist> getPlaylist(int playlistId) => _getPlaylist(pool, playlistId);

  Future<List<model.Playlist>> getPlaylistList() =>
      _getPlaylistList(pool);

  Future<int> updatePlaylist(
      int          id,
      String       name,
      String       path,
      bool         shuffle,
      int          channels,
      int          interval,
      List<String> chimelist,
      int          chimefreq,
      int          chimemax) =>
      _updatePlaylist(
          pool,
          id,
          name,
          path,
          shuffle,
          channels,
          interval,
          chimelist,
          chimefreq,
          chimemax);

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
  Future<int> createUser(String name, String extension, String sendFrom) =>
      _createUser(pool, name, extension, sendFrom);

  Future<int> deleteUser(int userId) => _deleteUser(pool, userId);

  Future<model.User> getUser(int userId) => _getUser(pool, userId);

  Future<List<model.User>> getUserList() => _getUserList(pool);

  Future<int> updateUser(int userId, String name, String extension, String sendFrom) =>
      _updateUser(pool, userId, name, extension, sendFrom);

  /* ***********************************************
     **************** User Groups ******************
   */

  Future<List<model.UserGroup>> getUserGroups(int userId) =>
      _getUserGroups(pool, userId);

  Future<List<model.UserGroup>> getGroupList() =>
        _getGroupList(pool);

  Future joinUserGroup(int userId, int groupId) =>
      _joinUserGroup(pool, userId, groupId);

  Future leaveUserGroup(int userId, int groupId) =>
      _leaveUserGroup(pool, userId, groupId);

  /* ***********************************************
     *************** User Identity *****************
   */

  Future<List<model.UserIdentity>> getUserIdentityList(int userId) =>
        _getUserIdentityList(pool, userId);

  Future<String> createUserIdentity(int userId, String identity) =>
      _createUserIdentity(pool, userId, identity);

  Future<int> updateUserIdentity(int userIdKey, String identityIdKey,
      String identityIdValue, int userIdValue) =>
      _updateUserIdentity(pool, userIdKey, identityIdKey, identityIdValue, userIdValue);

  Future<int> deleteUserIdentity(int userId, String identityId) =>
      _deleteUserIdentity(pool, userId, identityId);

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


