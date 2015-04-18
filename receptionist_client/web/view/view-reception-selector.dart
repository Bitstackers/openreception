part of view;

class ReceptionSelector extends ViewWidget {
  final Controller.Place          _myPlace;
  final Model.UIReceptionSelector _ui;

  /**
   * Constructor.
   */
  ReceptionSelector(Model.UIModel this._ui, Controller.Place this._myPlace) {
    _ui.help = 'alt+v';

    _observers();

    test(); // TODO (TL): Get rid of this testing code...
  }

  @override Controller.Place get myPlace => _myPlace;
  @override Model.UIModel    get ui      => _ui;

  @override void onBlur(_){}
  @override void onFocus(_){}

  /**
   * Activate this widget if it's not already activated.
   */
  void activateMe(_) {
    navigateToMyPlace();
  }

  /**
   * Observers.
   */
  void _observers() {
    _navigate.onGo.listen(setWidgetState);

    _ui.onClick    .listen(activateMe);
    _hotKeys.onAltV.listen(activateMe);
  }

  /// TODO (TL): Get rid of this. It's just here to test stuff. These
  /// [Reception] objects should come from one of Kims service methods.
  void test() {
    _ui.receptions = [new Reception(1, 'Responsum K/S'),
                      new Reception(2, 'Bitstackers K/S'),
                      new Reception(3, 'Loecke K/S'),
                      new Reception(4, 'Another Loecke K/S'),
                      new Reception(5, 'Another Responsum K/S'),
                      new Reception(6, 'FooBar K/S')];

  }
}
