part of openreception.resource;

/**
 * Protocol wrapper class for building homogenic REST
 * resources across servers and clients.
 */
abstract class CDR {

  static const String _cdr = 'cdr';
  static const String _checkpoint = 'checkpoint';


  static Uri list(Uri host, String from, String to) =>
      Uri.parse ('${root(host)}?${from}&${to}');

  static Uri checkpoint(Uri host) =>
      Uri.parse ('$host/$_checkpoint');

  static Uri root(Uri host) =>
      Uri.parse('${Util.removeTailingSlashes(host)}/${_cdr}');
}
