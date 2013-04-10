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
class Call{
  Map _call;
  Map get content => _call;

  int id;
  /**
   * TODO comment
   */
  Call(Map json) {
    _call = json;

    //TODO Parsing should not be necessary when the json is stabile.
    id = int.parse(json['id']);
  }

  Call._null() {
    _call = null;
  }

  String toString() => _call.toString();
}
