part of management_tool.view;

class Organization {
  final DivElement element = new DivElement()
    ..classes = ['organization-view-widget'];

  final InputElement _idInput = new InputElement()
    ..value = model.Organization.noID.toString();

  int get _id => int.parse(_idInput.value);
  void set _id(int newId) {
    _idInput.value = newId.toString();
  }

  final InputElement _billingTypeInput = new InputElement()..value = '';
  final CheckboxInputElement _activeInput = new CheckboxInputElement()
    ..checked = true;
  final InputElement _flagInput = new InputElement()..value = '';
  final InputElement _nameInput = new InputElement()..value = '';

  void set organization(model.Organization org) {
    _id = org.id;
    _billingTypeInput.value = org.billingType;
    _flagInput.value = org.flag;
    _nameInput.value = org.fullName;
  }

  model.Organization get organization => new model.Organization.empty()
    ..id = _id
    ..billingType = _billingTypeInput.value
    ..flag = _flagInput.value
    ..fullName = _nameInput.value;

  Organization() {
    element.children = [
      _idInput,
      new HeadingElement.h3()..text = 'Active',
      _activeInput,
      new HeadingElement.h3()..text = 'Name',
      _nameInput,
      new HeadingElement.h3()..text = 'Billing type',
      _billingTypeInput,
      new HeadingElement.h3()..text = 'flag',
      _flagInput,
    ];
  }
}
