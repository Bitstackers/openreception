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

  static Uri listContact(Uri host, int contactId, int receptionId) =>
    Uri.parse('${Contact.singleByReception(host, contactId, receptionId)}/calendar');

  static Uri  listReception(Uri host, int receptionId) =>
      Uri.parse('${Reception.single(host, receptionId)}/calendar');

  static Uri single(Uri host, int entryId) =>
    Uri.parse('$host/calendar/entry/${entryId}');

  static Uri singleContact(Uri host, int entryId, int rid, int cid) =>
    Uri.parse('$host/contact/${cid}/reception/${rid}/calendar/event/${entryId}');

  static Uri singleReception(Uri host, int entryId, int rid) =>
    Uri.parse('$host/reception/${rid}/calendar/event/${entryId}');

  static Uri changeList(Uri host, int eventID) =>
    Uri.parse('${host}/calendarentry/${eventID}/change');

  static Uri latestChange(Uri host, int eventID) =>
    Uri.parse('${host}/calendarentry/${eventID}/change/latest');
}
