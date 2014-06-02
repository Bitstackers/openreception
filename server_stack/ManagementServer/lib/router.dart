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
import 'utilities/logger.dart';

final Pattern anyThing = new UrlPattern(r'/(.*)');
final Pattern organizationIdUrl = new UrlPattern(r'/organization/(\d+)');
final Pattern organizationUrl = new UrlPattern(r'/organization(/?)');
final Pattern organizationReceptionIdUrl = new UrlPattern(r'/organization/(\d+)/reception/(\d+)');
final Pattern organizationReceptionUrl = new UrlPattern(r'/organization/(\d+)/reception(/?)');
final Pattern receptionUrl = new UrlPattern(r'/reception(/?)');
final Pattern contactIdUrl = new UrlPattern(r'/contact/(\d+)');
final Pattern contactUrl = new UrlPattern(r'/contact(/?)');
final Pattern receptionContactIdUrl = new UrlPattern(r'/reception/(\d+)/contact/(\d+)');
final Pattern receptionContactUrl = new UrlPattern(r'/reception/(\d+)/contact(/?)');
final Pattern dialplanUrl = new UrlPattern(r'/reception/(\d+)/dialplan');

final Pattern organizationContactUrl = new UrlPattern(r'/organization/(\d+)/contact(/?)');
final Pattern ContactReceptionUrl = new UrlPattern(r'/contact/(\d+)/reception(/?)');
final Pattern ContactOrganizationUrl = new UrlPattern(r'/contact/(\d+)/organization(/?)');

final Pattern contactypestUrl = new UrlPattern(r'/contacttypes(/?)');

final Pattern UserUrl = new UrlPattern(r'/user(/?)');
final Pattern UserIdUrl = new UrlPattern(r'/user/(\d+)');

final Pattern AudioFilelistUrl = new UrlPattern(r'/audiofiles(/?)');

final List<Pattern> Serviceagents =
[organizationIdUrl, organizationUrl,organizationReceptionIdUrl, organizationReceptionUrl, receptionUrl, contactIdUrl, contactUrl,
 receptionContactIdUrl, receptionContactUrl, dialplanUrl, organizationContactUrl, ContactReceptionUrl, ContactOrganizationUrl,
 UserUrl, UserIdUrl ];

ContactController contact;
DialplanController dialplan;
OrganizationController organization;
ReceptionController reception;
ReceptionContactController receptionContact;
UserController user;

void setupRoutes(HttpServer server, Configuration config, Logger logger) {
  Router router = new Router(server)
    ..filter(anyThing, (HttpRequest req) => logHit(req, logger))
    ..filter(matchAny(Serviceagents), (HttpRequest req) => authorized(req, config.authUrl, groupName: 'Service agent'))

    ..serve(organizationReceptionUrl, method: HttpMethod.GET).listen(reception.getOrganizationReceptionList)
    ..serve(receptionUrl, method: HttpMethod.GET).listen(reception.getReceptionList)

    ..serve(organizationReceptionUrl, method: HttpMethod.PUT).listen(reception.createReception)
    ..serve(organizationReceptionIdUrl, method: HttpMethod.GET)   .listen(reception.getReception)
    ..serve(organizationReceptionIdUrl, method: HttpMethod.POST)  .listen(reception.updateReception)
    ..serve(organizationReceptionIdUrl, method: HttpMethod.DELETE).listen(reception.deleteReception)

    ..serve(organizationContactUrl, method: HttpMethod.GET).listen(organization.getOrganizationContactList)

    ..serve(ContactReceptionUrl, method: HttpMethod.GET).listen(contact.getReceptionList)

    ..serve(contactypestUrl, method: HttpMethod.GET).listen(contact.getContactTypeList)

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

    ..serve(organizationUrl, method: HttpMethod.GET).listen(organization.getOrganizationList)
    ..serve(organizationUrl, method: HttpMethod.PUT).listen(organization.createOrganization)
    ..serve(organizationIdUrl, method: HttpMethod.GET)   .listen(organization.getOrganization)
    ..serve(organizationIdUrl, method: HttpMethod.POST)  .listen(organization.updateOrganization)
    ..serve(organizationIdUrl, method: HttpMethod.DELETE).listen(organization.deleteOrganization)

    ..serve(dialplanUrl, method: HttpMethod.GET).listen(reception.getDialplan)
    ..serve(dialplanUrl, method: HttpMethod.POST).listen(reception.updateDialplan)

    ..serve(UserUrl, method: HttpMethod.GET).listen(user.getUserList)
    ..serve(UserUrl, method: HttpMethod.PUT).listen(user.createUser)
    ..serve(UserIdUrl, method: HttpMethod.GET).listen(user.getUser)
    ..serve(UserIdUrl, method: HttpMethod.POST)  .listen(user.updateUser)
    ..serve(UserIdUrl, method: HttpMethod.DELETE).listen(user.deleteUser)

    ..serve(AudioFilelistUrl, method: HttpMethod.GET).listen(dialplan.getAudiofileList)

    ..serve(anyThing, method: HttpMethod.OPTIONS).listen(PreFlight)

    ..defaultStream.listen(NOTFOUND);
}

void setupControllers(Database db) {
  contact = new ContactController(db);
  dialplan = new DialplanController(db);
  organization = new OrganizationController(db);
  reception = new ReceptionController(db);
  receptionContact = new ReceptionContactController(db);
  user = new UserController(db);
}
