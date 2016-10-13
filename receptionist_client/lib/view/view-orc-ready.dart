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

part of orc.view;

/**
 * This class is responsible for instantiating all the widgets when then
 * [ui_model.AppClientState] is [Model.AppState.READY].
 */
class ORCReady {
  final ui_model.AppClientState _appState;
  final controller.Calendar _calendarController;
  final controller.Call _callController;
  final model.ClientConfiguration _clientConfig;
  ui_model.UICalendar _calendar;
  final controller.Contact _contactController;
  ContactSelector _contactSelector;
  Map<String, String> _langMap;
  MessageCompose _messageCompose;
  controller.Message _messageController;
  controller.Notification _notification;
  controller.Popup _popup;
  final controller.Reception _receptionController;
  ReceptionSelector _receptionSelector;
  static ORCReady _singleton;
  List<model.ReceptionReference> _sortedReceptions;
  final controller.Sound _sound;
  final controller.User _userController;
  final ui_model.UIORCReady _ui;

  /**
   * Constructor.
   */
  factory ORCReady(
      ui_model.AppClientState appState,
      ui_model.UIORCReady uiReady,
      controller.Calendar calendarController,
      model.ClientConfiguration clientConfig,
      controller.Contact contactController,
      controller.Reception receptionController,
      List<model.ReceptionReference> sortedReceptions,
      controller.User userController,
      controller.Call callController,
      controller.Notification notification,
      controller.Message message,
      controller.Popup popup,
      controller.Sound sound,
      Map<String, String> langMap) {
    if (_singleton == null) {
      _singleton = new ORCReady._internal(
          appState,
          uiReady,
          calendarController,
          clientConfig,
          contactController,
          receptionController,
          sortedReceptions,
          userController,
          callController,
          notification,
          message,
          popup,
          sound,
          langMap);
    }

    return _singleton;
  }

  /**
   * Internal constructor.
   */
  ORCReady._internal(
      ui_model.AppClientState this._appState,
      ui_model.UIORCReady this._ui,
      this._calendarController,
      this._clientConfig,
      this._contactController,
      this._receptionController,
      this._sortedReceptions,
      this._userController,
      this._callController,
      this._notification,
      this._messageController,
      this._popup,
      this._sound,
      this._langMap) {
    _observers();
  }

  /**
   * Observers.
   */
  void _observers() {
    _appState.onStateChange.listen((ui_model.AppState appState) =>
        appState == ui_model.AppState.ready ? _runApp() : _ui.visible = false);
  }

