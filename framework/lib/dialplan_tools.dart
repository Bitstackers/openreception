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

library openreception.dialplan_tools;

import 'model.dart' as model;

///Config values.
bool goLive = false;
String greetingDir = 'converted-vox';
String testNumber = 'xxxxxxxx';
String testEmail = 'some-guy@somewhere';

/**
 * Normalizes an opening hour string for use in extension name by removing the
 * spaces and removing other odd characters.
 */
String _normalizeOpeningHour(String string) =>
    string.replaceAll(' ', '_').replaceAll(':', '');

/**
 * Indent a string by two spaces.
 */
String _indent(item, {int count: 2}) => '  $item';

/**
 * Determine if an Iterable of actions involves receptions.
 */
bool _involvesReceptionists(Iterable<model.Action> actions) => actions
    .where((action) => action is model.Notify)
    .any((notify) => notify.eventName == 'call-offer');

/**
 *
 */
List<String> _openingHourToXmlDialplan(String extension, model.OpeningHour oh,
        Iterable<model.Action> actions) =>
    [
      '',
      _comment('Actions for opening hour $oh'),
      '<extension name="${extension}-${_normalizeOpeningHour(oh.toString())}" continue="true">'
    ]
      ..addAll(_involvesReceptionists(actions)
          ? ['  <condition field="\${reception_open}" expression="^true\$"/>']
          : [])
      ..add('  <condition ${_openingHourToFreeSwitch(oh)} break="on-true">')
      ..addAll(actions.map(_actionToXmlDialplan).fold(
          [],
          (combined, current) =>
              combined..addAll(current.map(_indent).map(_indent))))
      ..add('    <action application="hangup"/>')
      ..add('  </condition>')
      ..add('</extension>');

/**
 * Generate A fallback extension.
 */
List<String> _fallbackToDialplan(
    String extension, Iterable<model.Action> actions) {
  if (actions.last is model.Playback) {
    actions = new List.generate(10, (_) => actions.last);
  }
  return [
    '',
    _comment('Default fallback actions for $extension'),
    '<extension name="${extension}-closed">',
    '  <condition>',
  ]
    ..addAll(actions.map(_actionToXmlDialplan).fold(
        [], (combined, current) => combined..addAll(current.map(_indent))))
    ..add('    <action application="hangup"/>')
    ..add('  </condition>')
    ..add('</extension>');
}

/**
 *
 */
Iterable<String> _hourActionToXmlDialplan(
        String extension, model.HourAction hourAction) =>
    hourAction.hours.map(
        (oh) => _openingHourToXmlDialplan(extension, oh, hourAction.actions));

/**
 *
 */
Iterable<String> _hourActionsToXmlDialplan(
        String extension, Iterable<model.HourAction> hourActions) =>
    hourActions.map((ha) => _hourActionToXmlDialplan(extension, ha)
        .fold([], (combined, current) => combined..addAll(current)));

Iterable<String> _namedExtensionToDialPlan(model.NamedExtension extension) => [
      '',
      _noteTemplate('Extra-extension ${extension.name}'),
      '<extension name="${extension.name}" continue="true">',
      '  <condition field="destination_number" expression="^${extension.name}\$" break="on-false">',
    ]
      ..addAll(extension.actions.map(_actionToXmlDialplan).fold(
          [],
          (combined, current) =>
              combined..addAll(current.map(_indent).map(_indent))))
      ..add('  </condition>')
      ..add('</extension>');

Iterable<String> _extraExtensionsToDialplan(
        Iterable<model.NamedExtension> extensions) =>
    extensions
        .map(_namedExtensionToDialPlan)
        .fold([], (combined, current) => combined..addAll(current));

/**
 *
 */
String convertTextual(model.ReceptionDialplan dialplan, int rid) =>
    '''<!-- Dialplan for extension ${dialplan.extension}. Generated ${new DateTime.now()} -->
<include>
  <context name="reception-${dialplan.extension}">

    <!-- Initialize channel variables -->
    <extension name="${dialplan.extension}" continue="true">
      <condition field="destination_number" expression="^${dialplan.extension}\$" break="on-false">
        <action application="log" data="INFO Setting variables of call to ${dialplan.extension}, currently allocated to ID:${rid}."/>
        ${_setVar('reception_id', rid)}
        ${_setVar('openreception::greeting-played', false)}
        ${_setVar('openreception::locked', false)}
      </condition>
    </extension>

    ${_extraExtensionsToDialplan(dialplan.extraExtensions).join('\n    ')}
    
    <!-- Perform outbound calls -->
    <extension name="${dialplan.extension}-outbound" continue="true">
      <condition field="destination_number" expression="^external_transfer_(\d+)">
       <action application="bridge" data="{originate_timeout=120}[leg_timeout=50,reception_id=$rid]sofia/gateway/\${default_trunk}/\$1"/>
        <action application="hangup"/>
      </condition>
    </extension>
    ${_hourActionsToXmlDialplan(dialplan.extension, dialplan.open).fold([], (combined, current) => combined..addAll(current)).join('\n    ')}
    ${_fallbackToDialplan(dialplan.extension, dialplan.defaultActions).join('\n    ')}

  </context>
</include>''';

