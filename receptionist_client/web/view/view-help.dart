part of view;

class Help {
  UIHelp _ui;

  Help(UIHelp this._ui) {
    registerEventListeners();
  }

  void registerEventListeners() {
    _hotKeys.onF1.listen((_) => _ui.toggleHelp());
  }
}
