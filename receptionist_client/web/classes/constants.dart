library constants;

abstract class Id {
  static const String bobActive = 'bob-active';
  static const String CALL_ORIGINATE = 'call-originate';
  static const String contextHome = 'context-home';
  static const String contextHomeplus = 'context-homeplus';
  static const String contextMessages = 'context-messages';
  static const String contextLog = 'context-log';
  static const String contextStatistics = 'context-statistics';
  static const String contextPhone = 'context-phone';
  static const String contextVoicemails = 'context-voicemails';

  static const String COMPANY_ADDRESSES = 'companyaddresses';
  static const String COMPANY_ALTERNATENAMES = 'companyalternatenames';
  static const String COMPANY_BANKING_INFORMATION = 'companybankinginformation';
  static const String COMPANY_CUSTOMERTYPE = 'companycustomertype';
  static const String COMPANY_EMAIL_ADDRESSES = 'companyemailaddresses';
  static const String receptionEvents = 'reception-events';
  static const String receptionEventsHeader = 'reception-events-header';
  static const String COMPANY_HANDLING = 'companyhandling';
  static const String COMPANY_OPENINGHOURS = 'companyopeninghours';
  static const String COMPANY_OTHER = 'companyother';
  static const String COMPANY_PRODUCT = 'companyproduct';
  static const String COMPANY_REGISTRATION_NUMBER = 'companyregistrationnumber';
  static const String COMPANY_SALESCALLS = 'companysalescalls';
  static const String COMPANY_TELEPHONE_NUMBERS = 'companytelephonenumbers';
  static const String receptionSelector = 'reception-selector';
  static const String COMPANY_WEBSITES = 'companywebsites';
  static const String CONTACT_INFO = 'contactinfo';
  static const String contactCalendarEventCreateStartsHour = 'contact-calendar-event-create-starts-hour';
  static const String GLOBAL_QUEUE = 'globalqueue';

//  TODO (TL): Fix LOCAL_QUEUE so it is either a widget of it's own, or a proper
//  child of globalqueue.
//  static final String LOCAL_QUEUE = 'localqueue'; Currently called local-calls in HTML

  static const String LOGBOX = 'logbox';
  static const String MESSAGE_OVERVIEW = 'messageoverview';
  static const String MESSAGE_EDIT = 'message-edit';
  static const String PHONEBOOTH = 'phonebooth';
  static const String SENDMESSAGE = 'message-compose'; // TODO (TL): Bad name

  static const AGENT_INFO = 'agent-info';
//  static final CALL_MANAGEMENT = 'call-info'; // TODO (TL): Not in use???
  static const COMPANY_ADDRESSES_LIST = 'company-addresses-list';
  static const COMPANY_ALTERNATE_NAMES_LIST = 'company-alternate-names-list';
  static const COMPANY_BANKING_INFO_LIST = 'company-banking-info-list';
  static const COMPANY_CUSTOMERTYPE_BODY = 'company-customertype-body'; // TODO (TL): Bad name. *-body????
  static const COMPANY_EMAIL_ADDRESSES_LIST = 'company-email-addresses-list';
  static const receptionEventsList = 'reception-events-list';
  static const COMPANY_HANDLING_LIST = 'company_handling_list';
  static const COMPANY_OPENINGHOURS_LIST = 'company-opening-hours-list';
  static const COMPANY_OTHER_BODY = 'company-other-body';
  static const COMPANY_PRODUCT_BODY = 'company-product-body';
  static const COMPANY_REGISTRATION_NUMBER_LIST = 'company-registration-number-list';
  static const COMPANY_SALES_LIST = 'company-sales-list';
  static const receptionSelectorSearchbar = 'reception-selector-searchbar';
  static const COMPANY_TELEPHONENUMBERS_LIST = 'company-telephonenumbers-list';
  static const COMPANY_WEBSITES_LIST = 'company-websites-list';
  static const contextSwitcher = 'context-switcher';
  static const CONTACT_ADDITIONAL_INFO = 'contactAdditionalInfo'; // TODO (TL): Bad name
  static const CONTACT_BACKUP_LIST = 'contactBackupList'; // TODO (TL): Bad name
  static const CONTACT_CALENDAR = 'contact-calendar';
  static const CONTACT_DEPARTMENT = 'contactDepartment'; // TODO (TL): Bad name
  static const CONTACT_EMAIL_ADDRESS_LIST = 'contactEmailAddressList'; // TODO (TL): Bad name
  static const CONTACT_HANDLING_LIST = 'contactHandlingList'; // TODO (TL): Bad name
  static const CONTACT_INFO_CALENDAR = 'contactinfo_calendar';
  static const CONTACT_INFO_SEARCHBAR = 'contact-info-searchbar';
  static const CONTACT_POSITION = 'contactPosition'; // TODO (TL): Bad name
  static const CONTACT_RESPONSIBILITY = 'contactResponsibility'; // TODO (TL): Bad name
  static const CONTACT_RELATIONS = 'contactRelations'; // TODO (TL): Bad name
  static const CONTACT_TELEPHONE_NUMBER_LIST = 'contactTelephoneNumberList'; // TODO (TL): Bad name
  static const CONTACT_WORK_HOURS_LIST = 'contactWorkHoursList'; // TODO (TL): Bad name
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