/**
 * Detemine whether or not an extension is local or not.
 */
bool _isInternalExtension(String extension) => extension.contains('-');

/**
 * Template for dialout action.
 */
String _dialoutTemplate(String extension) => _isInternalExtension(extension)
    ? extension
    : goLive
        ? 'external_transfer_${extension} XML receptions'
        : 'external_transfer_${testNumber} XML receptions';

/**
 *
 */
String _liveCheckEmail(String email) => goLive ? email : testEmail;

/**
* Template for dialplan note.
*/
String _noteTemplate(String note) => _comment('Note: $note');

/**
 * Template for a comment.
 */
String _comment(String text) => '<!-- $text -->';

/**
 * Template transfer action.
 */
String _transferTemplate(String extension) =>
    '<action application="transfer" data="${_dialoutTemplate(extension)}"/>';

/**
* Template for set state action.
*/
String _setState(String newState) => _setVar("openreception::state", newState);

/**
 * Template for a sleep action.
 */
String _sleep(int msec) => '<action application="sleep" data="$msec"/>';

/**
 * Template for a call lock event.
 */
String _lockEvent() => '<action application="event" '
    'data="Event-Subclass=openreception::call-lock,Event-Name=CUSTOM"/>';
/**
 * Template for a call unlock event.
 */
String _unlockEvent() => '<action application="event" '
    'data="Event-Subclass=openreception::call-unlock,Event-Name=CUSTOM"/>';

/**
 * Template for a set variable action.
 */
String _setVar(String key, dynamic value) =>
    '<action application="set" data="$key=$value"/>';

/**
 * Template for a ring tone event.
 */
String _ringToneEvent() => '<action application="event" '
    'data="Event-Subclass=openreception::ringing-start,Event-Name=CUSTOM" />';

/**
 * Template for a ring stop event.
 */
String _ringToneStopEvent() => '<action application="event" '
    'data="Event-Subclass=openreception::ringing-stop,Event-Name=CUSTOM"/>';

/**
 * Template for a notify event.
 */
String _callNotifyEvent() => '<action application="event" '
    'data="Event-Subclass=openreception::call-notify,Event-Name=CUSTOM" />';

/**
 * Convert an action a xml dialplan entry.
 */
List<String> _actionToXmlDialplan(model.Action action) {
  List returnValue = [];
  if (action is model.Transfer) {
    if (action.note.isNotEmpty) returnValue.add(_noteTemplate(action.note));

    returnValue.add(_transferTemplate(action.extension));
  } else if (action is model.Notify) {
    returnValue.addAll([
      _comment('Announce the call to the receptionists'),
      _setState('new'),
      _callNotifyEvent()
    ]);
  } else if (action is model.Ringtone) {
    returnValue.addAll([
      _comment('Sending ringtones'),
      _setVar('openreception::state', 'ringing'),
      _ringToneEvent(),
      '<action application="answer"/>',
      '<action application="playback" '
          'data="tone_stream://L=${action.count};\${dk-ring}"/>',
      _ringToneStopEvent()
    ]);
  } else if (action is model.Playback) {
    if (action.note.isNotEmpty) returnValue.add(_noteTemplate(action.note));
    returnValue.addAll([_comment('Playback file ${action.filename}')]);

    returnValue.add(_setVar('openreception::state', 'playback'));

    if (action.wrapInLock) {
      returnValue
          .addAll([_setVar('openreception::locked', true), _lockEvent()]);
    }

    returnValue.addAll([
      _sleep(500),
      '<action application="playback" data="${greetingDir}/${action.filename}"/>',
      _sleep(500),
      _setVar('openreception::greeting-played', true),
    ]);

    if (action.wrapInLock) {
      returnValue
          .addAll([_setVar('openreception::locked', false), _unlockEvent()]);
    }
  } else if (action is model.Enqueue) {
    returnValue.addAll([
      _comment('Enqueue call'),
      '<action application="set" data="openreception::state=queued"/>',
      '<action application="event" data="Event-Subclass=openreception::wait-queue-enter,Event-Name=CUSTOM" />',
      '<action application="set" data="fifo_music=local_stream://${action.holdMusic}"/>',
      '<action application="fifo" data="${action.queueName}@\${domain_name} in"/>'
    ]);
  } else if (action is model.Voicemail) {
    if (action.note.isNotEmpty) returnValue.add(_noteTemplate(action.note));
    returnValue.add(
        '<action application="voicemail" data="default \$\${domain} ${action.vmBox}"/>');
  } else if (action is model.Ivr) {
    returnValue.add('<action application="ivr" data="${action.menuName}"/>');
  } else {
    throw new StateError('Unsupported action type: ${action.runtimeType}');
  }

  return returnValue;
}

