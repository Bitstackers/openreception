library constants;

abstract class CssClass {
  static const String calendarEventId = 'calendar-event-id';

  static const String callDestroyed = 'destroyed';
  static const String callEnqueued  = 'enqueued';
  static const String callLocked    = 'locked';
  static const String callParked    = 'parked';
  static const String callSpeaking  = 'speaking';

  static const String contactCalendarEventCreate             = 'contact-calendar-event-create';
  static const String contactCalendarEventEndsDay            = 'contact-calendar-event-create-ends-day';
  static const String contactCalendarEventEndsHour           = 'contact-calendar-event-create-ends-hour';
  static const String contactCalendarEventEndsMinute         = 'contact-calendar-event-create-ends-minute';
  static const String contactCalendarEventEndsMonth          = 'contact-calendar-event-create-ends-month';
  static const String contactCalendarEventEndsYear           = 'contact-calendar-event-create-ends-year';
  static const String contactCalendarEventCreateStartsDay    = 'contact-calendar-event-create-starts-day';
  static const String contactCalendarEventCreateStartsHour   = 'contact-calendar-event-create-starts-hour';
  static const String contactCalendarEventCreateStartsMinute = 'contact-calendar-event-create-starts-minute';
  static const String contactCalendarEventCreateStartsMonth  = 'contact-calendar-event-create-starts-month';
  static const String contactCalendarEventCreateStartsYear   = 'contact-calendar-event-create-starts-year';

  static const String contactDataAdditionalInfoLabel = 'contact-data-additional-info-label';
  static const String contactDataBackupsLabel        = 'contact-data-backups-label';
  static const String contactDataDepartmentLabel     = 'contact-data-department-label';
  static const String contactDataEmailsLabel         = 'contact-data-emails-label';
  static const String contactDataHandlingLabel       = 'contact-data-handling-label';
  static const String contactDataJobtitleLabel       = 'contact-data-jobtitle-label';
  static const String contactDataPhoneLabel          = 'contact-data-phone-label';
  static const String contactDataRelationsLabel      = 'contact-data-relations-label';
  static const String contactDataResponsibilityLabel = 'contact-data-responsibility-label';
  static const String contactDataWorkhoursLabel      = 'contact-data-workhours-label';

  static const String messageRecipientList = 'message-recipient-list';

  static const String messageSearchBox = 'message-search-box';
}

abstract class Id {
  static const String agentInfo                 = 'agent-info';
  static const String agentInfoPortrait         = 'agent-info-portrait';
  static const String agentInfoPortraitImage    = 'agent-info-portrait-image';
  static const String agentInfoStats            = 'agent-info-stats';
  static const String agentInfoStatsActive      = 'agent-info-stats-active';
  static const String agentInfoStatsPaused      = 'agent-info-stats-paused';
  static const String agentInfoStatsActiveLabel = 'agent-info-stats-active-label';
  static const String agentInfoStatsPausedLabel = 'agent-info-stats-paused-label';
  static const String agentInfoStatus           = 'agent-info-status';

  static const String bobActive   = 'bob-active';
  static const String bobDisaster = 'bob-disaster';
  static const String bobLoading  = 'bob-loading';

  static const String callOriginate = 'call-originate';

  static const String contactCalendar     = 'contact-calendar';
  static const String contactCalendarList = 'contact-calendar-list';

  static const String contactData                    = 'contact-data';
  static const String contactDataAdditionalInfo      = 'contact-data-additional-info';
  static const String contactDataBackupsList         = 'contact-data-backups-list';
  static const String contactDataDepartment          = 'contact-data-department';
  static const String contactDataEmailsList          = 'contact-data-emails-list';
  static const String contactDataHandlingList        = 'contact-data-handling-list';
  static const String contactDataHeader              = 'contact-data-header';
  static const String contactDataPosition            = 'contact-data-position';
  static const String contactDataRelations           = 'contact-data-relations';
  static const String contactDataResponsibility      = 'contact-data-responsibility';
  static const String contactDataTelephoneNumberList = 'contact-data-telephone-number-list';

  static const String contactSelector = 'contact-selector';
  static const String contactSelectorBody = 'contact-selector-body';
  static const String contactSelectorInput = 'contact-selector-input';
  static const String contactSelectorList = 'contact-selector-list';
  static const String contactSelectorSearch = 'contact-selector-search';

  static const String contactWorkHoursList = 'contact-work-hours-list';

