library management_tool.view;

import 'dart:html';
import 'package:logging/logging.dart';
import 'package:openreception_framework/model.dart' as ORModel;
import 'package:openreception_framework/service.dart' as ORService;

part 'view-dialplan.dart';
part 'view-dialplan_list.dart';

LIElement actionTemplate(ORModel.Action oh) =>
    new LIElement()..text = oh.toString();

LIElement hourActionTemplate(ORModel.HourAction ha) => new LIElement()
  ..children = [
    new HeadingElement.h4()..text = 'Hours',
    new UListElement()
      ..children = (ha.hours
          .map((oh) => new LIElement()..text = oh.toString())
          .toList()),
    new HeadingElement.h4()..text = 'Actions',
    new UListElement()..children = (ha.actions.map(actionTemplate).toList())
  ];

LIElement extensionTemplate(ORModel.NamedExtension ne) => new LIElement()
  ..children = [
    new HeadingElement.h4()..text = ne.name,
    new UListElement()..children = (ne.actions.map(actionTemplate).toList())
  ];

class IvrMenuList {
  set menus(Iterable<ORModel.IvrMenu> menus) {
    LIElement template(ORModel.IvrMenu menu) =>
        new IvrMenuListItem(menu).element;

    element.children = [
      new AnchorElement(href: '/ivr/create')..text = 'Create new'
    ]..addAll(menus.map(template));
  }

  final UListElement element = new UListElement()
    ..classes = ['ivr-listing-widget'];
}

class IvrMenuListItem {
  IvrMenuListItem(ORModel.IvrMenu menu) {
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

  set menu(ORModel.IvrMenu menu) {
    element.id = 'ivr-menu-${menu.name}';
    _nameInput
      ..id = 'ivr-menu${menu.name}-name'
      ..value = menu.name;
    _nameLabel.text = 'ivr-menu${menu.name}-name';
    _longGreeting.text = '${menu.greetingLong}';
    _entries.value = menu.entries.map((entry) => entry.toJson()).join('\n');
  }

  ORModel.IvrMenu get menu => new ORModel.IvrMenu(
      _nameInput.value, ORModel.Playback.parse(_longGreeting.text))
    ..name = name
    ..entries = _entries.value.split('\n').map(ORModel.IvrEntry.parse).toList();

  final DivElement element = new DivElement()..classes = ['ivr-edit-widget'];
  final InputElement _nameInput = new InputElement();
  final ParagraphElement _nameLabel = new ParagraphElement()..text = 'Name: ';
  final ParagraphElement _longGreeting = new ParagraphElement();
  final TextAreaElement _entries = new TextAreaElement();
  final ButtonElement _saveButton = new ButtonElement()..text = 'Update';
}
