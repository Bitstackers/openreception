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
 * This is a library ontainening all the storage classes.
 */
library storage;

import 'dart:async';
import 'dart:uri';
import 'dart:html';
import 'dart:json' as json;

import 'common.dart';
import 'configuration.dart';
import 'logger.dart';
import 'model.dart';
import 'protocol.dart' as protocol;

part 'storage.organization.dart';
part 'storage.organization_list.dart';
