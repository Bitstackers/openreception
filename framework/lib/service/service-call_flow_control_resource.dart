part of openreception.service;

/**
 * Protocol wrapper class for building homogenic REST
 * resources across servers and clients.
 */
abstract class CallFlowControlResource {

  static String nameSpace = 'call';

  /**
   * Builds a Uri to retrieve a every current peer resource.
   * The output format is:
   *    http://hostname/peer/list
   */
  static Uri peerList(Uri host)
    => Uri.parse('${host}/peer/list');

  /**
   * Builds a Uri to retrieve a single call resource.
   * The output format is:
   *    http://hostname/call/<callID>
   */
  static Uri single(Uri host, String callID)
    => Uri.parse('${root(host)}/${callID}');

  /**
   * Builds a Uri to pickup a specific call resource.
   * The output format is:
   *    http://hostname/call/<callID>/pickup
   */
  static Uri pickup(Uri host, String callID)
    =>  Uri.parse ('${single (root(host), callID)}/pickup');

  /**
   * Builds a Uri to originate to a specific extension.
   * The output format is:
   *    http://hostname/call/originate/<extension>/reception/<receptionID>/contact/<contactID>
   */
  static Uri originate(Uri host, String extension, int contactID, int receptionID)
    =>  Uri.parse ('${root(host)}/originate/${extension}/reception/${receptionID}/contact/${contactID}');

  /**
   * Builds a Uri to park a specific call resource.
   * The output format is:
   *    http://hostname/call/<callID>/park
   */
  static Uri park(Uri host, String callID)
    =>  Uri.parse ('${single (root(host), callID)}/park');

  /**
   * Builds a Uri to hangup a specific call resource.
   * The output format is:
   *    http://hostname/call/<callID>/hangup
   */
  static Uri hangup(Uri host, String callID)
    =>  Uri.parse ('${single (root(host), callID)}/hangup');

  /**
   * Builds a Uri to transfer a specific call resource.
   * The output format is:
   *    http://hostname/call/<callID>/hangup
   */
  static Uri transfer(Uri host, String callID, String destination)
    =>  Uri.parse ('${single (root(host), callID)}/transfer/${destination}');

  /**
   * Builds a Uri to retrieve a every current call resource.
   * The output format is:
   *    http://hostname/call/list
   */
  static Uri list(Uri host)
    => Uri.parse('${root(host)}/list');

  /**
   * Builds a Uri to retrieve a every current queued call resource.
   * The output format is:
   *    http://hostname/call/list
   */
  static Uri queue(Uri host)
    => Uri.parse('${root(host)}/queue');

  /**
   * Builds up the root resource.
   * The output format is:
   *    http://hostname/call
   */
  static Uri root(Uri host)
    => Uri.parse('${_removeTailingSlashes(host)}/${nameSpace}');
}
