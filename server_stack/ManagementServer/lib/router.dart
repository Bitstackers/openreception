import 'dart:io';

import 'package:route/pattern.dart';
import 'package:route/server.dart';

import 'configuration.dart';
import 'controller/contact.dart';
import 'controller/dialplan.dart';
import 'controller/organization.dart';
import 'controller/reception.dart';
import 'controller/reception_contact.dart';
import 'controller/user.dart';
import 'database.dart';
import 'utilities/http.dart';
import 'package:OpenReceptionFramework/httpserver.dart' as orf_http;

final Pattern anyThing = new UrlPattern(r'/(.*)');

final Pattern organizationIdUrl          = new UrlPattern(r'/organization/(\d+)');
final Pattern organizationUrl            = new UrlPattern(r'/organization(/?)');
final Pattern organizationContactUrl     = new UrlPattern(r'/organization/(\d+)/contact(/?)');
final Pattern organizationReceptionIdUrl = new UrlPattern(r'/organization/(\d+)/reception/(\d+)');
final Pattern organizationReceptionUrl   = new UrlPattern(r'/organization/(\d+)/reception(/?)');

final Pattern receptionUrl           = new UrlPattern(r'/reception(/?)');
final Pattern receptionIdUrl         = new UrlPattern(r'/reception/(\d+)');
final Pattern receptionContactIdUrl  = new UrlPattern(r'/reception/(\d+)/contact/(\d+)');
final Pattern receptionContactUrl    = new UrlPattern(r'/reception/(\d+)/contact(/?)');
final Pattern receptionContactIdEnpointUrl   = new UrlPattern(r'/reception/(\d+)/contact/(\d+)/endpoint');
final Pattern receptionContactIdEnpointIdUrl = new UrlPattern(r'/reception/(\d+)/contact/(\d+)/endpoint/(.+)/type/(.+)');
final Pattern receptionContactIdDistributionListUrl  = new UrlPattern(r'/reception/(\d+)/contact/(\d+)/distributionlist');
final Pattern dialplanUrl            = new UrlPattern(r'/reception/(\d+)/dialplan');
final Pattern ivrUrl                 = new UrlPattern(r'/reception/(\d+)/ivr');
final Pattern audiofilesUrl          = new UrlPattern(r'/reception/(\d+)/audiofiles');
final Pattern playlistUrl            = new UrlPattern(r'/playlist');
final Pattern playlistIdUrl          = new UrlPattern(r'/playlist/(\d+)');

final Pattern contactIdUrl           = new UrlPattern(r'/contact/(\d+)');
final Pattern contactUrl             = new UrlPattern(r'/contact(/?)');
final Pattern ContactColleaguesUrl   = new UrlPattern(r'/contact/(\d+)/colleagues(/?)');
final Pattern ContactOrganizationUrl = new UrlPattern(r'/contact/(\d+)/organization(/?)');
final Pattern ContactReceptionUrl    = new UrlPattern(r'/contact/(\d+)/reception(/?)');

final Pattern DialplanTemplateUrl = new UrlPattern(r'/dialplantemplate');

final Pattern contactTypesUrl  = new UrlPattern(r'/contacttypes(/?)');
final Pattern addressTypestUrl = new UrlPattern(r'/addresstypes(/?)');

final Pattern UserUrl             = new UrlPattern(r'/user(/?)');
final Pattern UserIdUrl           = new UrlPattern(r'/user/(\d+)');
final Pattern UserIdGroupUrl      = new UrlPattern(r'/user/(\d+)/group');
final Pattern UserIdGroupIdUrl    = new UrlPattern(r'/user/(\d+)/group/(\d+)');
final Pattern UserIdIdentityUrl   = new UrlPattern(r'/user/(\d+)/identity');
final Pattern UserIdIdentityIdUrl = new UrlPattern(r'/user/(\d+)/identity/(.+)');

final Pattern GroupUrl = new UrlPattern(r'/group');

//This resource is only meant to be used, in the time where data is being migrated over.
final Pattern receptionContactIdMoveUrl = new UrlPattern(r'/reception/(\d+)/contact/(\d+)/newContactId/(\d+)');

