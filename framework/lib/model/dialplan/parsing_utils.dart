/*                  This file is part of OpenReception
                   Copyright (C) 2015-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

library openreception.framework.model.dialplan.parsing_utils;

///'Tuple' class for returning an identifier consumed from a buffer and
/// the remaining buffer.
class _ConsumedIdenBuf {
  final String buffer;
  final String iden;

  const _ConsumedIdenBuf(this.iden, this.buffer);
}

/// 'Tuple' class for returning a comment consumed from a buffer and the
/// remaining buffer.
class _ConsumedCommentBuf {
  final String buffer;
  final String comment;

  const _ConsumedCommentBuf(this.comment, this.buffer);
}

/// Consume the next word up until next space from [buffer].
_ConsumedIdenBuf consumeWord(String buffer) {
  buffer = buffer.trimLeft();
  final nextTerm =
      buffer.indexOf(' ') > 0 ? buffer.indexOf(' ') : buffer.length;

  return new _ConsumedIdenBuf(
      buffer.substring(0, nextTerm), buffer.substring(nextTerm, buffer.length));
}

/// Consume the next comment from [buffer] up until ')' or [buffer] ends.
_ConsumedCommentBuf consumeComment(String buffer) {
  buffer = buffer.trimLeft();

  if (buffer.isEmpty) return new _ConsumedCommentBuf('', '');

  if (!buffer.startsWith('(')) {
    throw new FormatException('Buffer expected to start with a (', '"$buffer"');
  } else if (buffer.length < 2) {
    return new _ConsumedCommentBuf('', '');
  }
  final int parRight =
      buffer.indexOf(')') > 0 ? buffer.indexOf(')') : buffer.length;

  return new _ConsumedCommentBuf(
      buffer.substring(1, parRight), buffer.substring(parRight, buffer.length));
}

/// Consumes the occurence of [key] from the start of [buffer] and returns
/// the buffer again with the [key] removed.
///
/// Throws [FormatException] if the buffer does not contain the key in
/// the beginning.
String consumeKey(String buffer, String key) => (!buffer
        .trimLeft()
        .substring(0, key.length)
        .toLowerCase()
        .startsWith(key.toLowerCase())
    ? throw new FormatException(
        'Tried to parse a non-$key '
        'action as a $key',
        buffer)
    : buffer.substring(key.length));
