library adaheads.server.database;

import 'dart:async';
import 'dart:convert';

import 'package:openreception_framework/database.dart' as ORDatabase;
import 'package:libdialplan/libdialplan.dart';
import 'package:libdialplan/ivr.dart';

import 'model.dart' as model;
import 'configuration.dart';

part 'database/calendar.dart';
part 'database/contact.dart';
part 'database/dialplan.dart';
part 'database/distribution_list.dart';
part 'database/endpoint.dart';
part 'database/organization.dart';
part 'database/reception.dart';
part 'database/reception_contact.dart';
part 'database/user.dart';

ORDatabase.Connection _connection;
const String libraryName = 'adaheads.server.database';

Future<Database> setupDatabase(Configuration config) {
  Database db = new Database(config.dbuser, config.dbpassword, config.dbhost, config.dbport, config.dbname);
  return db.start().then((_) => db);
}

class Database {
  String user, password, host, name;
  int port, minimumConnections, maximumConnections;

  Database(String this.user, String this.password, String this.host, int this.port, String this.name, {int this.minimumConnections: 1, int this.maximumConnections: 10});

  Future start() {
    String connectString = 'postgres://${user}:${password}@${host}:${port}/${name}';

    return ORDatabase.Connection.connect (connectString)
        .then((ORDatabase.Connection newConnection) => _connection = newConnection);
  }

  /* ***********************************************
     ***************** Reception *******************
  */

  Future<int> createReception(int organizationId, String fullName, Map attributes, String extradatauri, bool enabled, String number) =>
      _createReception(_connection, organizationId, fullName, attributes, extradatauri, enabled, number);

  Future<int> deleteReception(int id) =>
      _deleteReception(_connection, id);

  Future<List<model.Reception>> getContactReceptions(int contactId) =>
      _getContactReceptions(_connection, contactId);

  Future<model.Reception> getReception(int receptionId) =>
      _getReception(_connection, receptionId);

  Future<List<model.Reception>> getReceptionList() => _getReceptionList(_connection);

  Future<int> updateReception(int id, int organizationId, String fullName, Map attributes, String extradatauri, bool enabled, String number) =>
      _updateReception(_connection, id, organizationId, fullName, attributes, extradatauri, enabled, number);

  Future<List<model.Reception>> getOrganizationReceptionList(int organizationId) =>
      _getOrganizationReceptionList(_connection, organizationId);

  /* ***********************************************
     ****************** Contact ********************
  */

  Future<List<model.ReceptionColleague>> getContactColleagues(int contactId) => _getContactColleagues(_connection, contactId);

  Future<List<String>> getContactTypeList() => _getContactTypeList(_connection);
  Future<List<String>> getAddressTypeList() => _getAddressTypeList(_connection);


  /* ***********************************************
     ************ Reception Contacts ***************
   */

  Future<int> createReceptionContact(int receptionId, int contactId, bool wantMessages, List phonenumbers, Map attributes, bool enabled) =>
      _createReceptionContact(_connection, receptionId, contactId, wantMessages, phonenumbers, attributes, enabled);

  Future<int> deleteReceptionContact(int receptionId, int contactId) =>
      _deleteReceptionContact(_connection, receptionId, contactId);

  Future<List<model.Organization>> getAContactsOrganizationList(int contactId) =>
      _getAContactsOrganizationList(_connection, contactId);

  Future<List<model.ReceptionContact_ReducedReception>> getAContactsReceptionContactList(int contactId) =>
      _getAContactsReceptionContactList(_connection, contactId);

  Future<int> updateReceptionContact(int receptionId, int contactId, bool wantMessages, List phonenumbers, Map attributes, bool enabled) =>
      _updateReceptionContact(_connection, receptionId, contactId, wantMessages, phonenumbers, attributes, enabled);

  Future moveReceptionContact(int receptionid, int oldContactId, int newContactId) =>
      _moveReceptionContact(_connection, receptionid, oldContactId, newContactId);

  /* ***********************************************
     ***************** Endpoints *******************
   */

  Future<int> createEndpoint(int receptionid, int contactid, String address, String type, bool confidential, bool enabled, int priority, String description) =>
      _createEndpoint(_connection, receptionid, contactid, address, type, confidential, enabled, priority, description);

  Future<int> deleteEndpoint(int receptionid, int contactid, String address, String type) =>
      _deleteEndpoint(_connection, receptionid, contactid, address, type);

  Future<model.Endpoint> getEndpoint(int receptionid, int contactid, String address, String type) =>
      _getEndpoint(_connection, receptionid, contactid, address, type);

  Future<List<model.Endpoint>> getEndpointList(int receptionid, int contactid) =>
      _getEndpointList(_connection, receptionid, contactid);

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

