part of openreception.resource;

/**
 * Protocol wrapper class for building homogenic REST
 * resources across servers and clients.
 */
abstract class Management {

  static const _reception = 'reception';
  static const _contact = 'contact';
  static const _organization = 'organization';

  static Uri receptions(Uri host) =>
    Uri.parse('$host/$_reception');

  static Uri receptionContacts(Uri host, int receptionID) =>
    Uri.parse('$host/$_reception/$receptionID/$_contact');

  static Uri reception(Uri host, int receptionID) =>
    Uri.parse('$host/$_reception/$receptionID');

  static Uri create(Uri host, int organizationID) =>
    Uri.parse('$host/$_organization/$organizationID');

  static Uri organization(Uri host, int organizationID) =>
    Uri.parse('$host/$_organization/$organizationID');

  static Uri organizations(Uri host) =>
    Uri.parse('$host/$_organization');

  static Uri organizationContacts(Uri host, int organizationID) =>
    Uri.parse('${organization}/$_contact');

  static Uri organizationContact(Uri host, int organizationID, int contactID) =>
    Uri.parse('${organization}/$_contact');

  static Uri organizationReception(Uri host, int organizationID, int receptionID) =>
    Uri.parse('${organization}/$_reception/$receptionID');

  static Uri contactTypes(Uri host) => Uri.parse('$host/contacttypes');


//  final Pattern receptionUrl           = new UrlPattern(r'/reception(/?)');
//  final Pattern receptionIdUrl         = new UrlPattern(r'/reception/(\d+)');
//  final Pattern receptionContactIdUrl  = new UrlPattern(r'/reception/(\d+)/contact/(\d+)');
//  final Pattern receptionContactUrl    = new UrlPattern(r'/reception/(\d+)/contact(/?)');
//  final Pattern receptionContactIdEnpointUrl   = new UrlPattern(r'/reception/(\d+)/contact/(\d+)/endpoint');
//  final Pattern receptionContactIdEnpointIdUrl = new UrlPattern(r'/reception/(\d+)/contact/(\d+)/endpoint/(.+)/type/(.+)');
//  final Pattern receptionContactIdDistributionListUrl  = new UrlPattern(r'/reception/(\d+)/contact/(\d+)/distributionlist');
//  final Pattern receptionContactIdDistributionListEntryUrl  = new UrlPattern(r'/reception/(\d+)/contact/(\d+)/distributionlist/(\d+)');
//  final Pattern receptionContactIdCalendarUrl   = new UrlPattern(r'/reception/(\d+)/contact/(\d+)/calendar');
//  final Pattern receptionContactIdCalendarIdUrl = new UrlPattern(r'/reception/(\d+)/contact/(\d+)/calendar/(\d+)');
//  final Pattern dialplanUrl            = new UrlPattern(r'/reception/(\d+)/dialplan');
//  final Pattern dialplanCompileUrl     = new UrlPattern(r'/reception/(\d+)/dialplan/compile');
//  final Pattern ivrUrl                 = new UrlPattern(r'/reception/(\d+)/ivr');
//  final Pattern audiofilesUrl          = new UrlPattern(r'/reception/(\d+)/audiofiles');
//  final Pattern receptionRecordUrl     = new UrlPattern(r'/reception/(\d+)/record');
//  final Pattern playlistUrl            = new UrlPattern(r'/playlist');
//  final Pattern playlistIdUrl          = new UrlPattern(r'/playlist/(\d+)');
//
//  final Pattern contactIdUrl           = new UrlPattern(r'/contact/(\d+)');
//  final Pattern contactUrl             = new UrlPattern(r'/contact(/?)');
//  final Pattern ContactColleaguesUrl   = new UrlPattern(r'/contact/(\d+)/colleagues(/?)');
//  final Pattern ContactOrganizationUrl = new UrlPattern(r'/contact/(\d+)/organization(/?)');
//  final Pattern ContactReceptionUrl    = new UrlPattern(r'/contact/(\d+)/reception(/?)');
//
//  final Pattern DialplanTemplateUrl = new UrlPattern(r'/dialplantemplate');
//
//  final Pattern contactTypesUrl  = new UrlPattern(r'/contacttypes(/?)');
//  final Pattern addressTypestUrl = new UrlPattern(r'/addresstypes(/?)');
//
//  final Pattern UserUrl             = new UrlPattern(r'/user(/?)');
//  final Pattern UserIdUrl           = new UrlPattern(r'/user/(\d+)');
//  final Pattern UserIdGroupUrl      = new UrlPattern(r'/user/(\d+)/group');
//  final Pattern UserIdGroupIdUrl    = new UrlPattern(r'/user/(\d+)/group/(\d+)');
//  final Pattern UserIdIdentityUrl   = new UrlPattern(r'/user/(\d+)/identity');
//  final Pattern UserIdIdentityIdUrl = new UrlPattern(r'/user/(\d+)/identity/(.+)');
}

