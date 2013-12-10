library BobLogin;

import 'dart:html';

import '../components.dart';
import 'configuration.dart';
import 'events.dart' as event;
import 'logger.dart';
import 'notification.dart';
import 'protocol.dart' as protocol;
import 'state.dart';

class BobLogin {
  DivElement element;
  Box box;
  SpanElement header;

  BobLogin(DivElement this.element) {
    assert(element != null);
    header = new SpanElement()
      ..text = 'Log ind';

    event.bus.on(event.stateUpdated).listen((State value) {
      element.classes.toggle('hidden', !value.isUnknown);
    });

    protocol.userslist().then((protocol.Response response) {
      if(response.status == protocol.Response.OK) {
        UListElement list = new UListElement();
        List users = response.data['users'];
        list.children.addAll(users.map(makeUserNode));
        box = new Box.withHeader(element, header, list);
      } else {
        ParagraphElement message = new ParagraphElement()..text = 'The list of users was unaccessable';
        box = new Box.withHeader(element, header, message);
      }
    });
  }

  makeUserNode(Map user) => new LIElement()
    ..text = user['name']
    ..onClick.listen((_) {
      notification.initialize();
      configuration.initialize();
      element.classes.add('hidden');

      int userId = 1;
      protocol.login(userId).then((protocol.Response<Map> value) {
        if(value.status == protocol.Response.OK) {
          log.debug('Bob.dart ------- Success Logged in---------');
        } else {
          log.error('Bob.dart Did not log in.');
        }
      }).catchError((e) {
        log.error('Bob.dart: CatchError $e');
      });
    });
}