part of openreception.service;

/**
 * Protocol wrapper class for building homogenic REST
 * resources across servers and clients.
 */
abstract class OrganizationResource {

  static String nameSpace = 'organization';

  static Uri single(Uri host, int organizationID)
    => Uri.parse('${root(host)}/${organizationID}');

  static Uri root(Uri host)
    => Uri.parse('${_removeTailingSlashes(host)}/${nameSpace}');

  static Uri list(Uri host)
    => Uri.parse('${root(host)}');
}
