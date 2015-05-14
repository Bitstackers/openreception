/*                  This file is part of OpenReception
                   Copyright (C) 2014-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

library lang;

const String libraryName = 'lang';

abstract class Key {
  static const String agentInfoActive                 = 'agent-info-active';
  static const String agentInfoPaused                 = 'agent-info-paused';

  static const String calendarEditorCancel            = 'calendar-editor-cancel';
  static const String calendarEditorDelete            = 'calendar-editor-delete';
  static const String calendarEditorEntryDuration     = 'calendar-editor-entry-duration';
  static const String calendarEditorHeader            = 'calendar-editor-header';
  static const String calendarEditorSave              = 'calendar-editor-save';
  static const String calendarEditorStart             = 'calendar-editor-start';
  static const String calendarEditorStop              = 'calendar-editor-stop';

  static const String contactCalendarHeader           = 'contact-calendar-header';

  static const String contactDataAddInfo              = 'contact-data-add-info';
  static const String contactDataBackup               = 'contact-data-backup';
  static const String contactDataCommands             = 'contact-data-commands';
  static const String contactDataDepartment           = 'contact-data-department';
  static const String contactDataEmailAddresses       = 'contact-data-email-addresses';
  static const String contactDataHeader               = 'contact-data-header';
  static const String contactDataRelations            = 'contact-data-relations';
  static const String contactDataResponsibility       = 'contact-data-responsibility';
  static const String contactDataShowTags             = 'contact-data-show-tags';
  static const String contactDataTelephoneNumbers     = 'contact-data-telephone-numbers';
  static const String contactDataTitle                = 'contact-data-title';
  static const String contactDataWorkHours            = 'contact-data-work-hours';
  static const String contactSelectorHeader           = 'contact-selector-header';

  static const String dayMonday                       = 'day-monday';
  static const String dayTuesday                      = 'day-tuesday';
  static const String dayWednesday                    = 'day-wednesday';
  static const String dayThursday                     = 'day-thursday';
  static const String dayFriday                       = 'day-friday';
  static const String daySaturday                     = 'day-saturday';
  static const String daySunday                       = 'day-sunday';

  static const String editorNew                       = 'editor-new';
  static const String editorEditDelete                = 'editor-edit-delete';

  static const String error                           = 'error';

  static const String filter                          = 'filter';

  static const String globalCallQueueHeader           = 'global-call-queue-header';

  static const String messageArchiveEditHeader        = 'message-archive-edit-header';
  static const String messageArchiveFilterHeader      = 'message-archive-filter-header';
  static const String messageArchiveHeader            = 'message-archive-header';

  static const String messageComposeCallerName        = 'message-compose-caller-name';
  static const String messageComposeCallsBack         = 'message-compose-calls-back';
  static const String messageComposeCancel            = 'message-compose-cancel';
  static const String messageComposeCellPhone         = 'message-compose-cell-phone';
  static const String messageComposeCompanyName       = 'message-compose-company-name';
  static const String messageComposeDraft             = 'message-compose-draft';
  static const String messageComposeHeader            = 'message-compose-header';
  static const String messageComposeLocalExt          = 'message-compose-local-ext';
  static const String messageComposeMessage           = 'message-compose-message';
  static const String messageComposeNameHint          = 'message-compose-name-hint';
  static const String messageComposePleaseCall        = 'message-compose-please-call';
  static const String messageComposePhone             = 'message-compose-phone';
  static const String messageComposeSave              = 'message-compose-save';
  static const String messageComposeSend              = 'message-compose-send';
  static const String messageComposeShowRecipients    = 'message-compose-show-recipients';
  static const String messageComposeUrgent            = 'message-compose-urgent';

  static const String myQueuedCallsHeader             = 'my-queued-calls-header';

  static const String receptionAddressesHeader        = 'reception-addresses-header';
  static const String receptionAltNamesHeader         = 'reception-alt-names-header';
  static const String receptionBankInfoHeader         = 'reception-bank-info-header';
  static const String receptionCalendarHeader         = 'reception-calendar-header';
  static const String receptionCommandsHeader         = 'reception-commands-header';
  static const String receptionEmailHeader            = 'reception-email-header';
  static const String receptionMiniWikiHeader         = 'reception-mini-wiki-header';
  static const String receptionOpeningHoursHeader     = 'reception-opening-hours-header';
  static const String receptionProductHeader          = 'reception-product-header';
  static const String receptionSalesmenHeader         = 'reception-salesmen-header';
  static const String receptionSelectorHeader         = 'reception-selector-header';
  static const String receptionTelephoneNumbersHeader = 'reception-telephone-numbers-header';
  static const String receptionTypeHeader             = 'reception-type-header';
  static const String receptionVATNumbersHeader       = 'reception-vat-numbers-header';
  static const String receptionWebsitesHeader         = 'reception-websites-header';

  static const String standardGreeting                = 'standard-greeting';

  static const String stateDisasterHeader             = 'state-disaster-header';
  static const String stateLoadingHeader              = 'state-loading-header';
}

/**
 * Danish translation map.
 */
