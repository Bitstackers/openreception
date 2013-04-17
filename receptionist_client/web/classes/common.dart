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

/**
 * A collection of common typedefs, methods, classes and exceptions for Bob.
 */
library Common;

import 'model.dart' as model;

typedef void Subscriber(Map json);
typedef void Callback();
typedef void OrganizationSubscriber (model.Organization organization);
typedef void OrganizationListSubscriber (model.OrganizationList organizationList);
typedef void CallSubscriber (model.Call call);

class TimeoutException implements Exception {
  final String message;

  const TimeoutException(this.message);

  String toString() => message;
}

/**
 * A generic List iterator.
 *
 * Implement by extending Iterable and adding an Iterator getter:
 *
 * class Foo extends Iterable<T>{
 *   List<T> _list = new List<T>();
 *
 *   // stuff
 *
 *   Iterator get iterator => new ListIterator<T>(_list);
 * }
 *
 * Foo can now be used in for (var X in Foo) loops.
 */
class GenericListIterator<E> implements Iterator<E> {
  List<E> _container;
  E       _current;
  int     _position = -1;

  GenericListIterator(this._container);

  bool moveNext() {
    var newPosition = _position + 1;

    if (newPosition < _container.length) {
      _current = _container.elementAt(newPosition);
      _position = newPosition;

      return true;
    }

    _position = _container.length;
    _current = null;

    return false;
  }

  E get current => _current;
}
