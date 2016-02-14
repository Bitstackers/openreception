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
  static const String actions = 'actions';
  static const String active = 'active';
  static const String agent = 'agent';

  static const String calendarEditorDelErrorTitle = 'calendar-editor-del-error';
  static const String calendarEditorDelSuccessTitle = 'calendar-editor-del-success';
  static const String calendarEditorHeader = 'calendar-editor-header';
  static const String calendarEditorSaveErrorTitle = 'calendar-editor-save-error';
  static const String calendarEditorSaveSuccessTitle = 'calendar-editor-save-success';

  static const String callFailed = 'call-failed';

  /// NOTE: The callState... strings are special in that their usage cannot be
  /// grep'ed in the source. They are used in the call queue widgets.
  static const String callStateCreated = 'callstate-created';
  static const String callStateHungup = 'callstate-hungup';
  static const String callStateInbound = 'callstate-inbound';
  static const String callStateOutbound = 'callstate-outbound';
  static const String callStateParked = 'callstate-parked';
  static const String callStateQueued = 'callstate-queued';
  static const String callStateRinging = 'callstate-ringing';
  static const String callStateSpeaking = 'callstate-speaking';
  static const String callStateTransferred = 'callstate-transferred';
  static const String callStateTransferring = 'callstate-transferring';
  static const String callStateUnknown = 'callstate-unknown';
  static const String callStateUnparked = 'callstate-unparked';

  static const String cancel = 'cancel';
  static const String cellPhone = 'cell-phone';
  static const String close = 'close';
  static const String closed = 'closed';
  static const String company = 'company';

  static const String contactCalendarHeader = 'contact-calendar-header';
  static const String contactDataAddInfo = 'contact-data-add-info';
  static const String contactDataBackup = 'contact-data-backup';
  static const String contactDataCommands = 'contact-data-commands';
  static const String contactDataDepartment = 'contact-data-department';
  static const String contactDataEmailAddresses = 'contact-data-email-addresses';
  static const String contactDataHeader = 'contact-data-header';
  static const String contactDataPSTN = 'contact-data-pstn';
  static const String contactDataRelations = 'contact-data-relations';
  static const String contactDataResponsibility = 'contact-data-responsibility';
  static const String contactDataShowPSTN = 'contact-data-show-pstn';
  static const String contactDataShowTags = 'contact-data-show-tags';
  static const String contactDataTelephoneNumbers = 'contact-data-telephone-numbers';
  static const String contactDataTitle = 'contact-data-title';
  static const String contactDataWorkHours = 'contact-data-work-hours';
  static const String contactSelectorHeader = 'contact-selector-header';

  static const String copy = 'copy';

  static const String date = 'date';
  static const String dayMonday = 'day-monday';
  static const String dayTuesday = 'day-tuesday';
  static const String dayWednesday = 'day-wednesday';
  static const String dayThursday = 'day-thursday';
  static const String dayFriday = 'day-friday';
  static const String daySaturday = 'day-saturday';
  static const String daySunday = 'day-sunday';
  static const String delete = 'delete';
  static const String duration = 'duration';

  static const String editDelete = 'edit-delete';
  static const String editorNew = 'editor-new';
  static const String error = 'error';
  static const String errorCallControllerBusy = 'error-call-controller-busy';
  static const String errorCallHangup = 'error-call-hangup';
  static const String errorCallNotFound = 'error-call-not-found';
  static const String errorCallNotFoundExtended = 'error-call-not-found-extended';
  static const String errorCallPark = 'error-call-park';
  static const String errorCallTransfer = 'error-call-transfer';
  static const String errorCallUnpark = 'error-call-unpark';
  static const String errorSystem = 'error-system';
  static const String extension = 'extension';

  static const String filter = 'filter';

  static const String globalCallQueueHeader = 'global-call-queue-header';

  static const String message = 'message';
  static const String messageArchiveContact = 'message-archive-contact';
  static const String messageArchiveHeader = 'message-archive-header';
  static const String messageCloseErrorTitle = 'message-close-error';
  static const String messageCloseSuccessTitle = 'message-close-success';
  static const String messageComposeCallerName = 'message-compose-caller-name';
  static const String messageComposeCallsBack = 'message-compose-calls-back';
  static const String messageComposeCellPhone = 'message-compose-cell-phone';
  static const String messageComposeCompanyName = 'message-compose-company-name';
  static const String messageComposeHaveCalled = 'message-compose-have-called';
  static const String messageComposeHeader = 'message-compose-header';
  static const String messageComposeLocalExt = 'message-compose-local-ext';
  static const String messageComposeMessage = 'message-compose-message';
  static const String messageComposeNameHint = 'message-compose-name-hint';
  static const String messageComposePleaseCall = 'message-compose-please-call';
  static const String messageComposePhone = 'message-compose-phone';
  static const String messageComposeShowRecipients = 'message-compose-show-recipients';
  static const String messageComposeShowNoRecipients = 'message-compose-show-no-recipients';
  static const String messageComposeUrgent = 'message-compose-urgent';
  static const String messageDeleteErrorTitle = 'message-delete-error';
  static const String messageDeleteSuccessTitle = 'message-delete-success';
  static const String messageSaveErrorTitle = 'message-save-error';
  static const String messageSaveSuccessTitle = 'message-save-success';
  static const String messageSaveSendErrorTitle = 'message-save-send-error';
  static const String messageSaveSendSuccessTitle = 'message-save-send-success';
  static const String myQueuedCallsHeader = 'my-queued-calls-header';

  static const String name = 'name';
  static const String no = 'no';

  static const String paused = 'paused';
  static const String phone = 'phone';

  static const String queued = 'queued';

  static const String reception = 'reception';
  static const String receptionAddressesHeader = 'reception-addresses-header';
  static const String receptionAltNamesHeader = 'reception-alt-names-header';
  static const String receptionBankInfoHeader = 'reception-bank-info-header';
  static const String receptionCalendarHeader = 'reception-calendar-header';
  static const String receptionCommandsHeader = 'reception-commands-header';
  static const String receptionChanged = 'reception-changed';
  static const String receptionEmailHeader = 'reception-email-header';
  static const String receptionMiniWikiHeader = 'reception-mini-wiki-header';
  static const String receptionOpeningHoursHeader = 'reception-opening-hours-header';
  static const String receptionProductHeader = 'reception-product-header';
  static const String receptionSalesmenHeader = 'reception-salesmen-header';
  static const String receptionSelectorHeader = 'reception-selector-header';
  static const String receptionTelephoneNumbersHeader = 'reception-telephone-numbers-header';
  static const String receptionTypeHeader = 'reception-type-header';
  static const String receptionVATNumbersHeader = 'reception-vat-numbers-header';
  static const String receptionWebsitesHeader = 'reception-websites-header';

  static const String save = 'save';
  static const String saved = 'saved';
  static const String send = 'send';
  static const String sent = 'sent';
  static const String standardGreeting = 'standard-greeting';
  static const String start = 'start';
  static const String stateDisasterHeader = 'state-disaster-header';
  static const String stateLoadingHeader = 'state-loading-header';
  static const String status = 'status';
  static const String stop = 'stop';

  static const String unknown = 'unknown';

  static const String yes = 'yes';
}

