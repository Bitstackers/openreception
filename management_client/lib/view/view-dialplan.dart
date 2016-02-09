part of management_tool.view;

class Dialplan {
  final DivElement element = new DivElement()
    ..classes = ['dialplan-view-widget'];
  final InputElement _noteInput = new InputElement()..value = '';
  final UListElement _closedEntriesUl = new UListElement();
  final UListElement _extraExtensions = new UListElement();
  final ButtonElement _addHourActionButton = new ButtonElement()..text = 'Add';
  final ButtonElement _saveButton = new ButtonElement()..text = 'Save';

  final HourActions _hourActionsView = new HourActions();

  final controller.Dialplan _dialplanController;

  final TextAreaElement _closedActionsInput = new TextAreaElement()
    ..classes.add('dialplan-action');

  /**
   *
   *
   */
  set dialplan(model.ReceptionDialplan rdp) {
    _closedActionsInput.value =
        rdp.defaultActions.map((a) => a.toJson()).join('\n');

    _noteInput.value = rdp.note;
    _hourActionsView.hourActions = rdp.open;
    _closedEntriesUl.children = new List<Element>()
      ..addAll(rdp.defaultActions.map(actionTemplate));
    _extraExtensions.children = new List<Element>()
      ..addAll(rdp.extraExtensions.map(extensionTemplate));
  }


  /**
   *
   * TODO: Implement
   */
  model.ReceptionDialplan get dialplan =>
      new model.ReceptionDialplan()..note = _noteInput.value;


  /**
   *
   */
  void observers () {
    _addHourActionButton.onClick.listen((_) {
      _hourActionsView.addHourAction(new model.HourAction());
    });

    ///TODO: distinguish between create and update.
    _saveButton.onClick.listen((_) {
      _dialplanController.save(dialplan);
    });

  }

  /**
    *
    */
  Dialplan(this._dialplanController) {

    element.children = [
      _saveButton,
      new HeadingElement.h3()..text = 'Opening hours',
      _hourActionsView.element,
      _addHourActionButton,
      new HeadingElement.h3()..text = 'When closed',
      _closedActionsInput,
      new HeadingElement.h3()..text = 'Extra extensions',
      new HeadingElement.h3()..text = 'Note',
      _noteInput,
      _extraExtensions
    ];
  }
}

class HourActions {
  final UListElement element = new UListElement()..classes = ['hour-actions'];

  final List<HourAction> hourActions = [];

  ///
  final TextAreaElement _actionsInput = new TextAreaElement()
    ..classes.add('dialplan-action');

  /**
   *
   */
  void set hourActions(Iterable<model.HourAction> has) {
    hourActions
      ..clear()
      ..addAll(has.map((ha) => new HourAction()..action = ha));

    element.children = []..addAll(hourActions.map((a) => a.element));
  }

  void addHourAction(model.HourAction ha) {
    final view = new HourAction()..action = ha;
    hourActions.add(view);

    element.children.add(view.element);

  }
}

class HourAction {
  final DivElement element = new DivElement()..classes = ['hour-action'];

  final ButtonElement _deleteButton = new ButtonElement()..classes = ['delete']..text = 'Delete';
  final InputElement _openHourInput = new InputElement()..value = '';

  ///
  final TextAreaElement _actionsInput = new TextAreaElement()
    ..classes.add('dialplan-action');

  /**
   *
   */
  void set action(model.HourAction ha) {
    _openHourInput.value = ha.hours.map((oh) => oh.toJson()).join(',');
    _actionsInput.value = ha.actions.map((a) => a.toJson()).join('\n');
  }

  /**
   *
   */
  HourAction() {
    _deleteButton.onClick.listen((_)  {
       element.remove();
    });

    element.children = [
      new HeadingElement.h3()..text = 'Opening hour',
      _openHourInput,
      new HeadingElement.h3()..text = 'Actions',
      _actionsInput,
      _deleteButton
    ];
  }
}
