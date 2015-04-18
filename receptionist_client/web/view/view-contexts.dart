part of view;

class Contexts {
  final Model.UIContexts _ui;

  /**
   * Constructor.
   */
  Contexts(Model.UIModel this._ui) {
    _observers();
  }

  /**
   * Observers.
   */
  void _observers() {
    _navigate.onGo.listen(_ui.toggleContext);

    _hotKeys.onAltQ.listen((_) => _navigate.goHome());
    _hotKeys.onAltW.listen((_) => _navigate.goHomeplus());
    _hotKeys.onAltE.listen((_) => _navigate.goMessages());
  }
}