final List<Pattern> Serviceagents =
[organizationIdUrl, organizationUrl,organizationReceptionIdUrl, organizationReceptionUrl, receptionUrl, contactIdUrl, contactUrl,
 receptionContactIdUrl, receptionContactUrl, dialplanUrl, organizationContactUrl, ContactReceptionUrl, ContactOrganizationUrl,
 UserUrl, UserIdUrl, UserIdGroupUrl, UserIdGroupIdUrl, GroupUrl, UserIdIdentityUrl, UserIdIdentityIdUrl,
 ivrUrl, audiofilesUrl, playlistUrl, playlistIdUrl, receptionContactIdDistributionListUrl,

 receptionContactIdMoveUrl];

ContactController contact;
DialplanController dialplan;
OrganizationController organization;
ReceptionController reception;
ReceptionContactController receptionContact;
UserController user;

void setupRoutes(HttpServer server, Configuration config) {
  Router router = new Router(server)
    ..filter(matchAny(Serviceagents), (HttpRequest req) => authorizedRole(req, config.authUrl, ['Service agent', 'Administrator']))

    ..serve(organizationReceptionUrl, method: HttpMethod.GET).listen(reception.getOrganizationReceptionList)
    ..serve(receptionUrl, method: HttpMethod.GET).listen(reception.getReceptionList)

    ..serve(organizationReceptionUrl, method: HttpMethod.PUT).listen(reception.createReception)
    ..serve(receptionIdUrl, method: HttpMethod.GET)   .listen(reception.getReception)
    ..serve(receptionIdUrl, method: HttpMethod.POST)  .listen(reception.updateReception)
    ..serve(receptionIdUrl, method: HttpMethod.DELETE).listen(reception.deleteReception)

    ..serve(organizationContactUrl, method: HttpMethod.GET).listen(organization.getOrganizationContactList)

    ..serve(ContactReceptionUrl, method: HttpMethod.GET).listen(contact.getReceptionList)

    ..serve(contactTypesUrl, method: HttpMethod.GET).listen(contact.getContactTypeList)
    ..serve(addressTypestUrl, method: HttpMethod.GET).listen(contact.getAddressTypestList)

    ..serve(ContactOrganizationUrl, method: HttpMethod.GET).listen(contact.getAContactsOrganizationList)

    ..serve(contactUrl, method: HttpMethod.GET).listen(contact.getContactList)
    ..serve(contactUrl, method: HttpMethod.PUT).listen(contact.createContact)
    ..serve(contactIdUrl, method: HttpMethod.GET)   .listen(contact.getContact)
    ..serve(contactIdUrl, method: HttpMethod.POST)  .listen(contact.updateContact)
    ..serve(contactIdUrl, method: HttpMethod.DELETE).listen(contact.deleteContact)

    ..serve(receptionContactUrl, method: HttpMethod.GET)  .listen(receptionContact.getReceptionContactList)
    ..serve(receptionContactIdUrl, method: HttpMethod.PUT).listen(receptionContact.createReceptionContact)
    ..serve(receptionContactIdUrl, method: HttpMethod.GET)   .listen(receptionContact.getReceptionContact)
    ..serve(receptionContactIdUrl, method: HttpMethod.POST)  .listen(receptionContact.updateReceptionContact)
    ..serve(receptionContactIdUrl, method: HttpMethod.DELETE).listen(receptionContact.deleteReceptionContact)

    ..serve(receptionContactIdEnpointUrl, method: HttpMethod.GET).listen(receptionContact.getEndpointList)
    ..serve(receptionContactIdEnpointUrl, method: HttpMethod.PUT).listen(receptionContact.createEndpoint)
    ..serve(receptionContactIdEnpointIdUrl, method: HttpMethod.GET).listen(receptionContact.getEndpoint)
    ..serve(receptionContactIdEnpointIdUrl, method: HttpMethod.POST).listen(receptionContact.updateEndpoint)
    ..serve(receptionContactIdEnpointIdUrl, method: HttpMethod.DELETE).listen(receptionContact.deleteEndpoint)

    ..serve(ContactColleaguesUrl, method: HttpMethod.GET).listen(contact.getColleagues)

    ..serve(organizationUrl, method: HttpMethod.GET).listen(organization.getOrganizationList)
    ..serve(organizationUrl, method: HttpMethod.PUT).listen(organization.createOrganization)
    ..serve(organizationIdUrl, method: HttpMethod.GET)   .listen(organization.getOrganization)
    ..serve(organizationIdUrl, method: HttpMethod.POST)  .listen(organization.updateOrganization)
    ..serve(organizationIdUrl, method: HttpMethod.DELETE).listen(organization.deleteOrganization)

    ..serve(dialplanUrl, method: HttpMethod.GET).listen(dialplan.getDialplan)
    ..serve(dialplanUrl, method: HttpMethod.POST).listen(dialplan.updateDialplan)

    ..serve(DialplanTemplateUrl, method: HttpMethod.GET).listen(dialplan.getTemplates)

    ..serve(receptionContactIdDistributionListUrl, method: HttpMethod.GET).listen(receptionContact.getDistributionList)
    ..serve(receptionContactIdDistributionListUrl, method: HttpMethod.POST).listen(receptionContact.updateDistributionList)

    ..serve(ivrUrl, method: HttpMethod.GET).listen(dialplan.getIvr)
    ..serve(ivrUrl, method: HttpMethod.POST).listen(dialplan.updateIvr)

    ..serve(playlistUrl, method: HttpMethod.GET).listen(dialplan.getPlaylists)
    ..serve(playlistUrl, method: HttpMethod.PUT).listen(dialplan.createPlaylist)
    ..serve(playlistIdUrl, method: HttpMethod.GET)   .listen(dialplan.getPlaylist)
    ..serve(playlistIdUrl, method: HttpMethod.POST)  .listen(dialplan.updatePlaylist)
    ..serve(playlistIdUrl, method: HttpMethod.DELETE).listen(dialplan.deletePlaylist)

    ..serve(UserUrl, method: HttpMethod.GET).listen(user.getUserList)
    ..serve(UserUrl, method: HttpMethod.PUT).listen(user.createUser)
    ..serve(UserIdUrl, method: HttpMethod.GET).listen(user.getUser)
    ..serve(UserIdUrl, method: HttpMethod.POST)  .listen(user.updateUser)
    ..serve(UserIdUrl, method: HttpMethod.DELETE).listen(user.deleteUser)

    ..serve(UserIdGroupUrl, method: HttpMethod.GET).listen(user.getUserGroups)
    ..serve(UserIdGroupIdUrl, method: HttpMethod.PUT).listen(user.joinUserGroups)
    ..serve(UserIdGroupIdUrl, method: HttpMethod.DELETE).listen(user.leaveUserGroups)

    ..serve(UserIdIdentityUrl, method: HttpMethod.GET).listen(user.getUserIdentityList)
    ..serve(UserIdIdentityUrl, method: HttpMethod.PUT).listen(user.createUserIdentity)
    ..serve(UserIdIdentityIdUrl, method: HttpMethod.POST)  .listen(user.updateUserIdentity)
    ..serve(UserIdIdentityIdUrl, method: HttpMethod.DELETE).listen(user.deleteUserIdentity)

    ..serve(GroupUrl, method: HttpMethod.GET).listen(user.getGroupList)

    ..serve(audiofilesUrl, method: HttpMethod.GET).listen(dialplan.getAudiofileList)

    ..serve(receptionContactIdMoveUrl, method: HttpMethod.POST).listen(receptionContact.moveContact)

    ..serve(anyThing, method: HttpMethod.OPTIONS).listen(orf_http.preFlight)

    ..defaultStream.listen(orf_http.page404);
}

void setupControllers(Database db, Configuration config) {
  contact = new ContactController(db, config);
  dialplan = new DialplanController(db, config);
  organization = new OrganizationController(db, config);
  reception = new ReceptionController(db, config);
  receptionContact = new ReceptionContactController(db, config);
  user = new UserController(db);
}