      _updateEndpoint(_connection,
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
     ****************** Calendar *******************
   */

  Future<List<model.Event>> getReceptionContactCalendarEvents(int receptionId, int contactId) =>
      _getReceptionContactCalendarEvents(_connection, receptionId, contactId);

  Future<int> createReceptionContactCalendarEvent(int receptioinId, int contactId, String message, DateTime start, DateTime stop) =>
      _createReceptionContactCalendarEvent(_connection, receptioinId, contactId, message, start, stop);

  Future<int> updateCalendarEvent(int eventId, String message, DateTime start, DateTime stop, [Map distributionList]) =>
      _updateCalendarEvent(_connection, eventId, message, start, stop);

  Future<int> deleteCalendarEvent(int eventId) =>
      _deleteCalendarEvent(_connection, eventId);

  /* ***********************************************
     ************** DistributionList ***************
   */
  Future<model.DistributionList> getDistributionList(int receptionId, int contactId) =>
      _getDistributionList(_connection, receptionId, contactId);

//  Future updateDistributionList(int receptionId, int contactId, Map distributionList) =>
//      _updateDistributionList(_connection, receptionId, contactId, distributionList);

  Future createDistributionListEntry(int ownerReceptionId, int ownerContactId, String role, int recipientReceptionId, int recipientContactId) =>
      _createDistributionListEntry(_connection, ownerReceptionId, ownerContactId, role, recipientReceptionId, recipientContactId);

  Future deleteDistributionListEntry(int entryId) =>
      _deleteDistributionListEntry(_connection, entryId);

  /* ***********************************************
     *************** Organization ******************
   */

  Future<int> createOrganization(String fullName, String billingType, String flag) =>
      _createOrganization(_connection, fullName, billingType, flag);

  Future<int> deleteOrganization(int organizationId) =>
      _deleteOrganization(_connection, organizationId);

  Future<model.Organization> getOrganization(int organizationId) =>
      _getOrganization(_connection, organizationId);

  Future<List<model.Organization>> getOrganizationList() =>
      _getOrganizationList(_connection);

  Future<int> updateOrganization(int organizationId, String fullName, String billingType, String flag) =>
      _updateOrganization(_connection, organizationId, fullName, billingType, flag);

  /* ***********************************************
     ****************** Dialplan *******************
   */

  Future<Dialplan> getDialplan(int receptionId) =>
      _getDialplan(_connection, receptionId);

  Future updateDialplan(int receptionId, Map dialplan) =>
      _updateDialplan(_connection, receptionId, dialplan);

  Future markDialplanAsCompiled(int receptionId) =>
      _markDialplanAsCompiled(_connection, receptionId);

  Future<IvrList> getIvr(int receptionId) =>
      _getIvr(_connection, receptionId);

  Future updateIvr(int receptionId, Map ivr) =>
      _updateIvr(_connection, receptionId, ivr);

  Future<List<model.DialplanTemplate>> getDialplanTemplates() =>
      _getDialplanTemplates(_connection);

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
      _createPlaylist(_connection,
                      name,
                      path,
                      shuffle,
                      channels,
                      interval,
                      chimelist,
                      chimefreq,
                      chimemax);


  Future<int> deletePlaylist(int playlistId) => _deletePlaylist(_connection, playlistId);

  Future<model.Playlist> getPlaylist(int playlistId) => _getPlaylist(_connection, playlistId);

  Future<List<model.Playlist>> getPlaylistList() =>
      _getPlaylistList(_connection);

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
          _connection,
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
     ********************* User ********************
   */
  Future<int> createUser(String name, String extension, String sendFrom) =>
      _createUser(_connection, name, extension, sendFrom);

  Future<int> deleteUser(int userId) => _deleteUser(_connection, userId);

  Future<model.User> getUser(int userId) => _getUser(_connection, userId);

  Future<List<model.User>> getUserList() => _getUserList(_connection);

  Future<int> updateUser(int userId, String name, String extension, String sendFrom) =>
      _updateUser(_connection, userId, name, extension, sendFrom);

  /* ***********************************************
     **************** User Groups ******************
   */

  Future<List<model.UserGroup>> getUserGroups(int userId) =>
      _getUserGroups(_connection, userId);

  Future<List<model.UserGroup>> getGroupList() =>
        _getGroupList(_connection);

  Future joinUserGroup(int userId, int groupId) =>
      _joinUserGroup(_connection, userId, groupId);

  Future leaveUserGroup(int userId, int groupId) =>
      _leaveUserGroup(_connection, userId, groupId);

  /* ***********************************************
     *************** User Identity *****************
   */

  Future<List<model.UserIdentity>> getUserIdentityList(int userId) =>
        _getUserIdentityList(_connection, userId);

  Future<String> createUserIdentity(int userId, String identity) =>
      _createUserIdentity(_connection, userId, identity);

  Future<int> updateUserIdentity(int userIdKey, String identityIdKey,
      String identityIdValue, int userIdValue) =>
      _updateUserIdentity(_connection, userIdKey, identityIdKey, identityIdValue, userIdValue);

  Future<int> deleteUserIdentity(int userId, String identityId) =>
      _deleteUserIdentity(_connection, userId, identityId);
}
