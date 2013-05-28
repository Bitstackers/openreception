/*                                Bob
                   Copyright (C) 2012-, AdaHeads K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This library is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License and
  a copy of the GCC Runtime Library Exception along with this program;
  see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see
  <http://www.gnu.org/licenses/>.
*/

part of model;

final Call nullCall = new Call._null();

/**
 * TODO comment, write this when the class have more to it, then a simple map.
 */
class Call implements Comparable {
  Map _call;

  int id = -1;
  DateTime start;

  Map get content => _call;

  /**
   * TODO comment
   */
  Call(Map json) {
    _call = json;

    //TODO Parsing should not be necessary when the json is stabile.
    id = int.parse(json['id']);
    start = DateTime.parse(json['start']);
  }

  Call._null() {
    _call = null;
    start = new DateTime.now();
  }

  int compareTo(Call other) => start.compareTo(other.start);

  String toString() => _call.toString();
}
