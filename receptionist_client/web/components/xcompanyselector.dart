import 'dart:html';

import 'package:web_ui/web_ui.dart';

import '../classes/environment.dart' as environment;
import '../classes/model.dart' as model;
import '../classes/storage.dart' as storage;

@observable
class CompanySelector extends WebComponent {
  String defaultOptionText = 'vælg virksomhed';
  model.OrganizationList organizationList = model.nullOrganizationList;
  model.Organization get _selectedOrganization => environment.organization.current;

  void created() {
    storage.organizationList.get((list) => organizationList = list);
    environment.organization.onChange.listen((org) => (query('[value="${org.id}"]') as OptionElement).selected = true);
  }

  void inserted() {
    this.onChange.listen(_selection);
  }

  void _selection(Event event) {
    var e = event.target as SelectElement;

    storage.organization.get(int.parse(e.value),
                            (org) => environment.organization.set(org));
  }
}
