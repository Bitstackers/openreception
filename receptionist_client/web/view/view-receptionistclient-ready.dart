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

part of view;

/**
 * TODO (TL): Comment
 */
class ReceptionistclientReady {
  final Model.AppClientState            _appState;
  AgentInfo                             _agentInfo;
  CalendarEditor                        _calendarEditor;
  ContactCalendar                       _contactCalendar;
  final Controller.Contact              _contactController;
  ContactData                           _contactData;
  ContactSelector                       _contactSelector;
  Contexts                              _contexts;
  GlobalCallQueue                       _globalCallQueue;
  Hint                                  _help;
  MessageArchive                        _messageArchive;
  MessageArchiveEdit                    _messageArchiveEdit;
  MessageArchiveFilter                  _messageArchiveFilter;
  MessageCompose                        _messageCompose;
  MyCallQueue                           _myCallQueue;
  ReceptionAddresses                    _receptionAddresses;
  ReceptionAltNames                     _receptionAltNames;
  ReceptionBankInfo                     _receptionBankInfo;
  ReceptionCalendar                     _receptionCalendar;
  ReceptionCommands                     _receptionCommands;
  final Controller.Reception            _receptionController;
  ReceptionEmail                        _receptionEmail;
  ReceptionMiniWiki                     _receptionMiniWiki;
  ReceptionOpeningHours                 _receptionOpeningHours;
  ReceptionProduct                      _receptionProduct;
  ReceptionSalesmen                     _receptionSalesmen;
  ReceptionSelector                     _receptionSelector;
  ReceptionTelephoneNumbers             _receptionTelephoneNumbers;
  ReceptionType                         _receptionType;
  ReceptionVATNumbers                   _receptionVATNumbers;
  ReceptionWebsites                     _receptionWebsites;
  static ReceptionistclientReady        _singleton;
  final Controller.User                 _userController;
  final Model.UIReceptionistclientReady _ui;
  WelcomeMessage                        _welcomeMessage;

  /**
   * Constructor.
   */
  factory ReceptionistclientReady(Model.AppClientState appState,
                                  Model.UIReceptionistclientReady uiReady,
                                  Controller.Contact contactController,
                                  Controller.Reception receptionController,
                                  Controller.User userController) {
    if(_singleton == null) {
      _singleton = new ReceptionistclientReady._internal(appState,
                                                         uiReady,
                                                         contactController,
                                                         receptionController,
                                                         userController);
    } else {
      return _singleton;
    }
  }

  /**
   * Internal constructor.
   */
  ReceptionistclientReady._internal(Model.AppClientState this._appState,
                                    Model.UIReceptionistclientReady this._ui,
                                    this._contactController,
                                    this._receptionController,
                                    this._userController) {
    _observers();
  }

  /**
   * Observers.
   */
  void _observers() {
    _appState.onStateChange.listen((Model.AppState appState) =>
        appState == Model.AppState.READY ? _runApp() : _ui.visible = false);
  }

