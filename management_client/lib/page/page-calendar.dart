library management_tool.page.calendar;

import 'dart:async';
import 'dart:html';

import 'package:logging/logging.dart';
import 'package:management_tool/controller.dart' as controller;
import 'package:management_tool/eventbus.dart';
import 'package:management_tool/view.dart' as view;
import 'package:openreception_framework/model.dart' as model;

const String _libraryName = 'management_tool.page.user';

/**
 *
 */
class Calendar {
  static const String _viewName = 'calendar';
  final Logger _log = new Logger('$_libraryName.Calendar');

  final DivElement element = new DivElement()
    ..id = "calendar-page"
    ..hidden = true
    ..classes.addAll(['page']);

  final controller.User _userController;
  final controller.Calendar _calendarController;
  final controller.Contact _contactController;
  final controller.Reception _receptionController;

  final UListElement _calendarChangeList = new UListElement()
    ..classes.add('calendar-change');

  /**
   *
   */
  Calendar(this._userController, this._calendarController,
      this._contactController, this._receptionController) {
    element.children = [_calendarChangeList];

    _observers();
  }

  /**
   *
   */
  Future _activatePage() async {
    _log.info('Activating calendar page');
    Iterable<model.CalendarEntry> entries = await _calendarController.list();

    _calendarChangeList.children = []..addAll(entries.map(_calendarEntryNode));
  }

  /**
   *
   */
  LIElement _calendarEntryNode(model.CalendarEntry ce) {
    final UListElement changeUl = new UListElement();
    final DivElement _ownerNode = new DivElement();

    _getOwnerNode(ce.owner).then((DivElement ownerElement) {
      _ownerNode.replaceWith(ownerElement);
    });

    _calendarController
        .changes(ce.ID)
        .then((Iterable<model.CalendarEntryChange> changes) {
      changeUl..children = ([]..addAll(changes.map(_changeToNode)));
    });

    return new LIElement()
      ..children = [
        new DivElement()
          ..children = [
            new HeadingElement.h3()..text = ce.content,
            _ownerNode,
            new HeadingElement.h4()..text = 'Ændringer',
            changeUl
          ]
      ];
  }

  /**
   *
   */
  Future<DivElement> _getOwnerNode(model.Owner owner) async {
    final DivElement de = new DivElement();
    if (owner is model.OwningContact) {
      final model.BaseContact contact =
          await _contactController.get(owner.contactId);
      de.text = contact.fullName;
    } else if (owner is model.OwningReception) {
      final model.Reception reception =
          await _receptionController.get(owner.receptionId);
      de.text = reception.name;
    } else {
      de.text = 'Ingen ejer';
    }

    return de;
  }

  /**
   *
   */
  LIElement _changeToNode(model.CalendarEntryChange cec) =>
      new LIElement()..text = 'Ændret ${cec.changedAt} af ${cec.username}';

  /**
   * Observers.
   */
  void _observers() {
    bus.on(WindowChanged).listen((WindowChanged event) {
      if (event.window == _viewName) {
        element.hidden = false;
        _activatePage();
      } else {
        element.hidden = true;
      }
    });
  }
}
