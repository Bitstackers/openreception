library constants;

abstract class CssClass {
  static const String calendarEventId = 'calendar-event-id';
  static const String contactCalendarEventCreate =
      'contact-calendar-event-create';
  static const String contactCalendarEventEndsDay =
      'contact-calendar-event-create-ends-day';
  static const String contactCalendarEventEndsHour =
      'contact-calendar-event-create-ends-hour';
  static const String contactCalendarEventEndsMinute =
      'contact-calendar-event-create-ends-minute';
  static const String contactCalendarEventEndsMonth =
      'contact-calendar-event-create-ends-month';
  static const String contactCalendarEventEndsYear =
      'contact-calendar-event-create-ends-year';
  static const String contactCalendarEventCreateStartsDay =
      'contact-calendar-event-create-starts-day';
  static const String contactCalendarEventCreateStartsHour =
      'contact-calendar-event-create-starts-hour';
  static const String contactCalendarEventCreateStartsMinute =
      'contact-calendar-event-create-starts-minute';
  static const String contactCalendarEventCreateStartsMonth =
      'contact-calendar-event-create-starts-month';
  static const String contactCalendarEventCreateStartsYear =
      'contact-calendar-event-create-starts-year';
  static const String contactDataAdditionalInfoLabel = 'contact-data-additional-info-label';
  static const String contactDataBackupsLabel = 'contact-data-backups-label';
  static const String contactDataDepartmentLabel = 'contact-data-department-label';
  static const String contactDataEmailsLabel = 'contact-data-emails-label';
  static const String contactDataHandlingLabel = 'contact-data-handling-label';
  static const String contactDataJobtitleLabel = 'contact-data-jobtitle-label';
  static const String contactDataPhoneLabel = 'contact-data-phone-label';
  static const String contactDataRelationsLabel = 'contact-data-relations-label';
  static const String contactDataResponsibilityLabel = 'contact-data-responsibility-label';
  static const String contactDataWorkhoursLabel = 'contact-data-workhours-label';
}

abstract class Id {
  static const String bobActive = 'bob-active';
  static const String CALL_ORIGINATE = 'call-originate';
  static const String contactCalendar = 'contact-calendar';
  static const String contactCalendarList = 'contact-calendar-list';
  static const String contactData = 'contact-data';
  static const String contactDataAdditionalInfo = 'contact-data-additional-info';
  static const String contactDataBackupsList = 'contact-data-backups-list';
  static const String contactDataDepartment = 'contact-data-department';
  static const String contactDataEmailsList = 'contact-data-emails-list';
  static const String contactDataHandlingList = 'contact-data-handling-list';
  static const String contactDataHeader = 'contact-data-header';
  static const String contactDataPosition = 'contact-data-position';
  static const String contactDataRelations = 'contact-data-relations';
  static const String contactDataResponsibility = 'contact-data-responsibility';
  static const String contactDataTelephoneNumberList = 'contact-data-telephone-number-list';
  static const String contactSelector = 'contact-selector';
  static const String contactSelectorBody = 'contact-selector-body';
  static const String contactSelectorInput = 'contact-selector-input';
  static const String contactSelectorList = 'contact-selector-list';
  static const String contactSelectorSearch = 'contact-selector-search';
  static const String contactWorkHoursList = 'contact-work-hours-list';
  static const String contextHome = 'context-home';
  static const String contextHomeplus = 'context-homeplus';
  static const String contextMessages = 'context-messages';
  static const String contextLog = 'context-log';
  static const String contextStatistics = 'context-statistics';
  static const String contextPhone = 'context-phone';
  static const String contextVoicemails = 'context-voicemails';

  static const String globalCallQueue = 'global-call-queue';
  static const String globalCallQueueList = 'global-call-queue-list';
  static const String localCallQueue = 'local-call-queue';
  static const String localCallQueueList = 'local-call-queue-list';