  /**
   * Go visible and setup all the app widgets.
   */
  void _runApp() {
    Model.UIContactCalendar   uiContactCalendar   = new Model.UIContactCalendar(querySelector('#contact-calendar'));
    Model.UIContactSelector   uiContactSelector   = new Model.UIContactSelector(querySelector('#contact-selector'));
    Model.UIReceptionCalendar uiReceptionCalendar = new Model.UIReceptionCalendar(querySelector('#reception-calendar'));
    Model.UIReceptionSelector uiReceptionSelector = new Model.UIReceptionSelector(querySelector('#reception-selector'));

    _contexts = new Contexts(new Model.UIContexts());
    _help     = new Hint(new Model.UIHint());

    _agentInfo = new AgentInfo(new Model.UIAgentInfo(querySelector('#agent-info')), _userController);

    _contactCalendar = new ContactCalendar
        (uiContactCalendar,
         new Controller.Destination(Context.Home, Widget.ContactCalendar),
         uiContactSelector,
         uiReceptionSelector,
         _contactController);

    _contactData = new ContactData
        (new Model.UIContactData(querySelector('#contact-data')),
         new Controller.Destination(Context.Home, Widget.ContactData),
         uiContactSelector,
         uiReceptionSelector);

    _calendarEditor = new CalendarEditor
        (new Model.UICalendarEditor(querySelector('#calendar-editor')),
         new Controller.Destination(Context.CalendarEdit, Widget.CalendarEditor),
         uiContactCalendar,
         uiReceptionCalendar);

    _contactSelector = new ContactSelector
        (uiContactSelector,
         new Controller.Destination(Context.Home, Widget.ContactSelector),
         uiReceptionSelector,
         _contactController);

    _globalCallQueue = new GlobalCallQueue
        (new Model.UIGlobalCallQueue(querySelector('#global-call-queue')),
         new Controller.Destination(Context.Home, Widget.GlobalCallQueue));

    _messageArchive = new MessageArchive
        (new Model.UIMessageArchive(querySelector('#message-archive')),
         new Controller.Destination(Context.Messages, Widget.MessageArchive));

    _messageArchiveEdit = new MessageArchiveEdit
        (new Model.UIMessageArchiveEdit(querySelector('#message-archive-edit')),
         new Controller.Destination(Context.Messages, Widget.MessageArchiveEdit));

    _messageArchiveFilter = new MessageArchiveFilter
        (new Model.UIMessageArchiveFilter(querySelector('#message-archive-filter')),
         new Controller.Destination(Context.Messages, Widget.MessageArchiveFilter));

    _messageCompose = new MessageCompose
        (new Model.UIMessageCompose(querySelector('#message-compose')),
         new Controller.Destination(Context.Home, Widget.MessageCompose));

    _myCallQueue = new MyCallQueue
        (new Model.UIMyCallQueue(querySelector('#my-call-queue')),
         new Controller.Destination(Context.Home, Widget.MyCallQueue));

    _receptionAddresses = new ReceptionAddresses
        (new Model.UIReceptionAddresses(querySelector('#reception-addresses')),
         new Controller.Destination(Context.Homeplus, Widget.ReceptionAddresses),
         uiReceptionSelector);

    _receptionAltNames = new ReceptionAltNames
        (new Model.UIReceptionAltNames(querySelector('#reception-alt-names')),
         new Controller.Destination(Context.Homeplus, Widget.ReceptionAltNames),
         uiReceptionSelector);

    _receptionBankInfo = new ReceptionBankInfo
        (new Model.UIReceptionBankInfo(querySelector('#reception-bank-info')),
         new Controller.Destination(Context.Homeplus, Widget.ReceptionBankInfo),
         uiReceptionSelector);

    _receptionCalendar = new ReceptionCalendar
        (uiReceptionCalendar,
         new Controller.Destination(Context.Home, Widget.ReceptionCalendar),
         uiReceptionSelector,
         this._receptionController);

    _receptionCommands = new ReceptionCommands
        (new Model.UIReceptionCommands(querySelector('#reception-commands')),
         new Controller.Destination(Context.Home, Widget.ReceptionCommands),
         uiReceptionSelector);

    _receptionEmail = new ReceptionEmail
        (new Model.UIReceptionEmail(querySelector('#reception-email')),
         new Controller.Destination(Context.Homeplus, Widget.ReceptionEmail),
         uiReceptionSelector);

    _receptionMiniWiki = new ReceptionMiniWiki
        (new Model.UIReceptionMiniWiki(querySelector('#reception-mini-wiki')),
         new Controller.Destination(Context.Homeplus, Widget.ReceptionMiniWiki),
         uiReceptionSelector);

    _receptionOpeningHours = new ReceptionOpeningHours
        (new Model.UIReceptionOpeningHours(querySelector('#reception-opening-hours')),
         new Controller.Destination(Context.Home, Widget.ReceptionOpeningHours),
         uiReceptionSelector);

    _receptionProduct = new ReceptionProduct
        (new Model.UIReceptionProduct(querySelector('#reception-product')),
         new Controller.Destination(Context.Home, Widget.ReceptionProduct),
         uiReceptionSelector);

    _receptionSalesmen = new ReceptionSalesmen
        (new Model.UIReceptionSalesmen(querySelector('#reception-salesmen')),
         new Controller.Destination(Context.Home, Widget.ReceptionSalesmen),
         uiReceptionSelector);

    _receptionSelector = new ReceptionSelector
        (new Controller.Destination(Context.Home, Widget.ReceptionSelector),
         uiReceptionSelector,
         _receptionController);

    _receptionTelephoneNumbers = new ReceptionTelephoneNumbers
        (new Model.UIReceptionTelephoneNumbers(querySelector('#reception-telephone-numbers')),
         new Controller.Destination(Context.Homeplus, Widget.ReceptionTelephoneNumbers),
         uiReceptionSelector);

    _receptionType = new ReceptionType
        (new Model.UIReceptionType(querySelector('#reception-type')),
         new Controller.Destination(Context.Homeplus, Widget.ReceptionType),
         uiReceptionSelector);

    _receptionVATNumbers = new ReceptionVATNumbers
        (new Model.UIReceptionVATNumbers(querySelector('#reception-vat-numbers')),
         new Controller.Destination(Context.Homeplus, Widget.ReceptionVATNumbers),
         uiReceptionSelector);

    _receptionWebsites = new ReceptionWebsites
        (new Model.UIReceptionWebsites(querySelector('#reception-websites')),
         new Controller.Destination(Context.Homeplus, Widget.ReceptionWebsites),
         uiReceptionSelector);

    _welcomeMessage = new WelcomeMessage
        (new Model.UIWelcomeMessage(querySelector('#welcome-message')),
         uiReceptionSelector);

    _ui.visible = true;

    window.location.hash.isEmpty ? _navigate.goHome() : _navigate.goWindowLocation();
  }
}
