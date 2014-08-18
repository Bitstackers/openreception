part of model;

class CdrEntry {
  String uuid;
  bool inbound;
  int reception_id;
  String extension;
  int duration;
  int waitTime;
  DateTime started_at;

  int owner;
  int contact_id;

  Map json;

  CdrEntry.fromJson(Map this.json) {
    Map variables = json['variables'];

    uuid = variables['uuid'];
    inbound = variables['direction'] == 'inbound';
    reception_id = int.parse(variables['reception_id']);

    if(json['callflow'] is List) {
      List<Map> callFlow = json['callflow'];
      extension = callFlow.firstWhere((Map map) => map['profile_index'] == '1')['caller_profile']['destination_number'];
    } else {
      extension = json['callflow']['caller_profile']['destination_number'];
    }

    duration = int.parse(variables['billsec']);
    waitTime = int.parse(variables['waitsec']);
    started_at = new DateTime.fromMillisecondsSinceEpoch(int.parse(json['variables']['start_epoch'])*1000);

    if(variables.containsKey('owner')) {
      owner = int.parse(variables['owner']);
    }

    if(variables.containsKey('contact_id')) {
      contact_id = int.parse(variables['contact_id']);
    }
  }
}
