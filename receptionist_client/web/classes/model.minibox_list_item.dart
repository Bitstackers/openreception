/*                     This file is part of Bob
                   Copyright (C) 2012-, AdaHeads K/S

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

/**
 * A MiniboxListItem consists of a String [value] and an int [priority]. In the
 * case of the [priority] 1 is considered more important than 2.
 */
class MiniboxListItem implements Comparable{
  int    priority;
  String value;

  /**
   * MiniboxListItem constructor. Expects a map with the following format:
   *
   *  {
   *    'priority' : int,
   *    'value'    : String
   *  }
   *  
   *  If the priority field is missing, a priority of 0 is assumed. 
   *
   */
  MiniboxListItem.fromJson(Map json) {
    this.value = json['value'];
    this.priority = json['priority'];
    
    if (this.priority == null) {
      this.priority = 0;
    }
  }

  /**
   * Enables a [MiniboxListItem] to sort itself compared to other items.
   */
  int compareTo(MiniboxListItem other) => priority - other.priority;

  /**
   * [MiniboxListItem] as String, for debug/log purposes.
   */
  String toString() => value;
}