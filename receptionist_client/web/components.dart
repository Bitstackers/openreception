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

library components;

import 'dart:async';
import 'dart:html';

import 'classes/configuration.dart';
import 'classes/context.dart';
import 'classes/commands.dart' as command;
import 'classes/events.dart' as event;
import 'classes/logger.dart';
import 'classes/model.dart' as model;
import 'classes/protocol.dart' as protocol;
import 'classes/state.dart';
import 'classes/storage.dart' as storage;

part 'components/agentinfo.dart';
part 'components/boxwithheader.dart';
part 'components/companyaddresses.dart';
part 'components/companyalternatenames.dart';
part 'components/companybankinginformation.dart';
part 'components/companycustomertype.dart';
part 'components/companyemailaddresses.dart';
part 'components/companyevents.dart';
part 'components/companyhandling.dart';
part 'components/companyopeninghours.dart';
part 'components/companyother.dart';
part 'components/companyproduct.dart';
part 'components/companyregistrationnumber.dart';
part 'components/companysalescalls.dart';
part 'components/companyselector.dart';
part 'components/companytelephonenumbers.dart';
part 'components/companywebsites.dart';
part 'components/contactinfo.dart';
part 'components/contextswitcher.dart';
part 'components/globalqueue.dart';
part 'components/localqueue.dart';
part 'components/sendmessage.dart';
part 'components/welcomemessage.dart';
