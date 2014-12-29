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

Future<Database> setupDatabase(Configuration config) {
  Database db = new Database(config.dbuser, config.dbpassword, config.dbhost, config.dbport, config.dbname);
  return db.start().then((_) => db);
}

class Database {
  ORDatabase.Connection db;
  String user, password, host, name;
  int port, minimumConnections, maximumConnections;

  Database(String this.user, String this.password, String this.host, int this.port, String this.name, {int this.minimumConnections: 1, int this.maximumConnections: 10});

  Future start() {
    String connectString = 'postgres://${user}:${password}@${host}:${port}/${name}';

    return ORDatabase.Connection.connect (connectString)
        .then((ORDatabase.Connection connection) => this.db = connection);
  }

  /* ***********************************************
     ***************** Reception *******************
  */

  Future<int> createReception(int organizationId, String fullName, Map attributes, String extradatauri, bool enabled, String number) =>
      _createReception(this.db, organizationId, fullName, attributes, extradatauri, enabled, number);

  Future<int> deleteReception(int id) =>
      _deleteReception(this.db, id);

  Future<List<model.Reception>> getContactReceptions(int contactId) =>
      _getContactReceptions(this.db, contactId);

  Future<model.Reception> getReception(int receptionId) =>
      _getReception(this.db, receptionId);

  Future<List<model.Reception>> getReceptionList() => _getReceptionList(this.db);

  Future<int> updateReception(int id, int organizationId, String fullName, Map attributes, String extradatauri, bool enabled, String number) =>
      _updateReception(this.db, id, organizationId, fullName, attributes, extradatauri, enabled, number);

  Future<List<model.Reception>> getOrganizationReceptionList(int organizationId) =>
      _getOrganizationReceptionList(this.db, organizationId);

  /* ***********************************************
     ****************** Contact ********************
  */

  Future<int> createContact(String fullName, String contact_type, bool enabled) =>
      _createContact(this.db, fullName, contact_type, enabled);

  Future<int> deleteContact(int contactId) => _deleteContact(this.db, contactId);

  Future<List<model.ReceptionColleague>> getContactColleagues(int contactId) => _getContactColleagues(this.db, contactId);

  Future<model.Contact> getContact(int contactId) => _getContact(this.db, contactId);

  Future<List<model.Contact>> getContactList() => _getContactList(this.db);

  Future<List<String>> getContactTypeList() => _getContactTypeList(this.db);
  Future<List<String>> getAddressTypeList() => _getAddressTypeList(this.db);

  Future<List<model.Contact>> getOrganizationContactList(int organizationId) =>
      _getOrganizationContactList(this.db, organizationId);

  Future<int> updateContact(int contactId, String fullName, String contact_type, bool enabled) =>
      _updateContact(this.db, contactId, fullName, contact_type, enabled);

  /* ***********************************************
     ************ Reception Contacts ***************
   */

  Future<int> createReceptionContact(int receptionId, int contactId, bool wantMessages, List phonenumbers, Map attributes, bool enabled) =>
      _createReceptionContact(this.db, receptionId, contactId, wantMessages, phonenumbers, attributes, enabled);

  Future<int> deleteReceptionContact(int receptionId, int contactId) =>
      _deleteReceptionContact(this.db, receptionId, contactId);

  Future<List<model.Organization>> getAContactsOrganizationList(int contactId) =>
      _getAContactsOrganizationList(this.db, contactId);

  Future<List<model.ReceptionContact_ReducedReception>> getAContactsReceptionContactList(int contactId) =>
      _getAContactsReceptionContactList(this.db, contactId);

  Future<model.ReceptionContact> getReceptionContact(int receptionId, int contactId) =>
      _getReceptionContact(this.db, receptionId, contactId);

  Future<List<model.ReceptionContact>> getReceptionContactList(int receptionId) =>
      _getReceptionContactList(this.db, receptionId);

  Future<int> updateReceptionContact(int receptionId, int contactId, bool wantMessages, List phonenumbers, Map attributes, bool enabled) =>
      _updateReceptionContact(this.db, receptionId, contactId, wantMessages, phonenumbers, attributes, enabled);

  Future moveReceptionContact(int receptionid, int oldContactId, int newContactId) =>
      _moveReceptionContact(this.db, receptionid, oldContactId, newContactId);

  /* ***********************************************
     ***************** Endpoints *******************
   */

  Future<int> createEndpoint(int receptionid, int contactid, String address, String type, bool confidential, bool enabled, int priority, String description) =>
      _createEndpoint(this.db, receptionid, contactid, address, type, confidential, enabled, priority, description);

  Future<int> deleteEndpoint(int receptionid, int contactid, String address, String type) =>
      _deleteEndpoint(this.db, receptionid, contactid, address, type);

  Future<model.Endpoint> getEndpoint(int receptionid, int contactid, String address, String type) =>
      _getEndpoint(this.db, receptionid, contactid, address, type);

  Future<List<model.Endpoint>> getEndpointList(int receptionid, int contactid) =>
      _getEndpointList(this.db, receptionid, contactid);

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