  static const String contextHome = 'context-home';
  static const String contextHomeplus = 'context-homeplus';
  static const String contextLog = 'context-log';
  static const String contextMessages = 'context-messages';
  static const String contextPhone = 'context-phone';
  static const String contextStatistics = 'context-statistics';
  static const String contextSwitcher = 'context-switcher';
  static const String contextVoicemails = 'context-voicemails';

  static const String globalCallQueue = 'global-call-queue';
  static const String globalCallQueueList = 'global-call-queue-list';

  static const String localCallQueue = 'local-call-queue';
  static const String localCallQueueList = 'local-call-queue-list';

  static const String logBox = 'log-box';
  static const String logBoxTable = 'log-box-table';

  static const String messageCompose = 'message-compose';

  static const String messageEdit = 'message-edit';

  static const String messageOverview                = 'message-overview';
  static const String messageOverviewHeaderAgent     = 'message-overview-header-agent';
  static const String messageOverviewHeaderCaller    = 'message-overview-header-caller';
  static const String messageOverviewHeaderContext   = 'message-overview-header-context';
  static const String messageOverviewHeaderStatus    = 'message-overview-header-status';
  static const String messageOverviewHeaderTimestamp = 'message-overview-header-timestamp';

  static const String messageSearch          = 'message-search';
  static const String messageSearchAgent     = 'message-search-agent';
  static const String messageSearchContact   = 'message-search-contact';
  static const String messageSearchReception = 'message-search-reception';
  static const String messageSearchType      = 'message-search-type';

  static const String notifications = 'notifications';

  static const String phoneBooth            = 'phone-booth';
  static const String phoneBoothNumberField = 'phone-booth-number-field';

  static const String receptionAddresses              = 'reception-addresses';
  static const String receptionAddressesList          = 'reception-addresses-list';
  static const String receptionAlternateNames         = 'reception-alternate-names';
  static const String receptionAlternateNamesList     = 'reception-alternate-names-list';
  static const String receptionBankingInformation     = 'reception-banking-information';
  static const String receptionBankingInformationList = 'reception-banking-information-list';
  static const String receptionCustomerType           = 'reception-customer-type';
  static const String receptionCustomerTypeBody       = 'reception-customer-type-body';
  static const String receptionEmailAddresses         = 'reception-email-addresses';
  static const String receptionEmailAddressesList     = 'reception-email-addresses-list';
  static const String receptionEvents                 = 'reception-events';
  static const String receptionEventsHeader           = 'reception-events-header';
  static const String receptionEventsList             = 'reception-events-list';
  static const String receptionExtraInformation       = 'reception-extra-information';
  static const String receptionExtraInformationBody   = 'reception-extra-information-body';
  static const String receptionHandling               = 'reception-handling';
  static const String receptionHandlingList           = 'reception-handling-list';
  static const String receptionOpeningHours           = 'reception-opening-hours';
  static const String receptionOpeningHoursList       = 'reception-opening-hours-list';
  static const String receptionProduct                = 'reception-product';
  static const String receptionProductBody            = 'reception-product-body';
  static const String receptionRegistrationNumber     = 'reception-registration-number';
  static const String receptionRegistrationNumberList = 'reception-registration-number-list';
  static const String receptionSalesCalls             = 'reception-sales-calls';
  static const String receptionSalesCallsList         = 'reception-sales-calls-list';
  static const String receptionSelectorSearchbar      = 'reception-selector-searchbar';
  static const String receptionTelephoneNumbers       = 'reception-telephone-numbers';
  static const String receptionTelephoneNumbersList   = 'reception-telephone-numbers-list';
  static const String receptionWebsites               = 'reception-websites';
  static const String receptionWebsitesList           = 'reception-websites-list';
  static const String receptionSelector               = 'reception-selector';

  static const String sendMessageCancel    = 'send-message-cancel';
  static const String sendMessageCellPhone = 'send-message-cell-phone';
  static const String sendMessageDraft     = 'send-message-draft';
  static const String sendMessageLocalNo   = 'send-message-local-no';
  static const String sendMessageName      = 'send-message-name';
  static const String sendMessagePhone     = 'send-message-phone';
  static const String sendMessageReception = 'send-message-reception';
  static const String sendMessageSearchBox = 'send-message-search-box';
  static const String sendMessageSend      = 'send-message-send';
  static const String sendMessageText      = 'send-message-text';
  static const String welcomeMessage       = 'welcome-message';
}
