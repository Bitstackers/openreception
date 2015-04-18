part of view;

class Help {
  final Model.UIHelp _ui;

  /**
   * Constructor.
   */
  Help(Model.UIHelp this._ui) {
    _observers();
  }

  /**
   * Observers.
   */
  void _observers() {
    _hotKeys.onF1.listen((_) => _ui.toggleHelp());
  }
}
