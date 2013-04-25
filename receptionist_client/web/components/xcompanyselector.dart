import 'dart:html';

import 'package:web_ui/web_ui.dart';

import '../classes/environment.dart' as environment;
import '../classes/model.dart' as model;
import '../classes/storage.dart' as storage;

@observable
class CompanySelector extends WebComponent {
  const String defaultOptionText = 'vælg virksomhed';
  model.OrganizationList organizationList = model.nullOrganizationList;

  void created() {
    storage.organizationList.get((list) => organizationList = list);
  }

  void _selection(Event event) {
    var e = event.target as SelectElement;
    storage.organization.get(int.parse(e.value),
                             (org) => environment.organization.set(org));
  }
}