  /**
   * Go visible and instantiate all the widgets.
   */
  void _runApp() {
    final util.WeekDays _weekDays = new util.WeekDays(
        _langMap[Key.dayMonday],
        _langMap[Key.dayTuesday],
        _langMap[Key.dayWednesday],
        _langMap[Key.dayThursday],
        _langMap[Key.dayFriday],
        _langMap[Key.daySaturday],
        _langMap[Key.daySunday]);
    ui_model.UICalendar _uiCalendar = new ui_model.UICalendar(
        querySelector('#calendar'), _weekDays, _langMap);
    ui_model.UIContactData _uiContactData =
        new ui_model.UIContactData(querySelector('#contact-data'));
    ui_model.UIContactSelector _uiContactSelector =
        new ui_model.UIContactSelector(
            querySelector('#contact-selector'), _popup, _langMap);
    ui_model.UIMessageArchive _uiMessageArchive = new ui_model.UIMessageArchive(
        querySelector('#message-archive'), _weekDays, _langMap);
    ui_model.UIMessageCompose _uiMessageCompose =
        new ui_model.UIMessageCompose(querySelector('#message-compose'));
    ui_model.UIReceptionSelector _uiReceptionSelector =
        new ui_model.UIReceptionSelector(querySelector('#reception-selector'),
            _popup, _receptionController, _langMap);

    new Contexts(new ui_model.UIContexts());
    new Hint(new ui_model.UIHint());

    _userController
        .getState(_appState.currentUser)
        .then((model.UserStatus userStatus) {
      new AgentInfo(new ui_model.UIAgentInfo(querySelector('#agent-info')),
          _appState, _userController, _notification, _callController);

      new GlobalCallQueue(
          new ui_model.UIGlobalCallQueue(
              querySelector('#global-call-queue'),
              _langMap,
              _clientConfig.hideInboundCallerId,
              _clientConfig.myIdentifiers),
          _appState,
          new controller.Destination(
              controller.Context.home, controller.Widget.globalCallQueue),
          _notification,
          _callController,
          _sound,
          userStatus);
    });

    new Calendar(
        _uiCalendar,
        new controller.Destination(
            controller.Context.home, controller.Widget.calendar),
        _uiContactSelector,
        _uiReceptionSelector,
        _contactController,
        _calendarController,
        _notification);

    new ContactData(
        _uiContactData,
        new controller.Destination(
            controller.Context.home, controller.Widget.contactData),
        _uiContactSelector,
        _uiReceptionSelector,
        _popup,
        _langMap);

    new CalendarEditor(
        new ui_model.UICalendarEditor(
            querySelector('#calendar-editor'), _weekDays, _langMap),
        new controller.Destination(
            controller.Context.calendarEdit, controller.Widget.calendarEditor),
        _uiCalendar,
        _uiContactSelector,
        _uiReceptionSelector,
        _calendarController,
        _popup,
        _userController,
        _langMap);

    _contactSelector = new ContactSelector(
        _uiContactSelector,
        new controller.Destination(
            controller.Context.home, controller.Widget.contactSelector),
        _uiReceptionSelector,
        _contactController);

    new MessageArchive(
        _uiMessageArchive,
        new controller.Destination(
            controller.Context.messages, controller.Widget.messageArchive),
        _messageController,
        _userController,
        _uiContactSelector,
        _uiReceptionSelector,
        _uiMessageCompose,
        _popup,
        _langMap);

    _messageCompose = new MessageCompose(
        _uiMessageCompose,
        _uiMessageArchive,
        _appState,
        new controller.Destination(
            controller.Context.home, controller.Widget.messageCompose),
        _uiContactSelector,
        _uiReceptionSelector,
        _messageController,
        _notification,
        _popup,
        _langMap);

    new MyCallQueue(
        new ui_model.UIMyCallQueue(querySelector('#my-call-queue'), _langMap,
            _contactController, _receptionController),
        _uiMessageCompose,
        _appState,
        new controller.Destination(
            controller.Context.home, controller.Widget.myCallQueue),
        _notification,
        _callController,
        _popup,
        _langMap,
        _uiContactData,
        _uiContactSelector,
        _uiReceptionSelector);

    new ReceptionAddresses(
        new ui_model.UIReceptionAddresses(
            querySelector('#reception-addresses')),
        new controller.Destination(
            controller.Context.homePlus, controller.Widget.receptionAddresses),
        _uiReceptionSelector);

    new ReceptionAltNames(
        new ui_model.UIReceptionAltNames(querySelector('#reception-alt-names')),
        new controller.Destination(
            controller.Context.homePlus, controller.Widget.receptionAltNames),
        _uiReceptionSelector);

    new ReceptionBankInfo(
        new ui_model.UIReceptionBankInfo(querySelector('#reception-bank-info')),
        new controller.Destination(
            controller.Context.homePlus, controller.Widget.receptionBankInfo),
        _uiReceptionSelector);

    new ReceptionCommands(
        new ui_model.UIReceptionCommands(querySelector('#reception-commands')),
        new controller.Destination(
            controller.Context.home, controller.Widget.receptionCommands),
        _uiReceptionSelector);

    new ReceptionEmail(
        new ui_model.UIReceptionEmail(querySelector('#reception-email')),
        new controller.Destination(
            controller.Context.homePlus, controller.Widget.receptionEmail),
        _uiReceptionSelector);

    new ReceptionMiniWiki(
        new ui_model.UIReceptionMiniWiki(querySelector('#reception-mini-wiki')),
        new controller.Destination(
            controller.Context.homePlus, controller.Widget.receptionMiniWiki),
        _uiReceptionSelector);

    new ReceptionOpeningHours(
        new ui_model.UIReceptionOpeningHours(
            querySelector('#reception-opening-hours')),
        new controller.Destination(
            controller.Context.home, controller.Widget.receptionOpeningHours),
        _uiReceptionSelector);

    new ReceptionProduct(
        new ui_model.UIReceptionProduct(querySelector('#reception-product')),
        new controller.Destination(
            controller.Context.home, controller.Widget.receptionProduct),
        _uiReceptionSelector);

    new ReceptionSalesmen(
        new ui_model.UIReceptionSalesmen(querySelector('#reception-salesmen')),
        new controller.Destination(
            controller.Context.home, controller.Widget.receptionSalesmen),
        _uiReceptionSelector);

    _receptionSelector = new ReceptionSelector(
        _uiReceptionSelector,
        _appState,
        new controller.Destination(
            controller.Context.home, controller.Widget.receptionSelector),
        _notification,
        _sortedReceptions,
        _receptionController,
        _popup,
        _langMap);

    new ReceptionTelephoneNumbers(
        new ui_model.UIReceptionTelephoneNumbers(
            querySelector('#reception-telephone-numbers')),
        new controller.Destination(controller.Context.homePlus,
            controller.Widget.receptionTelephoneNumbers),
        _uiReceptionSelector);

    new ReceptionType(
        new ui_model.UIReceptionType(querySelector('#reception-type')),
        new controller.Destination(
            controller.Context.homePlus, controller.Widget.receptionType),
        _uiReceptionSelector,
        _langMap);

    new ReceptionVATNumbers(
        new ui_model.UIReceptionVATNumbers(
            querySelector('#reception-vat-numbers')),
        new controller.Destination(
            controller.Context.homePlus, controller.Widget.receptionVATNumbers),
        _uiReceptionSelector);

    new ReceptionWebsites(
        new ui_model.UIReceptionWebsites(querySelector('#reception-websites')),
        new controller.Destination(
            controller.Context.homePlus, controller.Widget.receptionWebsites),
        _uiReceptionSelector);

    new WelcomeMessage(
        new ui_model.UIWelcomeMessage(querySelector('#welcome-message')),
        _appState,
        _uiReceptionSelector,
        _langMap);

    _ui.visible = true;

    window.location.hash.isEmpty
        ? _navigate.goHome()
        : _navigate.goWindowLocation();
  }
}
