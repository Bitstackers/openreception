import 'dart:async';
import 'dart:html';

import 'package:web_ui/web_ui.dart';

class CompanySelector extends WebComponent {
  var numbers = toObservable(<int>[1,2,3]);

//  created() {
//    new Timer.periodic(new Duration(seconds: 1), (timer) {
//      numbers.add(numbers[numbers.length - 1] + 1);
//      numbers.removeAt(0);
//    });
//  }
}
