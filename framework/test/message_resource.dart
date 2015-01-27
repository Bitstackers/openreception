//import 'dart:async';

import 'package:unittest/unittest.dart';
import 'package:unittest/html_config.dart' as HTML;

import '../lib/model.dart'      as Model;
//import '../lib/storage.dart'    as Storage;
//import '../lib/service.dart'    as Service;
//import '../lib/service-io.dart' as ServiceIO;
//import '../lib/service-html.dart' as ServiceHTML;


void main() {

  HTML.useHtmlConfiguration();

/*  test('Service.MessageResource.singleMessage', () =>
      expect(Service.MessageResource.single(Uri.parse('http://test/'), 5),
          equals(Uri.parse('http://test/message/5'))));

  Storage.Message store = new Service.RESTMessageStore
      (Uri.parse('http://localhost:4040'),
       'feedabbadeadbeef0',
       new ServiceHTML.Client());
*/
  test('Exception type', () {
      expect(()=> throw 'X',
      throwsA(new isInstanceOf<String>()));
  });
/*
  test('Service.IO.get (non-existing ID)', () =>
    expect(store.get(-1),
           throwsA(new isInstanceOf<Storage.NotFound>())));

  test('Service.IO.get (existing ID)', () {
      return store.get(1).then((message) {
        expect(message.ID, equals (new Model.Message.stub(1).ID));
    });
  });
  */
}
