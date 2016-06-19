library management_tool.view;

import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:random_string/random_string.dart' as random;

import 'package:intl/intl.dart' show DateFormat;
import 'package:logging/logging.dart';
import 'package:openreception.framework/bus.dart';
import 'package:openreception.framework/model.dart' as model;
import 'package:openreception.framework/storage.dart' as storage;

//import 'package:openreception.framework/util.dart' as util;
import 'package:management_tool/searchcomponent.dart';
import 'package:management_tool/controller.dart' as controller;

part 'view/view-calendar.dart';
part 'view/view-contact_base_info.dart';
part 'view/view-dialplan_calendar_plot.dart';
part 'view/view-dialplan.dart';
part 'view/view-dialplan_list.dart';
part 'view/view-endpoint.dart';
part 'view/view-ivr_menu.dart';
part 'view/view-message_filter.dart';
part 'view/view-messages.dart';
part 'view/view-object_history.dart';
part 'view/view-organization.dart';
part 'view/view-peer_account.dart';
part 'view/view-phonenumbers.dart';
part 'view/view-reception_contact.dart';
part 'view/view-reception.dart';
part 'view/view-user.dart';
part 'view/view-user_groups.dart';
part 'view/view-user_identities.dart';

const String _libraryName = 'management_tool.view';
const List<String> phonenumberTypes = const ['PSTN', 'SIP'];
controller.Popup notify = controller.popup;

var _jsonpp = new JsonEncoder.withIndent('  ');
final DateFormat rfc3339 = new DateFormat('yyyy-MM-dd HH:mm');

int compareContacts(model.BaseContact c1, model.BaseContact c2) =>
    c1.name.toLowerCase().compareTo(c2.name.toLowerCase());

int compareReceptionContacts(
        model.ReceptionContact c1, model.ReceptionContact c2) =>
    compareContacts(c1.contact, c2.contact);

int compareOrgRefs(
        model.OrganizationReference o1, model.OrganizationReference o2) =>
    o1.name.toLowerCase().compareTo(o2.name.toLowerCase());

int compareUserRefs(model.UserReference u1, model.UserReference u2) =>
    u1.name.toLowerCase().compareTo(u2.name.toLowerCase());

int compareRecRefs(model.ReceptionReference r1, model.ReceptionReference r2) =>
    r1.name.toLowerCase().compareTo(r2.name.toLowerCase());

void specialCharReplace(TextAreaElement elem) {
  final String orgValue = elem.value;
  final String newValue = elem.value.replaceAll('->', '➔').replaceAll('¤', '⚙');

  if (orgValue != newValue) {
    final int cursorIndex = elem.selectionStart;
    final int diffLength = orgValue.length - newValue.length;
    elem.value = newValue;
    elem.selectionStart = cursorIndex - diffLength;
    elem.selectionEnd = cursorIndex - diffLength;
  }
}

/**
 *
 */
List<String> _valuesFromListTextArea(TextAreaElement ta) =>
    new List<String>.from(ta.value
        .replaceAll('->', '➔')
        .replaceAll('¤', '⚙')
        .split('\n')
        .map((String str) => str.trim())
        .where((String str) => str.isNotEmpty));

/**
 * Returns a valid URI from a string - or null if it is malformed.
 */
Uri _validUri(String str) {
  try {
    return Uri.parse(str);
  } catch (_) {
    return null;
  }
}

LIElement actionTemplate(model.Action oh) =>
    new LIElement()..text = oh.toString();

LIElement hourActionTemplate(model.HourAction ha) => new LIElement()
  ..children = [
    new HeadingElement.h4()..text = 'Hours',
    new UListElement()
      ..children = (ha.hours
          .map((oh) => new LIElement()..text = oh.toString())
          .toList()),
    new HeadingElement.h4()..text = 'Actions',
    new UListElement()..children = (ha.actions.map(actionTemplate).toList())
  ];

LIElement extensionTemplate(model.NamedExtension ne) => new LIElement()
  ..children = [
    new HeadingElement.h4()..text = ne.name,
    new UListElement()..children = (ne.actions.map(actionTemplate).toList())
  ];

class IvrMenuList {
  set menus(Iterable<model.IvrMenu> menus) {
    LIElement template(model.IvrMenu menu) => new IvrMenuListItem(menu).element;

    element.children = new List<Element>.from(
        [new AnchorElement(href: '/ivr/create')..text = 'Create new'])
      ..addAll(menus.map(template));
  }

  final UListElement element = new UListElement()
    ..classes = ['ivr-listing-widget'];
}

class IvrMenuListItem {
  IvrMenuListItem(model.IvrMenu menu) {
    element.children = [
      new AnchorElement(href: '/ivr/${menu.name}')..text = menu.name
    ];
  }

  final LIElement element = new LIElement();
}

class IvrMenuView {
  //final ORService.RESTIvrStore _ivrStore;

  String get name => element.id.replaceFirst('ivr-menu-', '');

  IvrMenuView() {
//    _saveButton.onClick.listen(
//        (_) => _ivrStore.update(menu).then((savedMenu) => menu = savedMenu));

    element.children = [
      _nameLabel,
      _nameInput,
      _longGreeting,
      _entries,
      _saveButton
    ];
  }

  set menu(model.IvrMenu menu) {
    element.id = 'ivr-menu-${menu.name}';
    _nameInput
      ..id = 'ivr-menu${menu.name}-name'
      ..value = menu.name;
    _nameLabel.text = 'ivr-menu${menu.name}-name';
    _longGreeting.text = '${menu.greetingLong}';
    _entries.value = menu.entries.map((entry) => entry.toJson()).join('\n');
  }

  model.IvrMenu get menu => new model.IvrMenu(
      _nameInput.value, model.Playback.parse(_longGreeting.text))
    ..name = name
    ..entries = _entries.value.split('\n').map(model.IvrEntry.parse).toList();

  final DivElement element = new DivElement()..classes = ['ivr-edit-widget'];
  final InputElement _nameInput = new InputElement();
  final ParagraphElement _nameLabel = new ParagraphElement()..text = 'Name: ';
  final ParagraphElement _longGreeting = new ParagraphElement();
  final TextAreaElement _entries = new TextAreaElement();
  final ButtonElement _saveButton = new ButtonElement()..text = 'Update';
}
