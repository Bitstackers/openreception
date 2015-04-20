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
    List<Command> commands = [new Command.fromJson({'command':'Command 1'}),
                              new Command.fromJson({'command':'Command 2'}),
                              new Command.fromJson({'command':'Command 3'}),
                              new Command.fromJson({'command':'Command 4'}),
                              new Command.fromJson({'command':'Command 5'})];

    _ui.receptions = [new Reception(1, 'Responsum K/S', commands),
                      new Reception(2, 'Bitstackers K/S', commands),
                      new Reception(3, 'Loecke K/S', commands),
                      new Reception(4, 'Another Loecke K/S', commands),
                      new Reception(5, 'Another Responsum K/S', commands),
                      new Reception(6, 'FooBar K/S', commands)];

  }
}
