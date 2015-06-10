part of openreception.resource;

/**
 * Protocol wrapper class for building homogenic REST
 * resources across servers and clients.
 */
abstract class Management {

  static const _reception = 'reception';
  static const _contact = 'contact';
  static const _organization = 'organization';

  static Uri receptionList(Uri host) =>
    Uri.parse('$host/$_reception');

  static Uri receptionContacts(Uri host, int receptionID) =>
    Uri.parse('$host/$_reception/$receptionID/$_contact');

  static Uri reception(Uri host, int receptionID) =>
    Uri.parse('$host/$_reception/$receptionID');

  static Uri create(Uri host, int organizationID) =>
    Uri.parse('$host/$_organization/$organizationID');

}

