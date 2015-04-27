part of view;

/**
 * TODO (TL): Comment
 */
class WelcomeMessage extends ViewWidget {
  final Model.UIReceptionSelector _receptionSelector;
  final Model.UIWelcomeMessage    _ui;

  /**
   * Constructor.
   */
  WelcomeMessage(Model.UIModel this._ui,
                 Model.UIReceptionSelector this._receptionSelector) {
    _observers();
  }

  @override Controller.Destination get myDestination => null;
  @override Model.UIModel          get ui            => _ui;

  @override void onBlur(_){}
  @override void onFocus(_){}

  /**
   * Observers.
   */
  void _observers() {
    _receptionSelector.onSelect.listen(render);
  }

  /**
   * Render the widget with [reception].
   */
  void render(Reception reception) {
    if(reception.isNull) {
      _ui.clear();
    } else {
      _ui.greeting = 'Velkommen til ${reception.name}';
    }
  }
}
