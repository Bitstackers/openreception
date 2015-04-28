part of view;

/**
 * TODO (TL): Comment
 */
class ContactSelector extends ViewWidget {
  final Controller.Destination    _myDestination;
  final Model.UIReceptionSelector _receptionSelector;
  final Model.UIContactSelector   _ui;
  final Controller.Contact        _contactController;

  /**
   * Constructor.
   */
  ContactSelector(Model.UIModel this._ui,
                  Controller.Destination this._myDestination,
                  Model.UIReceptionSelector this._receptionSelector,
                  Controller.Contact this._contactController) {
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
   * Render the widget with [reception].
   */
  void render(Model.Reception reception) {
    if(reception.isEmpty) {
      _ui.clear();
    } else {
      _contactController.list(reception)
        .then ((Iterable<Model.Contact> contacts) {

        List<Model.Contact> sortedContacts = contacts.toList()
          ..sort((Model.Contact x , Model.Contact y) =>
              x.fullName.compareTo(y.fullName));

        this._ui.contacts = sortedContacts;
      }).then((_) {
        _ui.selectFirstContact();
      });
    }
  }
}
