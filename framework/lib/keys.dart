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

library openreception.keys;

const String recent = 'recent';
const String total = 'total';
const String agentChannel = 'agentChannel';
const String uuid = 'uuid';
const String path = 'path';
const String started = 'started';
const String contactID = 'contact_id';
const String contactName = 'contact_name';
const String receptionName = 'reception_name';
const String fullName = 'full_name';
const String contactType = 'contact_type';
const String enabled = 'enabled';
const String userID = 'uid';
const String updatedAt = 'updated';
const String username = 'username';
const String ID = 'id';
const String callId = 'call_id';
const String state = 'state';
const String bLeg = 'b_leg';
const String locked = 'locked';
const String inbound = 'inbound';
const String isCall = 'is_call';
const String destination = 'destination';
const String callerID = 'caller_id';
const String greetingPlayed = 'greeting_played';
const String receptionID = 'reception_id';
const String assignedTo = 'assigned_to';
const String channel = 'channel';
const String arrivalTime = 'arrival_time';
const String answeredAt = 'answered_at';
const String calendarServerUri = 'calendarServerUri';
const String callFlowServerURI = 'callFlowServerURI';
const String dialplanServerURI = 'dialplanServerURI';
const String receptionServerURI = 'receptionServerURI';
const String contactServerURI = 'contactServerURI';
const String messageServerURI = 'messageServerURI';
const String authServerURI = 'authServerURI';
const String userServerURI = 'userServerURI';
const String notificationSocket = 'notificationSocket';
const String systemLanguage = 'systemLanguage';
const String notificationServerUri = 'notificationServerUri';
const String connectionCount = 'connectionCount';
const String departments = 'departments';
const String wantsMessages = 'wants_messages';
const String reception = 'reception';
const String contact = 'contact';
const String company = 'company';
const String phone = 'phone';
const String cellPhone = 'cellPhone';
const String localExtension = 'localExtension';
const String statusEmail = 'statusEmail';
const String lastEntry = 'lastEntry';
const String password = 'password';
const String context = 'context';
const String inTransition = 'inTransition';
const String paused = 'paused';

const String distributionList = 'distribution_list';
const String phones = 'phones';
const String endpoints = 'endpoints';
const String backup = 'backup';
const String emailaddresses = 'emailaddresses';
const String handling = 'handling';
const String workhours = 'workhours';
const String tags = 'tags';
const String infos = 'infos';
const String titles = 'titles';
const String relations = 'relations';
const String responsibilities = 'responsibilities';

const String messagePrerequisites = 'messagePrerequisites';
const String billingType = 'billing_type';
const String flag = 'flag';
const String registered = 'registered';
const String activeChannels = 'activeChannels';
const String description = 'description';
const String value = 'value';
const String confidential = 'confidential';
const String type = 'type';
const String tag = 'tag';
const String organizationId = 'organization_id';
const String dialplan = 'dialplan';
const String extradataUri = 'extradatauri';
const String receptionTelephonenumber = 'reception_telephonenumber';
const String lastCheck = 'last_check';
const String shortGreeting = 'short_greeting';
const String greeting = 'greeting';
const String addresses = 'addresses';
const String attributes = 'attributes';
const String priority = 'priority';
const String role = 'role';

const String alternateNames = 'alternatenames';
const String customerTypes = 'customertypes';
const String product = 'product';
const String bankingInfo = 'bankinginformation';
const String salesMarketingHandling = 'salescalls';
const String emailAdresses = 'emailaddresses';
const String handlingInstructions = 'handlings';
const String openingHours = 'openinghours';
const String vatNumbers = 'registrationnumbers';
const String other = 'other';
const String phoneNumbers = 'telephonenumbers';
const String websites = 'websites';
const String miniWiki = 'miniwiki';

const String address = 'address';
const String groups = 'groups';
const String id = 'id';
const String identites = 'identites';
const String name = 'name';
const String extension = 'extension';
const String googleUsername = 'google_username';
const String googleAppcode = 'google_appcode';
const String UserID = 'userID';
const String lastState = 'lastState';
const String lastActivity = 'lastActivity';
const String callsHandled = 'callsHandled';
const String assignedCalls = 'assignedCalls';

const String start = 'start';
const String end = 'end';

const String takenByAgent = 'taken_by_agent';
const String enqueued = 'enqueued';
const String sent = 'sent';
const String caller = 'caller';
const String flags = 'flags';
const String body = 'message';
const String createdAt = 'created_at';
const String recipients = 'recipients';
const String tries = 'tries';
const String messageId = 'messageId';
const String lastTry = 'lastTry';
const String handledRecipients = 'handledRecipients';
const String unhandledRecipients = 'unhandledRecipients';

///Message flags
const String pleaseCall = 'pleaseCall';
const String willCallBack = 'willCallBack';
const String called = 'called';
const String urgent = 'urgent';
const String manuallyClosed = 'manuallyClosed';

///Message filter keys
const String upperMessageId = 'upper_message_id';
const String limit = 'limit';

/**
 * Common CDR related keys.
 */
class CdrKey {
  static final String agentBeginEpoch = 'agentBeginEpoch';
  static final String agentChannel = 'agentChannel';
  static final String agentEndEpoch = 'agentEndEpoch';
  static final String agentSummaries = 'agentSummaries';
  static final String answered10 = 'answered10';
  static final String answered10to20 = 'answered10to20';
  static final String answered20to60 = 'answered20to60';
  static final String answeredAfter60 = 'answeredAfter60';
  static final String answerEpoch = 'answerEpoch';
  static final String averageCallTime = 'averageCallTime';
  static final String averageOutboundCost = 'averageOutboundCost';
  static final String billSec = 'billSec';
  static final String bridgeUuid = 'bridgeUuid';
  static final String callChargeMultiplier = 'callChargeMultiplier';
  static final String callNotify = 'callNotify';
  static final String cdrFiles = 'cdrFiles';
  static final String cid = 'cid';
  static final String contextCallId = 'contextCallId';
  static final String cost = 'cost';
  static final String destination = 'destination';
  static final String direction = 'direction';
  static final String endEpoch = 'endEpoch';
  static final String externalTransferEpoch = 'externalTransferEpoch';
  static final String filename = 'filename';
  static final String finalTransferAction = 'finalTransferAction';
  static final String hangupCause = 'hangupCause';
  static final String inboundBillSeconds = 'inboundBillSeconds';
  static final String inboundNotNotified = 'inboundNotNotified';
  static final String ivr = 'ivr';
  static final String longCalls = 'longCalls';
  static final String notifiedAnswered = 'notifiedAnswered';
  static final String notifiedNotAnswered = 'notifiedNotAnswered';
  static final String outbound = 'outbound';
  static final String outboundBillSeconds = 'outboundBillSeconds';
  static final String outboundByAgent = 'outboundByAgent';
  static final String outboundCost = 'outboundCost';
  static final String outboundByPbx = 'outboundByPbx';
  static final String receptionOpen = 'receptionOpen';
  static final String rid = 'rid';
  static final String shortCalls = 'shortCalls';
  static final String sipFromUserStripped = 'sipFromUserStripped';
  static final String startEpoch = 'startEpoch';
  static final String state = 'state';
  static final String uid = 'uid';
  static final String uuid = 'uuid';
  static final String voicemail = 'voicemail';
}
