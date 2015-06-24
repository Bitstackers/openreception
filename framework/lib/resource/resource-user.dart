part of openreception.resource;

/**
 * Protocol wrapper class for building homogenic REST
 * resources across servers and clients.
 */
abstract class User {

  static const String _user = 'user';
  static const String _group = 'group';
  static const String _identity = 'identity';

  static Uri single(Uri host, int userID)
    => Uri.parse('${root(host)}/${userID}');

  static Uri root(Uri host)
    => Uri.parse('$host/$_user');

  static Uri list(Uri host)
    => Uri.parse('${root(host)}');

  static Uri userGroup(Uri host, int userID)
    => Uri.parse('${single(host, userID)}/$_group');

  static Uri group(Uri host)
    => Uri.parse('$host/$_group');

  static Uri userGroupByID(Uri host, int userID, int groupID)
      => Uri.parse('$host/$userID/$_group/$groupID');

  static Uri userIndentities(Uri host, int userID)
  => Uri.parse('$host/$userID/$_identity');

  static Uri userIndentity(Uri host, int userID, String identity)
  => Uri.parse('$host/$userID/$_identity/identity');

}
