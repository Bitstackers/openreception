import 'dart:html';

import 'package:web_ui/web_ui.dart';

import '../classes/environment.dart' as environment;
import '../classes/model.dart' as model;
import '../classes/storage.dart' as storage;

@observable
class CompanySelector extends WebComponent {
  model.OrganizationList organizationList = model.nullOrganizationList;

  String get currentOrgId => environment.organization.current.id.toString();

  void created() {
    storage.organizationList.get((list) => organizationList = list);
  }

  void _selection(Event event) {
    var e = event.target as SelectElement;
    storage.organization.get(int.parse(e.value),
                             (org) => environment.organization.set(org));
  }
}
