library model;

import 'dart:convert';

import 'logger.dart' as log;

part 'model/audiofile.dart';
part 'model/contact.dart';
part 'model/organization.dart';
part 'model/reception.dart';
part 'model/reception_contact.dart';
part 'model/custom_reception_contact.dart';
part 'model/phone.dart';
part 'model/reception_contact_reduced_reception.dart';

String stringFromJson(Map json, String key) {
  if (json.containsKey(key)) {
    return json[key];
  } else {
    log.error('Key "$key" not found in "${json}"');
    return null;
  }
}

List<String> priorityListFromJson(Map json, String key) {
  try {
    if (json.containsKey(key) && json[key] is List) {
      List<Map> rawList = json[key];
      List<String> list = new List<String>();

      rawList.sort((a, b) => a['priority'] - b['priority']);
      //Sorte by priority.
      for (Map item in json[key]) {
        list.add(item['value']);
      }
      return list;
    } else {
      return null;
    }
  } catch (e) {
    log.error('"$e key: "$key" json: "$json"');
    return null;
  }
}

List priorityListToJson(List<String> list) {
  List<Map> result = new List<Map>();

  int priority = 1;
  for (String item in list) {
    result.add({
      'priority': priority,
      'value': item
    });
  }

  return result;
}
