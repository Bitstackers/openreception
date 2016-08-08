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
abstract class ReceptionDialplan {
  static const String _ns = 'receptiondialplan';

  /**
   *
   */
  static Uri analyze(Uri host, String extension) =>
      Uri.parse('$host/$_ns/$extension/analyze');

  /**
   *
   */
  static Uri deploy(Uri host, String extension, int receptionId) =>
      Uri.parse('$host/$_ns/$extension/deploy/$receptionId');

  /**
   *
   */
  static Uri list(Uri host) => Uri.parse('$host/$_ns');

  /**
   *
   */
  static Uri reloadConfig(Uri host) => Uri.parse('$host/$_ns/reloadConfig');

  /**
   *
   */
  static Uri single(Uri host, String extension) =>
      Uri.parse('$host/$_ns/$extension');

  /**
   *
   */
  static Uri changeList(Uri host, [String extension]) {
    if (extension == null) {
      return Uri.parse('$host/$_ns/history');
    } else {
      return Uri.parse('$host/$_ns/$extension/history');
    }
  }

  /**
   *
   */
  static Uri changelog(Uri host, String extension) =>
      Uri.parse('$host/$_ns/$extension/changelog');
}
