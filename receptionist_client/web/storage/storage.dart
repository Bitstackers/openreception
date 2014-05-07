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

library storage;

import 'dart:async';

import '../model/model.dart' as model;
import '../service/service.dart' as Service;


part 'storage.contact.dart';
part 'storage.reception.dart';

const libraryName = 'storage';

void debug (String message, String context) {
  print ('[STORAGE]  - $context - $message');
}