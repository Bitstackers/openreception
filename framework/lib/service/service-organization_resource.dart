part of openreception.service;

/**
 * Protocol wrapper class for building homogenic REST
 * resources across servers and clients.
 */
abstract class OrganizationResource {

  static const String _nameSpace = 'organization';

  /**
   * Url for a single organization.
   */
  static Uri single(Uri host, int organizationID, {String token}) {
    Uri url = Uri.parse('${root(host)}/${organizationID}');
    return appendToken(url, token);
  }

  /**
   * Url for the organization namespace.
   */
  static Uri root(Uri host, {String token}) {
    Uri url = Uri.parse('${_removeTailingSlashes(host)}/${_nameSpace}');
    return appendToken(url, token);
  }

  /**
   * Url for list of organizations.
   */
  static Uri list(Uri host, {String token}) {
    Uri url = Uri.parse('${root(host)}');
    return appendToken(url, token);
  }
}
