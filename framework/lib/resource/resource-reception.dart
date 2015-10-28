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
abstract class Reception {

  static String nameSpace = 'reception';

  static Uri single(Uri host, int receptionID) =>
    Uri.parse('${root(host)}/${receptionID}');

  static Uri extensionOf(Uri host, int receptionID) =>
    Uri.parse('${root(host)}/${receptionID}/extension');

  static Uri byExtension(Uri host, String extension) =>
    Uri.parse('${root(host)}/extension/${extension}');

  static Uri root(Uri host) =>
    Uri.parse('${Util.removeTailingSlashes(host)}/${nameSpace}');

  static Uri list(Uri host) =>
    Uri.parse('${root(host)}');

  static Uri calendar(Uri host, int receptionID) =>
    Uri.parse('${root(host)}/${receptionID}/calendar');

  static Uri calendarEvent(Uri host, int receptionID, int eventID) =>
    Uri.parse('${root(host)}/${receptionID}/calendar/event/${eventID}');

  static Uri subset(Uri host, int upperReceptionID, int count) =>
    Uri.parse('${list(host)}/${upperReceptionID}/limit/${count}');

  static Uri calendarEventChanges(Uri host, int eventID) =>
    Uri.parse('${Util.removeTailingSlashes(host)}/calendarentry/${eventID}/change');

  static Uri calendarEventLatestChange(Uri host, int eventID) =>
    Uri.parse('${Util.removeTailingSlashes(host)}/calendarentry/${eventID}/change/latest');
}
