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

part of keyboard;

class KeyboardShortcuts{
  Map<int, Callback> _collection = new Map<int, Callback>();

  /**
   * Adds the callback with the [key]. Overwrites if allready present.
   */
  void add(int key, Callback callback) => _collection[key] = callback;

  /**
   * Removes key if present.
   */
  void remove (int key) => _collection.remove(key);

  /**
   * Calls the callback at the [key] if present.
   */
  bool callIfPresent(int key){
    if (_collection.containsKey(key)) {
      _collection[key]();
      return true;
    }
    return false;
  }
}
