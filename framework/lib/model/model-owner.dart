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

  /**
   *
   */
  factory Owner.parse(String buffer) {
    final key = buffer.split(':').first;
    if(key == OwningReception.type) {
      return new OwningReception(int.parse(buffer.split(':').last));
    }
    else if(key == OwningContact.type) {
      return new OwningContact(int.parse(buffer.split(':').last));
    }
    else if(key == 'none') {
      return none;
    }
  }

  const Owner();

  /**
   *
   */
  @override
  operator ==(Owner other);

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
  final int receptionId;

  static final String type = 'r';

  const OwningReception(this.receptionId);

  @override
  operator ==(OwningReception other) => this.receptionId == other.receptionId;

  /**
   *
   */
  String toJson() => toString();

  /**
   *
   */
  String toString() => '$type:$receptionId';
}

/**
 * Specialized [Owner] class that associates a [Contact] with another object.
 * For example a [CalendarEntry].
 */
class OwningContact extends Owner {
  final int contactId;
  static final String type = 'c';

  const OwningContact(this.contactId);

  @override
  operator ==(OwningContact other) => this.contactId == other.contactId;

  /**
   *
   */
  String toJson() => toString();

  /**
   *
   */
  String toString() => '$type:$contactId';
}
