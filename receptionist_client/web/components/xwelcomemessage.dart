import 'dart:html';

import 'package:web_ui/web_ui.dart';

import '../classes/environment.dart';
import '../classes/model.dart';

@observable
class WelcomeMessage extends WebComponent {
  Organization organization = nullOrganization;

  void created() {
    environment.onOrganizationChange.listen((value) => organization = value);
  }
}
