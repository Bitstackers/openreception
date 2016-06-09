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

part of openreception.framework.resource;

/**
 * Protocol wrapper class for building homogenic REST
 * resources across servers and clients.
 */
abstract class Message {
  static String nameSpace = 'message';

  static Uri single(Uri host, int messageID) =>
      Uri.parse('${util.removeTailingSlashes(host)}/${nameSpace}/${messageID}');

  static Uri send(Uri host, int messageID) => Uri.parse(
      '${util.removeTailingSlashes(host)}/${nameSpace}/${messageID}/send');

  static Uri root(Uri host) =>
      Uri.parse('${util.removeTailingSlashes(host)}/${nameSpace}');

  static Uri list(Uri host, {model.MessageFilter filter: null}) {
    String filterParameter =
        filter != null ? '?filter=${JSON.encode(filter)}' : '';

    return Uri.parse(
        '${util.removeTailingSlashes(host)}/${nameSpace}/list${filterParameter}');
  }

  static Uri midOfUid(Uri host, int uid) {
    return Uri.parse('$host/message/list/by-uid/$uid');
  }

  static Uri midOfCid(Uri host, int cid) {
    return Uri.parse('$host/message/list/by-cid/$cid');
  }

  static Uri midOfRid(Uri host, int rid) {
    return Uri.parse('$host/message/list/by-rid/$rid');
  }

  static Uri listDay(Uri host, DateTime day,
      {model.MessageFilter filter: null}) {
    final String filterParameter =
        filter != null ? '?filter=${JSON.encode(filter)}' : '';

    final String dateString = day.toIso8601String().split('T').first;

    return Uri.parse('$host/message/list/$dateString${filterParameter}');
  }

  static Uri listSaved(Uri host, {model.MessageFilter filter: null}) {
    final String filterParameter =
        filter != null ? '?filter=${JSON.encode(filter)}' : '';

    return Uri.parse('$host/message/list/saved${filterParameter}');
  }

  /**
   *
   */
  static Uri changeList(Uri host, [int mid]) {
    if (mid == null) {
      return Uri.parse('$host/$nameSpace/history');
    } else {
      return Uri.parse('$host/$nameSpace/$mid/history');
    }
  }
}
