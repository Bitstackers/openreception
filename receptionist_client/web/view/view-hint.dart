part of view;

class Hint {
  final Model.UIHint _ui;

  /**
   * Constructor.
   */
  Hint(Model.UIHint this._ui) {
    _observers();
  }

  /**
   * Observers.
   */
  void _observers() {
    _hotKeys.onF1.listen((_) => _ui.toggleHint());
  }
}
