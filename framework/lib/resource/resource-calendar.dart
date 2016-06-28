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
abstract class Calendar {
  /**
   *
   */
  static Uri ownerBase(Uri host, model.Owner owner) =>
      Uri.parse('$host/calendar/${owner.toJson()}');

  /**
   *
   */
  static Uri single(Uri host, int eid, model.Owner owner) =>
      Uri.parse('$host/calendar/${owner.toJson()}/${eid}');

  /**
   *
   */
  static Uri changeList(Uri host, model.Owner owner, [int eid]) {
    if (eid == null) {
      return Uri.parse('${host}/calendar/${owner.toJson()}/change');
    } else {
      return Uri.parse('${host}/calendar/${owner.toJson()}/${eid}/change');
    }
  }

  /**
   *
   */
  static Uri changelog(Uri host, model.Owner owner) =>
      Uri.parse('${host}/calendar/${owner.toJson()}/changelog');
}
