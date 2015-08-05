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

  static Uri single(Uri host, int ContactID) =>
      Uri.parse('${root(host)}/${ContactID}');

  static Uri root(Uri host) =>
      Uri.parse('${Util.removeTailingSlashes(host)}/${nameSpace}');

  static Uri list(Uri host) =>
      Uri.parse('${root(host)}');

  static Uri singleByReception(Uri host, int contactID, int receptionID)
    => Uri.parse('${root(host)}/${contactID}/reception/${receptionID}');

  static Uri listByReception(Uri host, int receptionID)
    => Uri.parse('${root(host)}/list/reception/${receptionID}');

  static Uri receptions(Uri host, int contactID)
    => Uri.parse('${root(host)}/${contactID}/reception');

  static Uri organizations(Uri host, int contactID)
    => Uri.parse('${root(host)}/${contactID}/organization');

  static Uri managementServerList(Uri host, int receptionID)
    => Uri.parse('$host/reception/${receptionID}/contact');

  static Uri calendar(Uri host, int contactID, int receptionID) =>
    Uri.parse('${singleByReception(host, contactID, receptionID)}/calendar');

  static Uri calendarEvent(Uri host, int contactID, int receptionID, int eventID) =>
    Uri.parse('${singleByReception(host, contactID, receptionID)}/calendar/event/${eventID}');

  static Uri calendarEventChanges(Uri host, int eventID) =>
    Uri.parse('${Util.removeTailingSlashes(host)}/calendarentry/${eventID}/change');

  static Uri calendarEventLatestChange(Uri host, int eventID) =>
    Uri.parse('${Util.removeTailingSlashes(host)}/calendarentry/${eventID}/change/latest');

  static Uri endpoints(Uri host, int contactID, int receptionID) =>
    Uri.parse('${singleByReception(host, contactID, receptionID)}/endpoints');

  static Uri phones(Uri host, int contactID, int receptionID) =>
    Uri.parse('${singleByReception(host, contactID, receptionID)}/phones');
}
