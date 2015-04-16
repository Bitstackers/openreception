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
  final UIReceptionistclientReady _ui = new UIReceptionistclientReady('receptionistclient-ready');

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

    help = new Help(new UIHelp());

    contexts = new Contexts(new UIContexts());

    receptionSelector = new ReceptionSelector(new UIReceptionSelector(querySelector('#reception-selector')),
                                              new Place(Context.Home, Widget.ReceptionSelector));

    agentInfo = new AgentInfo(new UIAgentInfo(querySelector('#agent-info')));

    contactSelector = new ContactSelector(new UIContactSelector(querySelector('#contact-selector')),
                      new Place(Context.Home, Widget.ContactSelector));

    contactCalendar = new ContactCalendar(new UIContactCalendar(querySelector('#contact-calendar')),
                                          new Place(Context.Home, Widget.ContactCalendar),
                                          contactSelector);

    contactData = new ContactData(new UIContactData(querySelector('#contact-data')),
                                  new Place(Context.Home, Widget.ContactData),
                                  contactSelector);

    calendarEditor = new CalendarEditor (new UICalendarEditor(querySelector('#calendar-editor')),
                                         new Place(Context.CalendarEdit, Widget.CalendarEditor));

    receptionCalendar = new ReceptionCalendar(new UIReceptionCalendar(querySelector('#reception-calendar')),
                                              new Place(Context.Home, Widget.ReceptionCalendar),
                                              receptionSelector);

    receptionCommands = new ReceptionCommands(new UIReceptionCommands(querySelector('#reception-commands')),
                                              new Place(Context.Home, Widget.ReceptionCommands));

    messageCompose = new MessageCompose(new UIMessageCompose(querySelector('#message-compose')),
                                        new Place(Context.Home, Widget.MessageCompose));

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
