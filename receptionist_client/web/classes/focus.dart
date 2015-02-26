/*                  This file is part of OpenReception
                   Copyright (C) 2012-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

library focus;

import 'constants.dart';
import 'events.dart' as event;
import 'logger.dart';

String _currentFocusId = '';
Map<String, int> _tabIndexes =
  {Id.receptionSelectorSearchbar:       1,
   'reception-events-list':             2,
   'company-handling-list':             3,
   Id.contactSelectorInput:             4,
   'contact-calendar':                  6,
   'sendmessagesearchbox':              8,
   'sendmessagesearchresult':           9,
   'sendmessagename':                  10,
   'sendmessagecompany':               11,
   'sendmessagephone':                 12,
   'sendmessagecellphone':             13,
   'sendmessagelocalno':               14,
   'sendmessagetext':                  15,
   'send-message-checkbox1':           16,
   'send-message-checkbox2':           17,
   'send-message-checkbox3':           18,
   'send-message-checkbox4':           19,
   'sendmessagecancel':                20,
   'sendmessagedraft':                 21,
   'sendmessagesend':                  22,
   Id.receptionOpeningHoursList:       25,
   Id.receptionSalesCallsList:         26,
   Id.receptionProductBody:            27,
   Id.receptionCustomerTypeBody:       28,
   'company-telephonenumbers-list':    29,
   Id.receptionAddressesList:          30,
   'company-alternate-names-list':     31,
   'company-banking-info-list':        32,
   Id.receptionEmailAddressesList:     33,
   Id.receptionWebsitesList:           34,
   'company-registration-number-list': 35,
   'company-other-body':               36,
   Id.globalCallQueueList:             37,
   'local-queue-list':                 38,

   'message-search-agent-searchbar':    1,
   'message-search-type-searchbar':     2,
   'message-search-company-searchbar':  3,
   'message-search-contact-searchbar':  4,
   'message-search-print':              5,
   'message-search-resend':             6,

   'phonebooth-company-searchbar':      1,
   'phonebooth-numberfield':            2,
   'phonebooth-button':                 3};

int getTabIndex (String id) {
  if(_tabIndexes.containsKey(id)) {
    return _tabIndexes[id];
  } else {
    log.error('Focus getTabIndex: Unknown id asked for tabIndex: ${id}');
    return -1;
  }
}

void setFocus(String newFocusId) {
  if(newFocusId != _currentFocusId) {
    var focusEvent = new Focus(_currentFocusId, newFocusId);
    _currentFocusId = newFocusId;
    event.bus.fire(event.focusChanged, focusEvent);
  }
}

class Focus{
  String _old, _current;

  String get old => _old;
  String get current => _current;

  Focus(String this._old, String this._current);
}
