/*                  This file is part of OpenReception
                   Copyright (C) 2016-, BitStackers

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

library orf.utilities.html;

import 'dart:html';

/// Replace ¤ with ⚙ and -> with ➔ in [elem].
void specialCharReplace(TextAreaElement elem) {
  final String orgValue = elem.value;
  final String newValue = elem.value.replaceAll('->', '➔').replaceAll('¤', '⚙');

  if (orgValue != newValue) {
    final int cursorIndex = elem.selectionStart;
    final int diffLength = orgValue.length - newValue.length;
    elem.value = newValue;
    elem.selectionStart = cursorIndex - diffLength;
    elem.selectionEnd = cursorIndex - diffLength;
  }
}
