import 'dart:html';

import 'package:web_ui/web_ui.dart';

import '../classes/environment.dart';
import '../classes/model.dart' as model;
import '../classes/storage.dart' as storage;

@observable
class CompanySelector extends WebComponent {
  String defaultOptionText = 'vælg virksomhed';
  model.OrganizationList organizationList = model.nullOrganizationList;

  void created() {
    storage.OrganizationList.get((list) => organizationList = list);
  }

  void inserted() {
    this.onChange.listen(_selection);
  }

  void _selection(Event event) {
    var e = event.target as SelectElement;

    storage.Organization.get(int.parse(e.value),
                            (org) => environment.setOrganization(org));
  }
}