/**
 * Danish translation map.
 */
Map<String, String> da = {
  Key.actions: 'Handlinger',
  Key.active: 'Aktive',
  Key.agent: 'Agent',

  Key.calendarEditorDelErrorTitle: 'Kalenderaftalen blev ikke slettet',
  Key.calendarEditorDelSuccessTitle: 'Kalenderaftalen blev slettet',
  Key.calendarEditorHeader: 'Kalenderaftale',
  Key.calendarEditorSaveErrorTitle: 'Kalenderaftalen blev ikke gemt',
  Key.calendarEditorSaveSuccessTitle: 'Kalenderaftalen blev gemt',

  Key.callFailed: 'Opkald fejlede',

  /// NOTE: The callState... strings are special in that their usage cannot be
  /// grep'ed in the source. They are used in the call queue widgets.
  Key.callStateCreated: 'Oprettet',
  Key.callStateHungup: 'Lagt på',
  Key.callStateInbound: 'Indgående',
  Key.callStateOutbound: 'Udgående',
  Key.callStateParked: 'Parkeret',
  Key.callStateQueued: 'I kø',
  Key.callStateRinging: 'Ringer',
  Key.callStateSpeaking: 'Taler',
  Key.callStateTransferred: 'Overført',
  Key.callStateTransferring: 'Overfører',
  Key.callStateUnknown: 'Ukendt',
  Key.callStateUnparked: 'Ikke parkeret',

  Key.cancel: 'Annuller',
  Key.cellPhone: 'Mobilnummer',
  Key.close: 'Luk',
  Key.closed: 'Lukket',
  Key.company: 'Virksomhed',

  Key.contactCalendarHeader: 'Kontaktkalender',
  Key.contactDataAddInfo: 'Diverse',
  Key.contactDataBackup: 'Backup',
  Key.contactDataCommands: 'Kommandoer',
  Key.contactDataDepartment: 'Afdeling',
  Key.contactDataEmailAddresses: 'Emailadresser',
  Key.contactDataHeader: 'Kontaktdatablad',
  Key.contactDataPSTN: 'nummer',
  Key.contactDataRelations: 'Relationer',
  Key.contactDataResponsibility: 'Ansvarsområde',
  Key.contactDataShowPSTN: 'PSTN',
  Key.contactDataShowTags: 'Tags',
  Key.contactDataTelephoneNumbers: 'Telefonnumre',
  Key.contactDataTitle: 'Titel',
  Key.contactDataWorkHours: 'Arbejdstider',
  Key.contactSelectorHeader: 'Kontakter',

  Key.copy: 'Kopier',

  Key.date: 'Dato',
  Key.dayMonday: 'Mandag',
  Key.dayTuesday: 'Tirsdag',
  Key.dayWednesday: 'Onsdag',
  Key.dayThursday: 'Torsdag',
  Key.dayFriday: 'Fredag',
  Key.daySaturday: 'Lørdag',
  Key.daySunday: 'Søndag',
  Key.delete: 'Slet',
  Key.duration: 'Varighed',

  Key.editDelete: 'ret/slet',
  Key.editorNew: 'ny',
  Key.error: 'fejl',
  Key.errorCallControllerBusy: 'Kaldhåndtering midlertidigt optaget',
  Key.errorCallHangup: 'Kaldet kunne ikke afbrydes',
  Key.errorCallNotFound: 'Kald ikke fundet',
  Key.errorCallNotFoundExtended: 'Det anmodede kald kunne ikke besvares',
  Key.errorCallPark: 'Kaldparkering fejlede',
  Key.errorCallTransfer: 'Viderestilling fejlede',
  Key.errorCallUnpark: 'Parkeret kald kunne ikke aktiveres',
  Key.errorSystem: 'Systemfejl',
  Key.extension: 'Lokalnummer',

  Key.filter: 'filter...',

  Key.globalCallQueueHeader: 'Kø',

  Key.message: 'Besked',
  Key.messageArchiveContact: 'Modtager',
  Key.messageArchiveHeader: 'Besked arkiv',
  Key.messageCloseErrorTitle: 'Beskeden blev ikke lukket',
  Key.messageCloseSuccessTitle: 'Beskeden blev lukket',
  Key.messageComposeCallerName: 'Fuldt navn',
  Key.messageComposeCallsBack: 'Ringer selv tilbage',
  Key.messageComposeCellPhone: 'Mobilnummer',
  Key.messageComposeCompanyName: 'Virksomhed',
  Key.messageComposeHaveCalled: 'Har ringet',
  Key.messageComposeHeader: 'Besked',
  Key.messageComposeLocalExt: 'Lokalnummer',
  Key.messageComposeMessage: 'Besked...',
  Key.messageComposeNameHint: 'Information om opkalder',
  Key.messageComposePleaseCall: 'Ring venligst',
  Key.messageComposePhone: 'Telefon',
  Key.messageComposeShowRecipients: 'Vis modtagere',
  Key.messageComposeShowNoRecipients: 'Ingen modtagere',
  Key.messageComposeUrgent: 'Haster',
  Key.messageDeleteErrorTitle: 'Beskeden blev ikke slettet',
  Key.messageDeleteSuccessTitle: 'Beskeden blev slettet',
  Key.messageSaveErrorTitle: 'Beskeden blev ikke gemt',
  Key.messageSaveSuccessTitle: 'Beskeden blev gemt',
  Key.messageSaveSendErrorTitle: 'Beskeden blev ikke sendt',
  Key.messageSaveSendSuccessTitle: 'Beskeden blev sendt',
  Key.myQueuedCallsHeader: 'Mine kald',

  Key.name: 'Navn',
  Key.no: 'Nej',

  Key.paused: 'Pause',
  Key.phone: 'Telefon',

  Key.queued: 'I kø',

  Key.reception: 'Reception',
  Key.receptionAddressesHeader: 'Adresser',
  Key.receptionAltNamesHeader: 'Alternative navne',
  Key.receptionBankInfoHeader: 'Bank',
  Key.receptionCalendarHeader: 'ReceptionsKalender',
  Key.receptionCommandsHeader: 'Kommandoer',
  Key.receptionChanged: 'Henter ny receptionsliste ved næste kaldbesvarelse',
  Key.receptionEmailHeader: 'Emailadresser',
  Key.receptionMiniWikiHeader: 'Mini wiki',
  Key.receptionOpeningHoursHeader: 'Åbningstider',
  Key.receptionProductHeader: 'Produkt',
  Key.receptionSalesmenHeader: 'Sælgere',
  Key.receptionSelectorHeader: 'Receptioner',
  Key.receptionTelephoneNumbersHeader: 'Telefonnumre',
  Key.receptionTypeHeader: 'Receptionstype',
  Key.receptionVATNumbersHeader: 'CVR-numre',
  Key.receptionWebsitesHeader: 'WWW',

  Key.save: 'Gem',
  Key.saved: 'Gemt',
  Key.send: 'Send',
  Key.sent: 'Sendt',
  Key.standardGreeting: 'Velkommen til....',
  Key.start: 'Start',
  Key.stateDisasterHeader: 'Vi har problemer - prøver at genstarte hvert 10. sekund',
  Key.stateLoadingHeader: 'Hold på bits og bytes mens vi starter programmet',
  Key.status: 'Status',
  Key.stop: 'Stop',

  Key.unknown: 'Ukendt',

  Key.yes: 'Ja'
};

