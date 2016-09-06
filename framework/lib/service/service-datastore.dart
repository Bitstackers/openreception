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

part of orf.service;

/// Datastore store client-aggregation class.
///
/// The client class wraps REST methods and handles lower-level
/// communication, such as serialization/deserialization, method choice
/// (GET, PUT, POST, DELETE) and resource uri building.
class Datastore {
  final RESTContactStore contact;
  final RESTReceptionStore reception;
  final RESTCalendarStore calendar;
  final RESTUserStore user;

  factory Datastore(Uri host, String token, WebService backend) {
    final RESTContactStore contactStore =
        new RESTContactStore(host, token, backend);
    final RESTReceptionStore receptionStore =
        new RESTReceptionStore(host, token, backend);
    final RESTCalendarStore calendarStore =
        new RESTCalendarStore(host, token, backend);
    final RESTUserStore userStore = new RESTUserStore(host, token, backend);

    return new Datastore._(
        contactStore, receptionStore, calendarStore, userStore);
  }

  Datastore._(this.contact, this.reception, this.calendar, this.user);
}
