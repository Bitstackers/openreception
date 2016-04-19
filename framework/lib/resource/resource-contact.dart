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
abstract class Contact {
  static String nameSpace = 'contact';

  /**
   *
   */
  static Uri single(Uri host, int cid) => Uri.parse('${root(host)}/${cid}');

  /**
   *
   */
  static Uri root(Uri host) =>
      Uri.parse('${Util.removeTailingSlashes(host)}/${nameSpace}');

  /**
   *
   */
  static Uri list(Uri host) => Uri.parse('${root(host)}');

  /**
   *
   */
  static Uri singleByReception(Uri host, int cid, int rid) =>
      Uri.parse('${root(host)}/${cid}/reception/${rid}');

  /**
   *
   */
  static Uri listByReception(Uri host, int rid) =>
      Uri.parse('${root(host)}/list/reception/${rid}');

  /**
   *
   */
  static Uri receptions(Uri host, int rid) =>
      Uri.parse('${root(host)}/${rid}/reception');

  /**
   *
   */
  static Uri organizations(Uri host, int cid) =>
      Uri.parse('${root(host)}/${cid}/organization');

  /**
   *
   */
  static Uri colleagues(Uri host, int cid) =>
      Uri.parse('${root(host)}/${cid}/colleagues');

  /**
   *
   */
  static Uri organizationContacts(Uri host, int oid) =>
      Uri.parse('$host/contact/organization/${oid}');

  /**
   *
   */
  static Uri change(Uri host, [int cid, int rid]) {
    if (cid == null) {
      return Uri.parse('$host/contact/history');
    } else {
      if (rid == null) {
        return Uri.parse('$host/contact/${cid}/history');
      } else {
        return Uri.parse('$host/contact/${cid}/reception/${rid}/history');
      }
    }
  }
}
