library orm.page.message;

import 'dart:async';
import 'dart:html';

import 'package:logging/logging.dart';
import 'package:orm/controller.dart' as controller;
import 'package:orm/view.dart' as view;
import 'package:orf/model.dart' as model;
import 'package:route_hierarchical/client.dart';

const String _libraryName = 'orm.page.message';

/**
 *
 */
class Message {
  final Logger _log = new Logger('$_libraryName');

  final DivElement element = new DivElement()
    ..hidden = true
    ..classes.addAll(['page']);

  final controller.Contact _contactController;
  final controller.Message _messageController;
  final controller.Reception _receptionController;
  final controller.User _userController;
  final Router _router;

  view.Messages _messageListingView;
  view.MessageFilter _messageFilterView;

  /**
   *
   */
  Message(this._contactController, this._messageController,
      this._receptionController, this._userController, this._router) {
    _setupRouter();

    _messageFilterView = new view.MessageFilter(
        _contactController, _receptionController, _userController);

    _messageListingView = new view.Messages(_messageController);
    element.children = [
      (new DivElement()
        ..classes.add('object-listing')
        ..children = [
          new HeadingElement.h2()..text = 'Filter',
          _messageFilterView.element,
        ]),
      new DivElement()
        ..classes.add('page-content')
        ..children = [_messageListingView.element]
    ];
    _observers();
  }

  /**
   * Observers.
   */
  void _observers() {
    _messageListingView.onDelete = () async {
      await _refresh();
    };

    _messageFilterView.onChange = () async {
      await _refresh();
    };
  }

  /**
   *
   */
  Future _refresh() async {
    _log.finest('Loading new message list');

    _messageListingView.loading = true;

    try {
      if (_messageFilterView.showSaved) {
        _messageListingView.messages =
            await _messageController.listSaved(_messageFilterView.filter);
      } else {
        List<DateTime> days = new List.generate(
            _messageFilterView.numDays,
            (int n) =>
                _messageFilterView.lastDate.subtract(new Duration(days: n)));

        List<model.Message> messages = [];
        await Future.wait(days.map((DateTime day) async {
          messages.addAll(
              await _messageController.list(day, _messageFilterView.filter));
        }));

        _messageListingView.messages = messages;
      }
    } finally {
      _messageListingView.loading = false;
    }
  }

  /**
   *
   */
  Future activate(RouteEvent e) async {
    element.hidden = false;
    await _refresh();
  }

  /**
   *
   */
  void deactivate(RouteEvent e) {
    element.hidden = true;
  }

  /**
   *
   */
  void _setupRouter() {
    print('setting up message router');
    _router.root
      ..addRoute(
          name: 'message',
          enter: activate,
          path: '/message',
          leave: deactivate);
  }
}
