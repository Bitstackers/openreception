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

final MiniboxList nullMiniboxList = new MiniboxList._null();

class MiniboxList extends IterableBase<MiniboxListItem>{
  List<MiniboxListItem> _list = <MiniboxListItem>[];

  MiniboxList(List list) {
    list.forEach((json) => _list.add(new MiniboxListItem.fromJson(json)));
    _list.sort();
  }

  MiniboxList._null();

  Iterator<MiniboxListItem> get iterator => _list.iterator;
}
