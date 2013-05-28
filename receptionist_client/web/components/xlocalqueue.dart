import 'dart:html';

import 'package:intl/intl.dart';
import 'package:web_ui/web_ui.dart';

import '../classes/environment.dart' as environment;
import '../classes/logger.dart';
import '../classes/model.dart' as model;
import '../classes/notification.dart' as notify;
import '../classes/protocol.dart' as protocol;

class LocalQueue extends WebComponent {
  String title = 'Lokal kø';

  List<model.Call> calls = toObservable(<model.Call>[]);

  void created() {
    _initialFill();
  }

  void _initialFill() {
    // dummy calls
    calls.add(new model.Call({'id':'43','start':'${new DateFormat("y-MM-dd kk:mm:ss").format(new DateTime.now())}'}));
    calls.add(new model.Call({'id':'42','start':'${new DateFormat("y-MM-dd kk:mm:ss").format(new DateTime.now().subtract(new Duration(seconds:27)))}'}));

    calls.sort();
  }
}
