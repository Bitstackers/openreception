import 'dart:html';

import 'package:web_ui/web_ui.dart';

import '../classes/environment.dart';
import '../classes/model.dart';
import '../classes/storage.dart';

@observable
class CompanySelector extends WebComponent {
  OrganizationList organizationList = nullOrganizationList;
  String defaultOptionText = 'vælg virksomhed';

  void created() {
    storageOrganization.getList((list) => organizationList = list);
  }

  void inserted() {
    _root.onChange.listen(_selection);
  }

  void _selection(Event event) {
    var e = event.target as SelectElement;
    storageOrganization.get(int.parse(e.value),
        (org) => environment.setOrganization(org));
  }
}
