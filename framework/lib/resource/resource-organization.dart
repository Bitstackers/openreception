part of openreception.resource;

/**
 * Protocol wrapper class for building homogenic REST
 * resources across servers and clients.
 */
abstract class Organization {

  static const String _nameSpace = 'organization';

  /**
   * Url for a single organization.
   */
  static Uri single(Uri host, int organizationID) =>
      Uri.parse('${root(host)}/${organizationID}');

  /**
   * Url for the organization namespace.
   */
  static Uri root(Uri host) =>
    Uri.parse('${Util.removeTailingSlashes(host)}/${_nameSpace}');

  /**
   * Url for list of organizations.
   */
  static Uri list(Uri host, {String token}) =>
    Uri.parse('${root(host)}');
}
