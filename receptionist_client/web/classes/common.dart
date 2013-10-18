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

library Common;

import 'dart:async';

/**
 * A simple timeout exception. MUST be used wherever we throw exceptions due
 * to timeout issues.
 */
class TimeoutException implements Exception {
  final String message;

  const TimeoutException(this.message);

  String toString() => message;
}

typedef bool boolFunc ();

/**
 * Repeats asking [check] every [repeatTime], at a maximum of [maxRepeat] times, if not [maxRepeat] is zero.
 * If [maxRepeat] is exceded then a [TimeoutException] is raised with [timeoutMessage].
 */
Future<bool> repeatCheck(boolFunc check, int maxRepeat, Duration repeatTime, {String timeoutMessage}) {
  assert(maxRepeat != null);
  assert(maxRepeat >= 0);
  assert(repeatTime.inMilliseconds > 0);

  final Completer completer = new Completer();
        int       count     = 0;

  if (check()) {
    completer.complete(true);
  } else {
    new Timer.periodic(repeatTime, (timer) {
      count += 1;
      if (check()) {
        timer.cancel();
        completer.complete(true);
      } else if (count > maxRepeat && maxRepeat != 0) {
        timer.cancel();
        completer.completeError(new TimeoutException(timeoutMessage));
      }
    });
  }

  return completer.future;
}

/**
 * Iterator for [Map].
 */
class MapIterator<T_Key, T_Value> extends Iterator<T_Value> {
  Iterator<T_Key> keys;
  Map<T_Key, T_Value> map;

  MapIterator(this.map) {
    keys = map.keys.iterator;
  }

  /**
   * Returns the current element.
   * Return null if the iterator has not yet been moved to the first element,
   * or if the iterator has been moved after the last element of the Iterable.
   */
  T_Value get current {
    if (keys.current != null) {
      return map[keys.current];
    }
    return null;
  }

  /**
   * Moves to the next element. Returns true if current contains the next element.
   * Returns false, if no element was left.
   * It is safe to invoke moveNext even when the iterator is already positioned
   * after the last element. In this case moveNext has no effect.
   */
  bool moveNext() {
    return keys.moveNext();
  }
}

/**
 * Applies external css styling to Polymer component.
 */
class ApplyAuthorStyle {
  bool get applyAuthorStyles => true;
}
