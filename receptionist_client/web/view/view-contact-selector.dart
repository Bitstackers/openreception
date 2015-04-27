part of view;

class ContactSelector extends ViewWidget {
  final Controller.Destination    _myDestination;
  final Model.UIReceptionSelector _receptionSelector;
  final Model.UIContactSelector   _ui;

  /**
   * Constructor.
   */
  ContactSelector(Model.UIModel this._ui,
                  Controller.Destination this._myDestination,
                  Model.UIReceptionSelector this._receptionSelector) {
    _ui.setHint('alt+s');
    _observers();
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

    _hotKeys.onAltS.listen(activateMe);

    _ui.onClick.listen(activateMe);

    _receptionSelector.onSelect.listen(render);
  }

  /**
   * Render the widget with [Contact]s.
   */
  void render(Reception reception) {
    if(reception.isNull) {
      _ui.clear();
    } else {
      _ui.contacts = [new Contact.fromJson({'id': 1, 'name': 'Trine Løcke Snøcke ${(reception.name)}', 'receptionId': 2, 'tags': ['Oplæring','Service']}),
                      new Contact.fromJson({'id': 2, 'name': 'Hoop Karaoke ${(reception.name)}', 'receptionId': 2, 'tags': ['Entertainment', 'International Business', 'teknik']}),
                      new Contact.fromJson({'id': 3, 'name': 'Thomas Løcke ${(reception.name)}', 'receptionId': 2, 'tags': ['Teknik', 'Farum', 'salg']}),
                      new Contact.fromJson({'id': 4, 'name': 'Simpleton McNuggin ${(reception.name)}', 'receptionId': 2, 'tags': ['Teknik', 'Glostrup', 'Service', 'løn', 'kreditor']})];

      _ui.selectFirstContact();
    }
  }
}
