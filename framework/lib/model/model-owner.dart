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
part of openreception.model;

/**
 * Model super-class representing an owner. Direct instances of this class
 * represents no owner, as it has no link to other object types.
 */
class Owner {
  static final Owner none = const Owner();
  static String type = 'none';
  final int id = 0;

  /**
   *
   */
  factory Owner.parse(String buffer) {
    final key = buffer.split(':').first;
    if (key == OwningReception.type) {
      return new OwningReception(int.parse(buffer.split(':').last));
    } else if (key == OwningContact.type) {
      return new OwningContact(int.parse(buffer.split(':').last));
    } else if (key == Owner.type) {
      return none;
    }
  }

  /**
   *
   */
  bool operator ==(Owner other) => id == other.id;

  /**
   *
   */
  const Owner();

  /**
   *
   */
  String toJson() => toString();

  /**
   *
   */
  String toString() => 'none:';
}

/**
 * Specialized [Owner] class that associates a [Reception] with another object.
 * For example a [CalendarEntry].
 */
class OwningReception extends Owner {
  final int id;

  static final String type = 'r';

  const OwningReception(this.id);

  @override
  bool operator ==(OwningReception other) => this.id == other.id;

  /**
   *
   */
  String toJson() => toString();

  /**
   *
   */
  String toString() => '$type:$id';
}

/**
 * Specialized [Owner] class that associates a [ReceptionAttributes] with another object.
 * For example a [CalendarEntry].
 */
class OwningContact extends Owner {
  final int id;
  static final String type = 'c';

  const OwningContact(this.id);

  /**
   *
   */
  String toJson() => toString();

  /**
   *
   */
  String toString() => '$type:$id';
}
