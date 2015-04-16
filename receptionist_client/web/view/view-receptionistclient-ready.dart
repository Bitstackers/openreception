part of view;

class ReceptionistclientReady {
  AppClientState                  _appState;
  AgentInfo                       agentInfo;
  CalendarEditor                  calendarEditor;
  ContactCalendar                 contactCalendar;
  ContactData                     contactData;
  ContactSelector                 contactSelector;
  Contexts                        contexts;
  GlobalCallQueue                 globalCallQueue;
  Help                            help;
  MessageCompose                  messageCompose;
  MyCallQueue                     myCallQueue;
  ReceptionCalendar               receptionCalendar;
  ReceptionCommands               receptionCommands;
  ReceptionOpeningHours           receptionOpeningHours;
  ReceptionProduct                receptionProduct;
  ReceptionSalesCalls             receptionSalesCalls;
  ReceptionSelector               receptionSelector;
  static ReceptionistclientReady  _singleton;
  WelcomeMessage                  welcomeMessage;

  final Model.UIReceptionistclientReady _ui = new Model.UIReceptionistclientReady('receptionistclient-ready');

  /**
   * Constructor.
   */
  factory ReceptionistclientReady(AppClientState appState) {
    if(_singleton == null) {
      _singleton = new ReceptionistclientReady._internal(appState);
    } else {
      return _singleton;
    }
  }

  /**
   * Internal constructor.
   */
  ReceptionistclientReady._internal(AppClientState appState) {
    _appState = appState;
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
    _ui.visible = true;

    help = new Help(new Model.UIHelp());

    contexts = new Contexts(new Model.UIContexts());

    Model.UIReceptionSelector uiReceptionSelector = new Model.UIReceptionSelector(querySelector('#reception-selector'));
    receptionSelector = new ReceptionSelector(uiReceptionSelector,
                                              new Controller.Place(Context.Home, Widget.ReceptionSelector));

    agentInfo = new AgentInfo(new Model.UIAgentInfo(querySelector('#agent-info')));

    Model.UIContactSelector uiContactSelector = new Model.UIContactSelector(querySelector('#contact-selector'));
    contactSelector = new ContactSelector(uiContactSelector,
                                          new Controller.Place(Context.Home, Widget.ContactSelector),
                                          uiReceptionSelector);

    contactCalendar = new ContactCalendar(new Model.UIContactCalendar(querySelector('#contact-calendar')),
                                          new Controller.Place(Context.Home, Widget.ContactCalendar),
                                          uiContactSelector);

    contactData = new ContactData(new Model.UIContactData(querySelector('#contact-data')),
                                  new Controller.Place(Context.Home, Widget.ContactData),
                                  uiContactSelector);

    calendarEditor = new CalendarEditor (new Model.UICalendarEditor(querySelector('#calendar-editor')),
                                         new Controller.Place(Context.CalendarEdit, Widget.CalendarEditor));

    receptionCalendar = new ReceptionCalendar(new Model.UIReceptionCalendar(querySelector('#reception-calendar')),
                                              new Controller.Place(Context.Home, Widget.ReceptionCalendar),
                                              uiReceptionSelector);

    receptionCommands = new ReceptionCommands(new Model.UIReceptionCommands(querySelector('#reception-commands')),
                                              new Controller.Place(Context.Home, Widget.ReceptionCommands));

    messageCompose = new MessageCompose(new Model.UIMessageCompose(querySelector('#message-compose')),
                                        new Controller.Place(Context.Home, Widget.MessageCompose));

    // TODO (TL): The following widgets have not yet been UIModel'ified.
//    globalCallQueue       = new GlobalCallQueue();
//    myCallQueue           = new MyCallQueue();
//    receptionOpeningHours = new ReceptionOpeningHours();
//    receptionProduct      = new ReceptionProduct();
//    receptionSalesCalls   = new ReceptionSalesCalls();
//    welcomeMessage        = new WelcomeMessage();

    window.location.hash.isEmpty ? _navigate.goHome() : _navigate.goWindowLocation();
  }
}
