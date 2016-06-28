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
abstract class Reception {
  static const String _ns = 'reception';

  /**
   *
   */
  static Uri single(Uri host, int rid) => Uri.parse('${root(host)}/${rid}');

  /**
   *
   */
  static Uri extensionOf(Uri host, int rid) =>
      Uri.parse('${root(host)}/${rid}/extension');

  /**
   *
   */
  static Uri byExtension(Uri host, String extension) =>
      Uri.parse('${root(host)}/extension/${extension}');

  /**
   *
   */
  static Uri root(Uri host) =>
      Uri.parse('${util.removeTailingSlashes(host)}/${_ns}');

  /**
   * 
   */
  static Uri list(Uri host) => Uri.parse('${root(host)}');

  /**
   *
   */
  static Uri changeList(Uri host, [int rid]) {
    if (rid == null) {
      return Uri.parse('$host/reception/history');
    } else {
      return Uri.parse('$host/reception/$rid/history');
    }
  }

  /**
   *
   */
  static Uri changelog(Uri host, int rid) =>
      Uri.parse('${host}/$_ns/${rid}/changelog');
}
