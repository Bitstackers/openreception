part of model;

class UIContactData extends UIModel {
  final DivElement _root;

  UIContactData(DivElement this._root);

  UListElement get additionalInfoList  => _root.querySelector('.additional-info');
  UListElement get backupList          => _root.querySelector('.backup');
  UListElement get commandsList        => _root.querySelector('.commands');
  UListElement get departmentList      => _root.querySelector('.department');
  UListElement get emailAddressesList  => _root.querySelector('.email-addresses');
  UListElement get relationsList       => _root.querySelector('.relations');
  UListElement get responsibilityList  => _root.querySelector('.responsibility');
  OListElement get telephoneNumberList => _root.querySelector('.telephone-number');
  UListElement get titleList           => _root.querySelector('.title');
  UListElement get workHoursList       => _root.querySelector('.work-hours');

  @override
  HtmlElement get root => _root;
}
