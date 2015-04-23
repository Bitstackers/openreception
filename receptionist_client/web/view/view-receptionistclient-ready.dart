part of view;

class ReceptionistclientReady {
  final AppClientState                  _appState;
  AgentInfo                             agentInfo;
  CalendarEditor                        calendarEditor;
  ContactCalendar                       contactCalendar;
  ContactData                           contactData;
  ContactSelector                       contactSelector;
  Contexts                              contexts;
  GlobalCallQueue                       globalCallQueue;
  Help                                  help;
  MessageCompose                        messageCompose;
  MyCallQueue                           myCallQueue;
  ReceptionCalendar                     receptionCalendar;
  ReceptionCommands                     receptionCommands;
  ReceptionOpeningHours                 receptionOpeningHours;
  ReceptionProduct                      receptionProduct;
  ReceptionSalesmen                     receptionSalesmen;
  ReceptionSelector                     receptionSelector;
  static ReceptionistclientReady        _singleton;
  WelcomeMessage                        welcomeMessage;
  final Model.UIReceptionistclientReady _ui;

  /**
   * Constructor.
   */
  factory ReceptionistclientReady(AppClientState appState,
                                  Model.UIReceptionistclientReady uiReady) {
    if(_singleton == null) {
      _singleton = new ReceptionistclientReady._internal(appState, uiReady);
    } else {
      return _singleton;
    }
  }

  /**
   * Internal constructor.
   */
  ReceptionistclientReady._internal(AppClientState this._appState,
                                    Model.UIReceptionistclientReady this._ui) {
    _observers();
  }

  /**
   * Observers.
   */
  void _observers() {
    _appState.onStateChange.listen((AppState appState) =>
        appState == AppState.READY ? _runApp() : _ui.visible = false);
  }

  /**
   * Go visible and setup all the app widgets.
   */
  void _runApp() {
    Model.UIContactCalendar   uiContactCalendar   = new Model.UIContactCalendar(querySelector('#contact-calendar'));
    Model.UIContactSelector   uiContactSelector   = new Model.UIContactSelector(querySelector('#contact-selector'));
    Model.UIReceptionCalendar uiReceptionCalendar = new Model.UIReceptionCalendar(querySelector('#reception-calendar'));
    Model.UIReceptionSelector uiReceptionSelector = new Model.UIReceptionSelector(querySelector('#reception-selector'));

    _ui.visible = true;

    help = new Help(new Model.UIHelp());

    contexts = new Contexts(new Model.UIContexts());


    receptionSelector = new ReceptionSelector(uiReceptionSelector,
                                              new Controller.Destination(Context.Home, Widget.ReceptionSelector));

    agentInfo = new AgentInfo(new Model.UIAgentInfo(querySelector('#agent-info')));

    contactSelector = new ContactSelector(uiContactSelector,
                                          new Controller.Destination(Context.Home, Widget.ContactSelector),
                                          uiReceptionSelector);

    contactCalendar = new ContactCalendar(uiContactCalendar,
                                          new Controller.Destination(Context.Home, Widget.ContactCalendar),
                                          uiContactSelector,
                                          uiReceptionSelector);

    contactData = new ContactData(new Model.UIContactData(querySelector('#contact-data')),
                                  new Controller.Destination(Context.Home, Widget.ContactData),
                                  uiContactSelector,
                                  uiReceptionSelector);

    calendarEditor = new CalendarEditor (new Model.UICalendarEditor(querySelector('#calendar-editor')),
                                         new Controller.Destination(Context.CalendarEdit, Widget.CalendarEditor),
                                         uiContactCalendar,
                                         uiReceptionCalendar);

    receptionCalendar = new ReceptionCalendar(uiReceptionCalendar,
                                              new Controller.Destination(Context.Home, Widget.ReceptionCalendar),
                                              uiReceptionSelector);

    receptionCommands = new ReceptionCommands(new Model.UIReceptionCommands(querySelector('#reception-commands')),
                                              new Controller.Destination(Context.Home, Widget.ReceptionCommands),
                                              uiReceptionSelector);

    receptionOpeningHours = new ReceptionOpeningHours(new Model.UIReceptionOpeningHours(querySelector('#reception-opening-hours')),
                                                      new Controller.Destination(Context.Home, Widget.ReceptionOpeningHours),
                                                      uiReceptionSelector);

    receptionProduct = new ReceptionProduct(new Model.UIReceptionProduct(querySelector('#reception-product')),
                                            new Controller.Destination(Context.Home, Widget.ReceptionProduct),
                                            uiReceptionSelector);

    receptionSalesmen = new ReceptionSalesmen(new Model.UIReceptionSalesmen(querySelector('#reception-salesmen')),
                                              new Controller.Destination(Context.Home, Widget.ReceptionSalesmen),
                                              uiReceptionSelector);

    messageCompose = new MessageCompose(new Model.UIMessageCompose(querySelector('#message-compose')),
                                        new Controller.Destination(Context.Home, Widget.MessageCompose));

    // TODO (TL): The following widgets have not yet been UIModel'ified.
//    globalCallQueue       = new GlobalCallQueue();
//    myCallQueue           = new MyCallQueue();

//    welcomeMessage        = new WelcomeMessage();

    window.location.hash.isEmpty ? _navigate.goHome() : _navigate.goWindowLocation();
  }
}
