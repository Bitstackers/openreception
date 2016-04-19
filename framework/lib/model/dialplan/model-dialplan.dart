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

library openreception.model.dialplan;

import 'keys.dart' as Key;
import 'parsing_utils.dart';

part 'model-action.dart';
part 'model-enqueue.dart';
part 'model-extension.dart';
part 'model-hour_action.dart';
part 'model-ivr.dart';
part 'model-ivr_entry.dart';
part 'model-ivr_menu.dart';
part 'model-ivr_reception_transfer.dart';
part 'model-ivr_submenu.dart';
part 'model-ivr_topmenu.dart';
part 'model-ivr_transfer.dart';
part 'model-ivr_voicemail.dart';
part 'model-notify.dart';
part 'model-opening_hour.dart';
part 'model-reception_dialplan.dart';
part 'model-reception_transfer.dart';
part 'model-playback.dart';
part 'model-ringtone.dart';
part 'model-transfer.dart';
part 'model-voicemail.dart';

const String libaryName = 'model.dialplan';