Map<String, String> da =
  {Key.agentInfoActive                : 'Aktive',
   Key.agentInfoPaused                : 'Pause',

   Key.calendarEditorCancel           : 'Annuller',
   Key.calendarEditorDelete           : 'Slet',
   Key.calendarEditorEntryDuration    : 'Varighed',
   Key.calendarEditorHeader           : 'Kalenderaftale',
   Key.calendarEditorSave             : 'Gem',
   Key.calendarEditorStart            : 'Start',
   Key.calendarEditorStop             : 'Stop',

   Key.contactCalendarHeader          : 'Kontakt kalender',

   Key.contactDataAddInfo             : 'Diverse',
   Key.contactDataBackup              : 'Backup',
   Key.contactDataCommands            : 'Kommandoer',
   Key.contactDataDepartment          : 'Afdeling',
   Key.contactDataEmailAddresses      : 'Emailadresser',
   Key.contactDataHeader              : 'Kontakt datablad',
   Key.contactDataRelations           : 'Relationer',
   Key.contactDataResponsibility      : 'Ansvarsområde',
   Key.contactDataShowTags            : 'Tags',
   Key.contactDataTelephoneNumbers    : 'Telefonnumre',
   Key.contactDataTitle               : 'Titel',
   Key.contactDataWorkHours           : 'Arbejdstider',
   Key.contactSelectorHeader          : 'Kontakter',

   Key.dayMonday                      : 'Mandag',
   Key.dayTuesday                     : 'Tirsdag',
   Key.dayWednesday                   : 'Onsdag',
   Key.dayThursday                    : 'Torsdag',
   Key.dayFriday                      : 'Fredag',
   Key.daySaturday                    : 'Lørdag',
   Key.daySunday                      : 'Søndag',

   Key.editorEditDelete               : 'ret/slet',
   Key.editorNew                      : 'ny',

   Key.error                          : 'fejl',

   Key.filter                         : 'Søg....',

   Key.globalCallQueueHeader          : 'Kø',

   Key.messageArchiveEditHeader       : 'Besked',
   Key.messageArchiveFilterHeader     : 'Besked arkiv filter',
   Key.messageArchiveHeader           : 'Besked arkiv',

   Key.messageComposeCallerName       : 'Fuldt navn',
   Key.messageComposeCallsBack        : 'Ringer selv tilbage',
   Key.messageComposeCancel           : 'Annuller',
   Key.messageComposeCellPhone        : 'Mobilnummer',
   Key.messageComposeCompanyName      : 'Virksomhed',
   Key.messageComposeDraft            : 'Kladde',
   Key.messageComposeHeader           : 'Besked',
   Key.messageComposeLocalExt         : 'Lokalnummer',
   Key.messageComposeMessage          : 'Besked...',
   Key.messageComposeNameHint         : 'Information om opkalder',
   Key.messageComposePleaseCall       : 'Ring venligst',
   Key.messageComposePhone            : 'Telefon',
   Key.messageComposeSave             : 'Gem',
   Key.messageComposeSend             : 'Send',
   Key.messageComposeShowRecipients   : 'Vis modtagere',
   Key.messageComposeUrgent           : 'Haster',

   Key.myQueuedCallsHeader            : 'Mine kald',

   Key.receptionAddressesHeader       : 'Adresser',
   Key.receptionAltNamesHeader        : 'Alternative navne',
   Key.receptionBankInfoHeader        : 'Bank',
   Key.receptionCalendarHeader        : 'Receptions Kalender',
   Key.receptionCommandsHeader        : 'Kommandoer',
   Key.receptionEmailHeader           : 'Emailadresser',
   Key.receptionMiniWikiHeader        : 'Mini wiki',
   Key.receptionOpeningHoursHeader    : 'Åbningstider',
   Key.receptionProductHeader         : 'Produkt',
   Key.receptionSalesmenHeader        : 'Sælgere',
   Key.receptionSelectorHeader        : 'Receptioner',
   Key.receptionTelephoneNumbersHeader: 'Telefonnumre',
   Key.receptionTypeHeader            : 'Receptionstype',
   Key.receptionVATNumbersHeader      : 'CVR-numre',
   Key.receptionWebsitesHeader        : 'WWW',

   Key.standardGreeting               : 'Velkommen til....',

   Key.stateDisasterHeader            : 'Vi har problemer - prøver at genstarte hvert 10 sekund',
   Key.stateLoadingHeader             : 'Hold på bits og bytes mens vi starter programmet'};