/**
 * Replace dialplan that are statically known.
 */
String unfoldVariables(String buffer, String extension) => buffer
    .replaceAll('\${destination_number}', extension)
    .replaceAll('\${reception-greeting}', '$extension-dag.wav')
    .replaceAll('\${reception-greeting-closed}', '$extension-nat.wav');

/**
 * Turns a [model.WeekDay] into a FreeSWITCH weekday index.
 */
int _weekDayToFreeSwitch(model.WeekDay wday) => (wday.index) + 1;

/**
 * Formats an [model.OpeningHour] into a format that FreeSWITCH understands.
 */
String _openingHourToFreeSwitch(model.OpeningHour oh) {
  String wDayString = '';

  /// Prefixes string of integer with a '0' if the integer value is below 10.
  String _twoDigitInt(int i) => i < 10 ? '0$i' : '$i';

  if ([oh.fromDay, oh.toDay].contains(model.WeekDay.all)) {
    wDayString = '';
  } else if (oh.fromDay == oh.toDay) {
    wDayString = 'wday="${_weekDayToFreeSwitch(oh.fromDay)}"';
  } else {
    wDayString =
        'wday="${_weekDayToFreeSwitch(oh.fromDay)}-${_weekDayToFreeSwitch(oh.toDay)}"';
  }

  String ohString =
      '${_twoDigitInt(oh.fromHour)}:${_twoDigitInt(oh.fromMinute)}:00-'
      '${_twoDigitInt(oh.toHour)}:${_twoDigitInt(oh.toMinute)}:00';

  return '$wDayString time-of-day="$ohString"';
}

/**
 *
 */

List<String> _ivrMenuToXml(model.IvrMenu menu) => menu.entries
    .map(_ivrEntryToXml)
    .fold([], (combined, current) => combined..addAll(current));

String _generateXmlFromIvrMenu(model.IvrMenu menu) =>
    '''<menu name="${menu.name}"
      greet-long="\$\${sounds_dir}/${greetingDir}/${menu.greetingLong.filename}"
      greet-short="\$\${sounds_dir}/${greetingDir}/${menu.greetingShort.filename}"
      timeout="\$\${IVR_timeout}"
      max-failures="\$\${IVR_max-failures}"
      max-timeouts="\$\${IVR_max-timeout}">

    ${(_ivrMenuToXml(menu)).join('\n    ')}
  </menu>  
  
  ${menu.submenus.map(_generateXmlFromIvrMenu).join('\n  ')}
''';

String generateXmlFromIvr(model.IvrMenu menu) => '''
<include>
  ${_generateXmlFromIvrMenu(menu)}
</include>''';

List<String> _ivrEntryToXml(model.IvrEntry entry) {
  List returnValue = [];
  if (entry is model.IvrTransfer) {
    if (entry.transfer.note.isNotEmpty) returnValue
        .add(_noteTemplate(entry.transfer.note));
    returnValue.add('<entry action="menu-exec-app" digits="${entry.digits}" '
        'param="transfer ${_dialoutTemplate(entry.transfer.extension)}"/>');
  } else if (entry is model.IvrVoicemail) {
    returnValue.add(
        '<entry action="menu-exec-app" digits="${entry.digits}" param="voicemail default \$\${domain} ${entry.voicemail.vmBox}"/>');
  } else if (entry is model.IvrSubmenu) {
    returnValue.add(
        '<entry action="menu-sub" digits="${entry.digits}" param="${entry.name}"/>');
  } else if (entry is model.IvrTopmenu) {
    returnValue.add('<entry action="menu-top" digits="${entry.digits}"/>');
  } else throw new ArgumentError.value(
      entry.runtimeType,
      'entry'
      'type ${entry.runtimeType} is not supported by translation tool');

  return returnValue;
}

Iterable<String> ivrOf(model.ReceptionDialplan rdp) => rdp.allActions
    .where((action) => action is model.Ivr)
    .map((ivr) => ivr.menuName);

/**
 *
 */
String convertVoicemail(model.Voicemail vm) => '''<include>
  <user id="${vm.vmBox}">
    <params>
      <param name="password" value=""/>
      <param name="vm-password" value=""/>
      <param name="http-allowed-api" value="voicemail"/>
      <param name="vm-mailto" value="${_liveCheckEmail(vm.recipient)}"/>
      <param name="vm-email-all-messages" value="true"/>
      <param name="vm-notify-mailto" value="${_liveCheckEmail(vm.recipient)}"/>
      <param name="vm-attach-file" value="true" />
      <param name="vm-skip-instructions" value="true"/>
      <param name="vm-skip-greeting" value="true"/>
    </params>
    <variables>
      <variable name="toll_allow" value=""/>
      <variable name="user_context" value="voicemail"/>
    </variables>
  </user>
</include>''';
