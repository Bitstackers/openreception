/*                  This file is part of OpenReception
                   Copyright (C) 2015-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of model;

abstract class CalendarEntry extends ORModel.CalendarEntry {
  static int get noID => ORModel.CalendarEntry.noID;

  CalendarEntry.fromMap(Map map) : super.fromMap(map);

  CalendarEntry.empty();

  CalendarEntry.forContact (int contactID, int receptionID) :
    super.forContact(contactID, receptionID);

  CalendarEntry.forReception (int receptionID) :
    super.forReception(receptionID);
}
