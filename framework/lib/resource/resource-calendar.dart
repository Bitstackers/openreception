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
abstract class Calendar {
  static Uri list(Uri host, Model.Owner owner) =>
      Uri.parse('$host/calendar/${owner.toJson()}');

  static Uri base(Uri host) => Uri.parse('$host/calendarentry');

  static Uri single(Uri host, int eid) =>
      Uri.parse('$host/calendarentry/${eid}');

  static Uri purge(Uri host, int entryId) =>
      Uri.parse('$host/calendarentry/${entryId}/purge');

  /**
   *
   */
  static Uri changeList(Uri host, Model.Owner owner, [int eid]) {
    if (eid == null) {
      return Uri.parse('${host}/calendar/${owner.toJson()}/change');
    } else {
      return Uri
          .parse('${host}/calendarentry/$eid/owner/${owner.toJson()}/change');
    }
  }
}
