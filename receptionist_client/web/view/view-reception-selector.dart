part of view;

/**
 * TODO (TL): Comment
 */
class ReceptionSelector extends ViewWidget {
  final Controller.Destination    _myDestination;
  final Model.UIReceptionSelector _ui;

  /**
   * Constructor.
   */
  ReceptionSelector(Model.UIModel this._ui,
                    Controller.Destination this._myDestination) {
    _observers();

    test(); // TODO (TL): Get rid of this testing code...
  }

  @override Controller.Destination get myDestination => _myDestination;
  @override Model.UIModel          get ui            => _ui;

  @override void onBlur(_){}
  @override void onFocus(_){}

  /**
   * Activate this widget if it's not already activated.
   */
  void activateMe(_) {
    navigateToMyDestination();
  }

  /**
   * Observers.
   */
  void _observers() {
    _navigate.onGo.listen(setWidgetState);

    _hotKeys.onAltV.listen(activateMe);

    _ui.onClick.listen(activateMe);
  }

  /// TODO (TL): Get rid of this. It's just here to test stuff. These
  /// [Reception] objects should come from one of Kims service methods.
  void test() {
    List<String> commands = ['Command 1',
                             'Command 2',
                             'Command 3',
                             'Command 4',
                             'Command 5'];

    String product = 'Vi sælger gummiænder og andet hurlumhej til fester i badekar\nFooBar og stads';

    List<String> openingHours = ['Opening hour 1',
                                 'Opening hour 2',
                                 'Opening hour 3',
                                 'Opening hour 4',
                                 'Opening hour 5'];

    List<String> salesMen = ['Salesmen 1',
                             'Salesmen 2',
                             'Salesmen 3',
                             'Salesmen 4',
                             'Salesmen 5'];

    _ui.receptions = [new Reception(1, 'Responsum K/S')
                        ..commands = commands
                        ..openingHours = openingHours
                        ..product = product
                        ..salesMen = salesMen
                      ,
                      new Reception(2, 'Bitstackers K/S')
                        ..commands = commands
                        ..openingHours = openingHours
                        ..product = product
                        ..salesMen = salesMen
                      ,
                      new Reception(3, 'Loecke K/S')
                        ..commands = commands
                        ..openingHours = openingHours
                        ..product = product
                        ..salesMen = salesMen
                      ,
                      new Reception(4, 'Another Loecke K/S')
                        ..commands = commands
                        ..openingHours = openingHours
                        ..product = product
                        ..salesMen = salesMen
                      ,
                      new Reception(5, 'Another Responsum K/S')
                        ..commands = commands
                        ..openingHours = openingHours
                        ..product = product
                        ..salesMen = salesMen
                      ,
                      new Reception(6, 'FooBar K/S')
                        ..commands = commands
                        ..openingHours = openingHours
                        ..product = product
                        ..salesMen = salesMen];

  }
}