      _updateEndpoint(this.db,
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
      _getReceptionContactCalendarEvents(this.db, receptionId, contactId);

  Future<int> createReceptionContactCalendarEvent(int receptioinId, int contactId, String message, DateTime start, DateTime stop) =>
      _createReceptionContactCalendarEvent(this.db, receptioinId, contactId, message, start, stop);

  Future<int> updateCalendarEvent(int eventId, String message, DateTime start, DateTime stop, [Map distributionList]) =>
      _updateCalendarEvent(this.db, eventId, message, start, stop);

  Future<int> deleteCalendarEvent(int eventId) =>
      _deleteCalendarEvent(this.db, eventId);

  /* ***********************************************
     ************** DistributionList ***************
   */
  Future<model.DistributionList> getDistributionList(int receptionId, int contactId) =>
      _getDistributionList(this.db, receptionId, contactId);

//  Future updateDistributionList(int receptionId, int contactId, Map distributionList) =>
//      _updateDistributionList(this.db, receptionId, contactId, distributionList);

  Future createDistributionListEntry(int ownerReceptionId, int ownerContactId, String role, int recipientReceptionId, int recipientContactId) =>
      _createDistributionListEntry(this.db, ownerReceptionId, ownerContactId, role, recipientReceptionId, recipientContactId);

  Future deleteDistributionListEntry(int entryId) =>
      _deleteDistributionListEntry(this.db, entryId);

  /* ***********************************************
     *************** Organization ******************
   */

  Future<int> createOrganization(String fullName, String billingType, String flag) =>
      _createOrganization(this.db, fullName, billingType, flag);

  Future<int> deleteOrganization(int organizationId) =>
      _deleteOrganization(this.db, organizationId);

  Future<model.Organization> getOrganization(int organizationId) =>
      _getOrganization(this.db, organizationId);

  Future<List<model.Organization>> getOrganizationList() =>
      _getOrganizationList(this.db);

  Future<int> updateOrganization(int organizationId, String fullName, String billingType, String flag) =>
      _updateOrganization(this.db, organizationId, fullName, billingType, flag);

  /* ***********************************************
     ****************** Dialplan *******************
   */

  Future<Dialplan> getDialplan(int receptionId) =>
      _getDialplan(this.db, receptionId);

  Future updateDialplan(int receptionId, Map dialplan) =>
      _updateDialplan(this.db, receptionId, dialplan);

  Future markDialplanAsCompiled(int receptionId) =>
      _markDialplanAsCompiled(this.db, receptionId);

  Future<IvrList> getIvr(int receptionId) =>
      _getIvr(this.db, receptionId);

  Future updateIvr(int receptionId, Map ivr) =>
      _updateIvr(this.db, receptionId, ivr);

  Future<List<model.DialplanTemplate>> getDialplanTemplates() =>
      _getDialplanTemplates(this.db);

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
      _createPlaylist(this.db,
                      name,
                      path,
                      shuffle,
                      channels,
                      interval,
                      chimelist,
                      chimefreq,
                      chimemax);


  Future<int> deletePlaylist(int playlistId) => _deletePlaylist(this.db, playlistId);

  Future<model.Playlist> getPlaylist(int playlistId) => _getPlaylist(this.db, playlistId);

  Future<List<model.Playlist>> getPlaylistList() =>
      _getPlaylistList(this.db);

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
          this.db,
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
      _createUser(this.db, name, extension, sendFrom);

  Future<int> deleteUser(int userId) => _deleteUser(this.db, userId);

  Future<model.User> getUser(int userId) => _getUser(this.db, userId);

  Future<List<model.User>> getUserList() => _getUserList(this.db);

  Future<int> updateUser(int userId, String name, String extension, String sendFrom) =>
      _updateUser(this.db, userId, name, extension, sendFrom);

  /* ***********************************************
     **************** User Groups ******************
   */

  Future<List<model.UserGroup>> getUserGroups(int userId) =>
      _getUserGroups(this.db, userId);

  Future<List<model.UserGroup>> getGroupList() =>
        _getGroupList(this.db);

  Future joinUserGroup(int userId, int groupId) =>
      _joinUserGroup(this.db, userId, groupId);

  Future leaveUserGroup(int userId, int groupId) =>
      _leaveUserGroup(this.db, userId, groupId);

  /* ***********************************************
     *************** User Identity *****************
   */

  Future<List<model.UserIdentity>> getUserIdentityList(int userId) =>
        _getUserIdentityList(this.db, userId);

  Future<String> createUserIdentity(int userId, String identity) =>
      _createUserIdentity(this.db, userId, identity);

  Future<int> updateUserIdentity(int userIdKey, String identityIdKey,
      String identityIdValue, int userIdValue) =>
      _updateUserIdentity(this.db, userIdKey, identityIdKey, identityIdValue, userIdValue);

  Future<int> deleteUserIdentity(int userId, String identityId) =>
      _deleteUserIdentity(this.db, userId, identityId);
}
