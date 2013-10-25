/*                     This file is part of Bob
                   Copyright (C) 2012-, AdaHeads K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of components;

class CompanySelector {
  final       String                 defaultOptionText = 'vælg virksomhed';
              model.Organization     nullOrganization  = model.nullOrganization;
  model.Organization     organization      = model.nullOrganization;
  model.OrganizationList organizationList  = new model.OrganizationList();
  DivElement element;
  SelectElement select;

  CompanySelector(DivElement this.element) {
    select = new SelectElement()
      ..onChange.listen(selection);
    element.children.add(select);

    _registerEventHandlers();
    _initialFill();
  }

  void _initialFill() {
    storage.getOrganizationList()
      .then((model.OrganizationList list) => organizationList = list)
      .catchError((error) => log.critical('CompanySelector._initialFill storage.getOrganizationList failed with ${error}'))
      .whenComplete(render);
  }

  void render() {
    List<OptionElement> options = new List<OptionElement>()
        ..add(new OptionElement()
        ..disabled = true
        ..text = 'Vælg Virksomhed'
        ..selected = organization.id == model.nullOrganization.id);

    if(organizationList != null) {
      for(model.BasicOrganization value in organizationList) {
        options.add(new OptionElement()
                      ..text = '${value.name}'
                      ..selected = organization.id == value.id
                      ..value = value.id.toString());
      }
    }

    select.children
      ..clear()
      ..addAll(options);
  }

  void updateSelected() {
    for(OptionElement option in select.children) {
      option.selected = option.value == organization.id.toString();
    }
  }

  void selection(Event e) {
    SelectElement element = e.target;

    try {
      int id = int.parse(element.value);

      storage.getOrganization(id).then((model.Organization org) {
        event.bus.fire(event.organizationChanged, org);
        log.debug('CompanySelector._selection updated organization to ${organization}');

      }).catchError((error) {
        event.bus.fire(event.organizationChanged, model.nullOrganization);
        log.critical('CompanySelector._selection storage.getOrganization failed with ${error}');

      });
    } on FormatException {
      event.bus.fire(event.organizationChanged, model.nullOrganization);
      log.critical('CompanySelector._selection storage.getOrganization SelectElement has bad value: ${element.value}');
    }
  }

  void _registerEventHandlers() {
    event.bus.on(event.organizationChanged).listen((model.Organization org) {
      organization = org;
      updateSelected();
    });

    event.bus.on(event.organizationListChanged).listen((model.OrganizationList list) {
      //TODO if the interface is busy/receptionist working on a company, This is not the option you are looking for.
      organizationList = list;
      render();
    });
  }
}
