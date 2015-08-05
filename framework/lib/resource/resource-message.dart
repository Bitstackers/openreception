/*                  This file is part of OpenReception
                   Copyright (C) 2014-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of openreception.resource;

/**
 * Protocol wrapper class for building homogenic REST
 * resources across servers and clients.
 */
abstract class Message {

  static String nameSpace = 'message';

  static Uri single(Uri host, int messageID)
    => Uri.parse('${Util.removeTailingSlashes(host)}/${nameSpace}/${messageID}');

  static Uri send(Uri host, int messageID)
    => Uri.parse('${Util.removeTailingSlashes(host)}/${nameSpace}/${messageID}/send');

  static Uri root(Uri host)
    => Uri.parse('${Util.removeTailingSlashes(host)}/${nameSpace}');

  static Uri list(Uri host, {Model.MessageFilter filter : null}) {
    String filterParameter = filter!=null
                                     ? '?filter=${JSON.encode(filter)}'
                                     : '';

    return Uri.parse('${Util.removeTailingSlashes(host)}/${nameSpace}/list${filterParameter}');
  }
}
