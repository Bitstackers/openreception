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

final MiniboxList nullMiniboxList = new MiniboxList._null();

/**
 * A list of [MiniboxListItem] objects.
 */
class MiniboxList extends IterableBase<MiniboxListItem>{
  List<MiniboxListItem> _list = <MiniboxListItem>[];

  Iterator<MiniboxListItem> get iterator => _list.iterator;

  /**
   * [MiniboxList] constructor. Builds a list of [MiniboxListItem] objects from
   * the contents of json[key].
   */
  MiniboxList.fromJson(Map json, String key) {
    if (json.containsKey(key)) {
      json[key].forEach((item) => _list.add(new MiniboxListItem.fromJson(item)));
      _list.sort();
    }
  }

  /**
   * [MiniboxList] null constructor.
   */
  MiniboxList._null();
}
