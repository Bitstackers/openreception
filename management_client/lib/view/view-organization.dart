part of management_tool.view;

class OrganizationChange {
  final Change type;
  final model.Organization organization;

  OrganizationChange.create(this.organization) : type = Change.created;
  OrganizationChange.delete(this.organization) : type = Change.deleted;
  OrganizationChange.update(this.organization) : type = Change.updated;
}

/**
 *
 */
class Organization {
  final DivElement element = new DivElement()
    ..classes = ['organization', 'page']
    ..hidden = true;

  final Logger _log = new Logger('$_libraryName.Organization');
  final controller.Organization _orgController;

  Stream<OrganizationChange> get changes => _changeBus.stream;
  final Bus<OrganizationChange> _changeBus = new Bus<OrganizationChange>();

  int get _id => int.parse(_idInput.value);
  void set _id(int newId) {
    _idInput.value = newId.toString();
  }

  final LabelElement _oidLabel = new LabelElement()..text = 'orgid:??';
  final HiddenInputElement _idInput = new HiddenInputElement()
    ..value = model.Organization.noId.toString();
  final ButtonElement _saveButton = new ButtonElement()
    ..classes.add('save')
    ..text = 'Gem';
  final ButtonElement _deleteButton = new ButtonElement()
    ..text = 'Slet'
    ..classes.add('delete');

  ObjectHistory _historyView;
  final AnchorElement _historyToggle = new AnchorElement()
    ..href = '#history'
    ..text = 'Vis historik';

  final HeadingElement _heading = new HeadingElement.h2();

  final InputElement _notesInput = new InputElement()..value = '';
  final InputElement _nameInput = new InputElement()..value = '';

  void set organization(model.Organization org) {
    _id = org.id;
    _notesInput.value = org.notes.join(', ');
    _nameInput.value = org.name;

    element.hidden = false;

    if (organization.id != model.Organization.noId) {
      _heading.text =
          'Retter organisation: "${org.name}" - (oid: ${organization.id})';
      _saveButton.disabled = true;
    } else {
      _heading.text = 'Opretter ny organisation';
      _saveButton.disabled = false;
    }
    _deleteButton.text = 'Slet';
    _deleteButton.disabled = !_saveButton.disabled;
  }

  /**
   *
   */
  model.Organization get organization => new model.Organization.empty()
    ..id = _id
    ..notes = new List<String>.from(
        _notesInput.value.split(',').map((str) => str.trim()))
    ..name = _nameInput.value;

  /**
   *
   */
  Organization(this._orgController) {
    _historyView = new ObjectHistory();
    _historyView.element.hidden = true;
    _historyToggle..text = 'Vis historik';

    element.children = [
      _saveButton,
      _deleteButton,
      _heading,
      _idInput,
      new DivElement()
        ..children = [
          new LabelElement()
            ..text = 'Navn'
            ..htmlFor = _nameInput.id,
          _nameInput
        ],
      new DivElement()
        ..children = [
          new LabelElement()
            ..text = 'Noter'
            ..htmlFor = _notesInput.id,
          _notesInput
        ],
      _historyToggle,
      _historyView.element
    ];

    _observers();
  }

  /**
   *
   */
  void _observers() {
    _historyToggle.onClick.listen((_) async {
      await _orgController.changes(organization.id).then((c) {
        _historyView.commits = c;
      });

      _historyView.element.hidden = !_historyView.element.hidden;

      _historyToggle.text =
          _historyView.element.hidden ? 'Vis historik' : 'Skjul historik';
    });

    Iterable<InputElement> inputs =
        element.querySelectorAll('input') as Iterable<InputElement>;

    inputs.forEach((InputElement ine) {
      ine.onInput.listen((_) {
        _saveButton.disabled = false;
        _deleteButton.disabled = !_saveButton.disabled;
      });
    });

    _deleteButton.onClick.listen((_) async {
      if (_deleteButton.text.toLowerCase() == 'slet') {
        _deleteButton.text = 'Bekræft sletning af oid: ${organization.id}?';
        return;
      }
      try {
        await _orgController.remove(organization.id);
        _changeBus.fire(new OrganizationChange.delete(organization));
        element.hidden = true;
        notify.success('Organisationen blev slettet', organization.name);
      } catch (error) {
        notify.error('Der skete en fejl, så organisationen blev ikke slettet.',
            'Fejl: $error');
        _log.severe('Tried to remove an organization, but got: $error');
        element.hidden = false;
      }
      _deleteButton.text = 'Slet';
    });

    _saveButton.onClick.listen((_) async {
      element.hidden = true;
      if (organization.id == model.Organization.noId) {
        try {
          model.OrganizationReference newOrg =
              await _orgController.create(organization);
          _changeBus.fire(new OrganizationChange.create(
              await _orgController.get(newOrg.id)));
          notify.success('Organisationen blev oprettet', newOrg.name);
        } catch (error) {
          notify.error(
              'Der skete en fejl, så organisationen blev ikke oprettet',
              'Fejl: $error');
          _log.severe('Tried to create an new organization, but got: $error');
          element.hidden = false;
        }
      } else {
        try {
          await _orgController.update(organization);
          _changeBus.fire(new OrganizationChange.update(organization));
          notify.success('Ændringerne blev gemt', organization.name);
        } catch (error) {
          notify.error('Kunne ikke gemme ændringerne til organisationen',
              'Fejl: $error');
          _log.severe('Tried to update an organization, but got: $error');
          element.hidden = false;
        }
      }
    });
  }
}