/**
 * English translation map.
 */
Map<String, String> en =
  {Key.agentInfoActive                : 'Active',
   Key.agentInfoPaused                : 'Paused',

   Key.calendarEditorCancel           : 'Cancel',
   Key.calendarEditorDelete           : 'Delete',
   Key.calendarEditorEntryDuration    : 'Duration',
   Key.calendarEditorHeader           : 'Calendar event',
   Key.calendarEditorSave             : 'Save',
   Key.calendarEditorStart            : 'Start',
   Key.calendarEditorStop             : 'Stop',

   Key.contactCalendarHeader          : 'Contact calendar',

   Key.contactDataAddInfo             : 'Miscellaneous',
   Key.contactDataBackup              : 'Backup',
   Key.contactDataCommands            : 'Commands',
   Key.contactDataDepartment          : 'Department',
   Key.contactDataEmailAddresses      : 'Email addresses',
   Key.contactDataHeader              : 'Contact data',
   Key.contactDataRelations           : 'Relations',
   Key.contactDataResponsibility      : 'Responsibility',
   Key.contactDataShowTags            : 'Tags',
   Key.contactDataTelephoneNumbers    : 'Telephone numbers',
   Key.contactDataTitle               : 'Title',
   Key.contactDataWorkHours           : 'Work hours',
   Key.contactSelectorHeader          : 'Contacts',

   Key.dayMonday                      : 'Monday',
   Key.dayTuesday                     : 'Tuesday',
   Key.dayWednesday                   : 'Wednesday',
   Key.dayThursday                    : 'Thursday',
   Key.dayFriday                      : 'Friday',
   Key.daySaturday                    : 'Saturday',
   Key.daySunday                      : 'Sunday',

   Key.editorEditDelete               : 'edit/delete',
   Key.editorNew                      : 'new',

   Key.error                          : 'error',

   Key.filter                         : 'search....',

   Key.globalCallQueueHeader          : 'Queue',

   Key.messageArchiveEditHeader       : 'Message',
   Key.messageArchiveFilterHeader     : 'Message archive filter',
   Key.messageArchiveHeader           : 'Message archive',

   Key.messageComposeCallerName       : 'Full name',
   Key.messageComposeCallsBack        : 'Will call back later',
   Key.messageComposeCancel           : 'Cancel',
   Key.messageComposeCellPhone        : 'Cell phone',
   Key.messageComposeCompanyName      : 'Company',
   Key.messageComposeDraft            : 'Draft',
   Key.messageComposeHeader           : 'Message',
   Key.messageComposeLocalExt         : 'Extension',
   Key.messageComposeMessage          : 'Message',
   Key.messageComposeNameHint         : 'Information about caller',
   Key.messageComposePleaseCall       : 'Please call',
   Key.messageComposePhone            : 'Phone',
   Key.messageComposeSave             : 'Save',
   Key.messageComposeSend             : 'Send',
   Key.messageComposeShowRecipients   : 'Show recipients',
   Key.messageComposeUrgent           : 'Urgent',

   Key.myQueuedCallsHeader            : 'My calls',

   Key.receptionAddressesHeader       : 'Addresses',
   Key.receptionAltNamesHeader        : 'Alternative names',
   Key.receptionBankInfoHeader        : 'Bank',
   Key.receptionCalendarHeader        : 'Reception Calendar',
   Key.receptionCommandsHeader        : 'Commands',
   Key.receptionEmailHeader           : 'Email addresses',
   Key.receptionMiniWikiHeader        : 'Mini wiki',
   Key.receptionOpeningHoursHeader    : 'Opening hours',
   Key.receptionProductHeader         : 'Product',
   Key.receptionSalesmenHeader        : 'Salesmen',
   Key.receptionSelectorHeader        : 'Receptions',
   Key.receptionTelephoneNumbersHeader: 'Telephone numbers',
   Key.receptionTypeHeader            : 'Reception type',
   Key.receptionVATNumbersHeader      : 'VAT numbers',
   Key.receptionWebsitesHeader        : 'WWW',

   Key.standardGreeting               : 'You\'ve called....',

   Key.stateDisasterHeader            : 'Problems discovered. Trying to recover every 10 seconds',
   Key.stateLoadingHeader             : 'Hold on to your bits while we\'re loading the application'};
