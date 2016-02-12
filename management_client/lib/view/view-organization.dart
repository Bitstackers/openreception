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
    ..value = model.Organization.noID.toString();
  final ButtonElement _saveButton = new ButtonElement()
    ..classes.add('save')
    ..text = 'Gem';
  final ButtonElement _deleteButton = new ButtonElement()
    ..text = 'Slet'
    ..classes.add('delete');

  final HeadingElement _heading = new HeadingElement.h2();

  final InputElement _billingTypeInput = new InputElement()..value = '';
  final InputElement _flagInput = new InputElement()..value = '';
  final InputElement _nameInput = new InputElement()..value = '';

  void set organization(model.Organization org) {
    _id = org.id;
    _billingTypeInput.value = org.billingType;
    _flagInput.value = org.flag;
    _nameInput.value = org.fullName;

    element.hidden = false;

    if (organization.id != model.Organization.noID) {
      _heading.text = 'Retter organisation: "${org.fullName}" - (oid: ${organization.id})';
      _saveButton.disabled = true;
    } else {
      _heading.text = 'Opretter ny organisation';
      _saveButton.disabled = false;
    }

    _deleteButton.disabled = !_saveButton.disabled;
  }

  /**
   *
   */
  model.Organization get organization => new model.Organization.empty()
    ..id = _id
    ..billingType = _billingTypeInput.value
    ..flag = _flagInput.value
    ..fullName = _nameInput.value;

  /**
   *
   */
  Organization(this._orgController) {
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
            ..text = 'Regnings Type'
            ..htmlFor = _billingTypeInput.id,
          _billingTypeInput
        ],
      new DivElement()
        ..children = [
          new LabelElement()
            ..text = 'Flag'
            ..htmlFor = _flagInput.id,
          _flagInput
        ],
    ];

    _observers();
  }

  /**
   *
   */
  void _observers() {
    Iterable<InputElement> inputs =
        element.querySelectorAll('input') as Iterable<InputElement>;

    inputs.forEach((InputElement ine) {
      ine.onInput.listen((_) {
        _saveButton.disabled = false;
        _deleteButton.disabled = !_saveButton.disabled;
      });
    });

    _deleteButton.onClick.listen((_) async {

      if(_deleteButton.text.toLowerCase() == 'slet') {
        _deleteButton.text = 'Bekræft sletning?';
        return;
      }
      try {
        await _orgController.remove(organization.id);
        _changeBus.fire(new OrganizationChange.delete(organization));
        element.hidden = true;
        notify.info('Organisationen blev slettet.');

      } catch (error) {
        notify.error('Der skete en fejl, så organisationen blev ikke slettet.');
        _log.severe('Tried to remove an organization, but got: $error');
        element.hidden = false;
      }
      _deleteButton.text = 'Slet';
    });

    _saveButton.onClick.listen((_) async {
      element.hidden = true;
      if (organization.id == model.Organization.noID) {
        try {
          model.Organization newOrg = await _orgController.create(organization);
          _changeBus.fire(new OrganizationChange.create(newOrg));
          notify.info('Organisationen blev oprettet.');
        } catch (error) {
          notify.error(
              'Der skete en fejl, så organisationen blev ikke oprettet.');
          _log.severe('Tried to create an new organization, but got: $error');
          element.hidden = false;
        }
      } else {
        try {
          await _orgController.update(organization);
          _changeBus.fire(new OrganizationChange.update(organization));
          notify.info('Ændringerne blev gemt.');
        } catch (error) {
          notify.error(
              'Der skete en fejl i forbindelse med forsøget på at gemme ændringerne til organisationen.');
          _log.severe('Tried to update an organization, but got: $error');
          element.hidden = false;
        }
      }
    });
  }
}
