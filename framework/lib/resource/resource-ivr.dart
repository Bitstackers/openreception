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
abstract class Ivr {
  static const String _ns = 'ivr';

  /**
   *
   */
  static Uri list(Uri host) => Uri.parse('$host/$_ns');

  /**
   *
   */
  static Uri single(Uri host, String menuName) =>
      Uri.parse('$host/$_ns/$menuName');

  /**
   *
   */
  static Uri deploy(Uri host, String menuName) =>
      Uri.parse('$host/$_ns/$menuName/deploy');

  /**
   *
   */
  static Uri changeList(Uri host, [String menuName]) {
    if (menuName == null) {
      return Uri.parse('$host/$_ns/history');
    } else {
      return Uri.parse('$host/$_ns/$menuName/history');
    }
  }

  /**
   *
   */
  static Uri changelog(Uri host, String menuName) =>
      Uri.parse('$host/$_ns/$menuName/changelog');
}