  static const String receptionAddresses = 'reception-addresses';
  static const String receptionAddressesList = 'reception-addresses-list';
  static const String receptionAlternateNames = 'reception-alternate-names';
  static const String receptionAlternateNamesList = 'reception-alternate-names-list';
  static const String receptionBankingInformation = 'reception-banking-information';
  static const String receptionBankingInformationList = 'reception-banking-information-list';
  static const String receptionCustomerType = 'reception-customer-type';
  static const String receptionCustomerTypeBody = 'reception-customer-type-body';
  static const String receptionEmailAddresses = 'reception-email-addresses';
  static const String receptionEmailAddressesList = 'reception-email-addresses-list';
  static const String receptionEvents = 'reception-events';
  static const String receptionEventsHeader = 'reception-events-header';
  static const String receptionExtraInformation = 'reception-extra-information';
  static const String receptionOpeningHours = 'reception-opening-hours';
  static const String receptionOpeningHoursList = 'reception-opening-hours-list';
  static const String receptionProduct = 'reception-product';
  static const String receptionProductBody = 'reception-product-body';
  static const String receptionRegistrationNumber = 'reception-registration-number';
  static const String receptionRegistrationNumberList = 'reception-registration-number-list';
  static const String receptionSalesCalls = 'reception-sales-calls';
  static const String receptionSalesCallsList = 'reception-sales-calls-list';
  static const String receptionTelephoneNumbers = 'reception-telephone-numbers';
  static const String receptionTelephoneNumbersList = 'reception-telephone-numbers-list';
  static const String receptionWebsites = 'reception-websites';
  static const String receptionWebsitesList = 'reception-websites-list';
  static const String companyHandling = 'company-handling';
  static const String companyHandlingList = 'company-handling-list';
  static const String receptionSelector = 'reception-selector';

  static const String LOGBOX = 'logbox';
  static const String MESSAGE_OVERVIEW = 'messageoverview';
  static const String MESSAGE_EDIT = 'message-edit';
  static const String PHONEBOOTH = 'phonebooth';
  static const String SENDMESSAGE = 'message-compose'; // TODO (TL): Bad name

  static const AGENT_INFO = 'agent-info';
//  static final CALL_MANAGEMENT = 'call-info'; // TODO (TL): Not in use???
  static const receptionEventsList = 'reception-events-list';
  static const COMPANY_OTHER_BODY = 'company-other-body';
  static const receptionSelectorSearchbar = 'reception-selector-searchbar';
  static const contextSwitcher = 'context-switcher';
  static const LOGBOX_TABLE = 'logbox-table';
  static const MESSAGE_SEARCH = 'message-search';
  static const NOTIFICATION_PANEL = 'notifications';
  static const PHONEBOOTH_NUMBERFIELD = 'phonebooth-numberfield';
  static const SENDMESSAGE_CANCEL = 'sendmessagecancel';

//  TODO (TL): Does not appear to be in use??
//  static final SENDMESSAGE_CHECKBOX1 = 'send-message-checkbox1';
//  static final SENDMESSAGE_CHECKBOX2 = 'send-message-checkbox2';
//  static final SENDMESSAGE_CHECKBOX3 = 'send-message-checkbox3';
//  static final SENDMESSAGE_CHECKBOX4 = 'send-message-checkbox4';

  static const SENDMESSAGE_DRAFT = 'sendmessagedraft';
  static const SENDMESSAGE_SEARCHBOX = 'sendmessagesearchbox';

//  TODO (TL): Does not appear to be in use??
//  static final SENDMESSAGE_SEARCH_RESULT = 'sendmessagesearchresult';
  static const SENDMESSAGE_NAME = 'sendmessagename';
  static const SENDMESSAGE_COMPANY = 'sendmessagecompany';
  static const SENDMESSAGE_PHONE = 'sendmessagephone';
  static const SENDMESSAGE_CELLPHONE = 'sendmessagecellphone';
  static const SENDMESSAGE_LOCALNO = 'sendmessagelocalno';
  static const SENDMESSAGE_SEND = 'sendmessagesend';
  static const SENDMESSAGE_TEXT = 'sendmessagetext';
  static const WELCOME_MESSAGE = 'welcome-message';
}