/**
 * English translation map.
 */
Map<String, String> en = {
  Key.actions: 'Actions',
  Key.active: 'Active',
  Key.agent: 'Agent',

  Key.calendarEditorDelErrorTitle: 'Calendar entry not deleted',
  Key.calendarEditorDelSuccessTitle: 'Calendar entry deleted',
  Key.calendarEditorHeader: 'Calendar event',
  Key.calendarEditorSaveErrorTitle: 'Calendar entry not saved',
  Key.calendarEditorSaveSuccessTitle: 'Calendar entry saved',

  Key.callFailed: 'Call failed',

  /// NOTE: The callState... strings are special in that their usage cannot be
  /// grep'ed in the source. They are used in the call queue widgets.
  Key.callStateCreated: 'Created',
  Key.callStateHungup: 'Hungup',
  Key.callStateInbound: 'Inbound',
  Key.callStateOutbound: 'Outbound',
  Key.callStateParked: 'Parked',
  Key.callStateQueued: 'Queued',
  Key.callStateRinging: 'Ringing',
  Key.callStateSpeaking: 'Speaking',
  Key.callStateTransferred: 'Transferred',
  Key.callStateTransferring: 'Transferring',
  Key.callStateUnknown: 'Unknown',
  Key.callStateUnparked: 'Unparked',

  Key.cancel: 'Cancel',
  Key.cellPhone: 'Cell phone',
  Key.close: 'Close',
  Key.closed: 'Closed',
  Key.company: 'Company',

  Key.contactCalendarHeader: 'Contact calendar',
  Key.contactDataAddInfo: 'Miscellaneous',
  Key.contactDataBackup: 'Backup',
  Key.contactDataCommands: 'Commands',
  Key.contactDataDepartment: 'Department',
  Key.contactDataEmailAddresses: 'Email addresses',
  Key.contactDataHeader: 'Contact data',
  Key.contactDataPSTN: 'number',
  Key.contactDataRelations: 'Relations',
  Key.contactDataResponsibility: 'Responsibility',
  Key.contactDataShowPSTN: 'PSTN',
  Key.contactDataShowTags: 'Tags',
  Key.contactDataTelephoneNumbers: 'Telephone numbers',
  Key.contactDataTitle: 'Title',
  Key.contactDataWorkHours: 'Work hours',
  Key.contactSelectorHeader: 'Contacts',

  Key.copy: 'Copy',

  Key.date: 'Date',
  Key.dayMonday: 'Monday',
  Key.dayTuesday: 'Tuesday',
  Key.dayWednesday: 'Wednesday',
  Key.dayThursday: 'Thursday',
  Key.dayFriday: 'Friday',
  Key.daySaturday: 'Saturday',
  Key.daySunday: 'Sunday',
  Key.delete: 'Delete',
  Key.duration: 'Duration',

  Key.editDelete: 'edit/delete',
  Key.editorNew: 'new',
  Key.error: 'error',
  Key.errorCallControllerBusy: 'Call handling temporarily busy',
  Key.errorCallHangup: 'Hangup failed',
  Key.errorCallNotFound: 'Call not found',
  Key.errorCallNotFoundExtended: 'The requested call could not be answered',
  Key.errorCallPark: 'Call park failed',
  Key.errorCallTransfer: 'Call transfer failed',
  Key.errorCallUnpark: 'Pickup call from park failed',
  Key.errorSystem: 'System error',
  Key.extension: 'Extension',

  Key.filter: 'filter...',

  Key.globalCallQueueHeader: 'Queue',

  Key.message: 'Message',
  Key.messageArchiveContact: 'Recipient',
  Key.messageArchiveHeader: 'Message archive',
  Key.messageCloseErrorTitle: 'Message not closed',
  Key.messageCloseSuccessTitle: 'Message closed',
  Key.messageComposeCallerName: 'Full name',
  Key.messageComposeCallsBack: 'Will call back later',
  Key.messageComposeCellPhone: 'Cell phone',
  Key.messageComposeCompanyName: 'Company',
  Key.messageComposeHaveCalled: 'Have called',
  Key.messageComposeHeader: 'Message',
  Key.messageComposeLocalExt: 'Extension',
  Key.messageComposeMessage: 'Message',
  Key.messageComposeNameHint: 'Information about caller',
  Key.messageComposePleaseCall: 'Please call',
  Key.messageComposePhone: 'Phone',
  Key.messageComposeShowRecipients: 'Show recipients',
  Key.messageComposeShowNoRecipients: 'No recipients',
  Key.messageComposeUrgent: 'Urgent',
  Key.messageDeleteErrorTitle: 'Message not deleted',
  Key.messageDeleteSuccessTitle: 'Message deleted',
  Key.messageSaveErrorTitle: 'Message not saved',
  Key.messageSaveSuccessTitle: 'Message saved',
  Key.messageSaveSendErrorTitle: 'Message not sent',
  Key.messageSaveSendSuccessTitle: 'Message sent',
  Key.myQueuedCallsHeader: 'My calls',

  Key.name: 'Name',
  Key.no: 'Nej',

  Key.paused: 'Paused',
  Key.phone: 'Phone',

  Key.queued: 'Queued',

  Key.reception: 'Reception',
  Key.receptionAddressesHeader: 'Addresses',
  Key.receptionAltNamesHeader: 'Alternative names',
  Key.receptionBankInfoHeader: 'Bank',
  Key.receptionCalendarHeader: 'Reception Calendar',
  Key.receptionCommandsHeader: 'Commands',
  Key.receptionChanged: 'Reception list will be refreshed on next call answer',
  Key.receptionEmailHeader: 'Email addresses',
  Key.receptionMiniWikiHeader: 'Mini wiki',
  Key.receptionOpeningHoursHeader: 'Opening hours',
  Key.receptionProductHeader: 'Product',
  Key.receptionSalesmenHeader: 'Salesmen',
  Key.receptionSelectorHeader: 'Receptions',
  Key.receptionTelephoneNumbersHeader: 'Telephone numbers',
  Key.receptionTypeHeader: 'Reception type',
  Key.receptionVATNumbersHeader: 'VAT numbers',
  Key.receptionWebsitesHeader: 'WWW',

  Key.save: 'Save',
  Key.saved: 'Saved',
  Key.send: 'Send',
  Key.sent: 'Sent',
  Key.standardGreeting: 'You\'ve called....',
  Key.start: 'Start',
  Key.stateDisasterHeader: 'Problems discovered. Trying to recover every 10 seconds',
  Key.stateLoadingHeader: 'Hold on to your bits while we\'re loading the application',
  Key.status: 'Status',
  Key.stop: 'Stop',

  Key.unknown: 'Unknown',

  Key.yes: 'Yes'
};
