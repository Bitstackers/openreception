part of view;

class Help {
  Model.UIHelp _ui;

  Help(Model.UIHelp this._ui) {
    _observers();
  }

  void _observers() {
    _hotKeys.onF1.listen((_) => _ui.toggleHelp());
  }
}
