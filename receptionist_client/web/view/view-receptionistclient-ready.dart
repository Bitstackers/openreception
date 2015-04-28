part of view;

/**
 * TODO (TL): Comment
 */
class ReceptionistclientReady {
  final Model.AppClientState                  _appState;
  AgentInfo                             agentInfo;
  CalendarEditor                        calendarEditor;
  ContactCalendar                       contactCalendar;
  ContactData                           contactData;
  ContactSelector                       contactSelector;
  Contexts                              contexts;
  GlobalCallQueue                       globalCallQueue;
  Hint                                  help;
  MessageArchive                        messageArchive;
  MessageArchiveEdit                    messageArchiveEdit;
  MessageArchiveFilter                  messageArchiveFilter;
  MessageCompose                        messageCompose;
  MyCallQueue                           myCallQueue;
  ReceptionAddresses                    receptionAddresses;
  ReceptionAltNames                     receptionAltNames;
  ReceptionBankInfo                     receptionBankInfo;
  ReceptionCalendar                     receptionCalendar;
  ReceptionCommands                     receptionCommands;
  ReceptionEmail                        receptionEmail;
  ReceptionMiniWiki                     receptionMiniWiki;
  ReceptionOpeningHours                 receptionOpeningHours;
  ReceptionProduct                      receptionProduct;
  ReceptionSalesmen                     receptionSalesmen;
  ReceptionSelector                     receptionSelector;
  ReceptionTelephoneNumbers             receptionTelephoneNumbers;
  ReceptionType                         receptionType;
  ReceptionVATNumbers                   receptionVATNumbers;
  ReceptionWebsites                     receptionWebsites;
  static ReceptionistclientReady        _singleton;
  WelcomeMessage                        welcomeMessage;
  final Model.UIReceptionistclientReady _ui;
  final Controller.Contact              _contactController;
  final Controller.Reception            _receptionController;
  /**
   * Constructor.
   */
  factory ReceptionistclientReady(Model.AppClientState appState,
                                  Model.UIReceptionistclientReady uiReady,
                                  Controller.Contact _contactController,
                                  Controller.Reception _receptionController) {
    if(_singleton == null) {
      _singleton = new ReceptionistclientReady._internal
          (appState, uiReady, _contactController, _receptionController);
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
                                    this._receptionController) {
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

    contexts = new Contexts(new Model.UIContexts());
    help     = new Hint(new Model.UIHint());

    agentInfo = new AgentInfo(new Model.UIAgentInfo(querySelector('#agent-info')));

    contactCalendar = new ContactCalendar
        (uiContactCalendar,
         new Controller.Destination(Context.Home, Widget.ContactCalendar),
         uiContactSelector,
         uiReceptionSelector,
         _contactController);

    contactData = new ContactData
        (new Model.UIContactData(querySelector('#contact-data')),
         new Controller.Destination(Context.Home, Widget.ContactData),
         uiContactSelector,
         uiReceptionSelector);

    calendarEditor = new CalendarEditor
        (new Model.UICalendarEditor(querySelector('#calendar-editor')),
         new Controller.Destination(Context.CalendarEdit, Widget.CalendarEditor),
         uiContactCalendar,
         uiReceptionCalendar);

    contactSelector = new ContactSelector
        (uiContactSelector,
         new Controller.Destination(Context.Home, Widget.ContactSelector),
         uiReceptionSelector,
         _contactController);

    globalCallQueue = new GlobalCallQueue
        (new Model.UIGlobalCallQueue(querySelector('#global-call-queue')),
         new Controller.Destination(Context.Home, Widget.GlobalCallQueue));

    messageArchive = new MessageArchive
        (new Model.UIMessageArchive(querySelector('#message-archive')),
         new Controller.Destination(Context.Messages, Widget.MessageArchive));

    messageArchiveEdit = new MessageArchiveEdit
        (new Model.UIMessageArchiveEdit(querySelector('#message-archive-edit')),
         new Controller.Destination(Context.Messages, Widget.MessageArchiveEdit));

    messageArchiveFilter = new MessageArchiveFilter
        (new Model.UIMessageArchiveFilter(querySelector('#message-archive-filter')),
         new Controller.Destination(Context.Messages, Widget.MessageArchiveFilter));

    messageCompose = new MessageCompose
        (new Model.UIMessageCompose(querySelector('#message-compose')),
         new Controller.Destination(Context.Home, Widget.MessageCompose));

    myCallQueue = new MyCallQueue
        (new Model.UIMyCallQueue(querySelector('#my-call-queue')),
         new Controller.Destination(Context.Home, Widget.MyCallQueue));

    receptionAddresses = new ReceptionAddresses
        (new Model.UIReceptionAddresses(querySelector('#reception-addresses')),
         new Controller.Destination(Context.Homeplus, Widget.ReceptionAddresses),
         uiReceptionSelector);

    receptionAltNames = new ReceptionAltNames
        (new Model.UIReceptionAltNames(querySelector('#reception-alt-names')),
         new Controller.Destination(Context.Homeplus, Widget.ReceptionAltNames),
         uiReceptionSelector);

    receptionBankInfo = new ReceptionBankInfo
        (new Model.UIReceptionBankInfo(querySelector('#reception-bank-info')),
         new Controller.Destination(Context.Homeplus, Widget.ReceptionBankInfo),
         uiReceptionSelector);

    receptionCalendar = new ReceptionCalendar
        (uiReceptionCalendar,
         new Controller.Destination(Context.Home, Widget.ReceptionCalendar),
         uiReceptionSelector,
         this._receptionController);

    receptionCommands = new ReceptionCommands
        (new Model.UIReceptionCommands(querySelector('#reception-commands')),
         new Controller.Destination(Context.Home, Widget.ReceptionCommands),
         uiReceptionSelector);

    receptionEmail = new ReceptionEmail
        (new Model.UIReceptionEmail(querySelector('#reception-email')),
         new Controller.Destination(Context.Homeplus, Widget.ReceptionEmail),
         uiReceptionSelector);

    receptionMiniWiki = new ReceptionMiniWiki
        (new Model.UIReceptionMiniWiki(querySelector('#reception-mini-wiki')),
         new Controller.Destination(Context.Homeplus, Widget.ReceptionMiniWiki),
         uiReceptionSelector);

    receptionOpeningHours = new ReceptionOpeningHours
        (new Model.UIReceptionOpeningHours(querySelector('#reception-opening-hours')),
         new Controller.Destination(Context.Home, Widget.ReceptionOpeningHours),
         uiReceptionSelector);

    receptionProduct = new ReceptionProduct
        (new Model.UIReceptionProduct(querySelector('#reception-product')),
         new Controller.Destination(Context.Home, Widget.ReceptionProduct),
         uiReceptionSelector);

    receptionSalesmen = new ReceptionSalesmen
        (new Model.UIReceptionSalesmen(querySelector('#reception-salesmen')),
         new Controller.Destination(Context.Home, Widget.ReceptionSalesmen),
         uiReceptionSelector);

    receptionSelector = new ReceptionSelector
        (new Controller.Destination(Context.Home, Widget.ReceptionSelector),
         uiReceptionSelector,
         _receptionController);

    receptionTelephoneNumbers = new ReceptionTelephoneNumbers
        (new Model.UIReceptionTelephoneNumbers(querySelector('#reception-telephone-numbers')),
         new Controller.Destination(Context.Homeplus, Widget.ReceptionTelephoneNumbers),
         uiReceptionSelector);

    receptionType = new ReceptionType
        (new Model.UIReceptionType(querySelector('#reception-type')),
         new Controller.Destination(Context.Homeplus, Widget.ReceptionType),
         uiReceptionSelector);

    receptionVATNumbers = new ReceptionVATNumbers
        (new Model.UIReceptionVATNumbers(querySelector('#reception-vat-numbers')),
         new Controller.Destination(Context.Homeplus, Widget.ReceptionVATNumbers),
         uiReceptionSelector);

    receptionWebsites = new ReceptionWebsites
        (new Model.UIReceptionWebsites(querySelector('#reception-websites')),
         new Controller.Destination(Context.Homeplus, Widget.ReceptionWebsites),
         uiReceptionSelector);

    welcomeMessage = new WelcomeMessage
        (new Model.UIWelcomeMessage(querySelector('#welcome-message')),
         uiReceptionSelector);

    _ui.visible = true;

    window.location.hash.isEmpty ? _navigate.goHome() : _navigate.goWindowLocation();
  }
}
