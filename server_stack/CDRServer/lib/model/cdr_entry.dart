part of model;

class CdrEntry {
  String uuid;
  bool inbound;
  int reception_id;
  String extension;
  int duration;
  int waitTime;
  DateTime started_at;
  Map json;

  CdrEntry.fromJson(Map this.json) {

    uuid = json['variables']['uuid'];
    inbound = json['variables']['direction'] == 'inbound';
    reception_id = int.parse(json['variables']['reception_id']);

    if(json['callflow'] is List) {
      List<Map> callFlow = json['callflow'];
      extension = callFlow.firstWhere((Map map) => map['profile_index'] == '1')['caller_profile']['destination_number'];
    } else {
      extension = json['callflow']['caller_profile']['destination_number'];
    }

    duration = int.parse(json['variables']['duration']);
    waitTime = int.parse(json['variables']['waitsec']);
    started_at = new DateTime.fromMillisecondsSinceEpoch(int.parse(json['variables']['start_epoch'])*1000);
  }
}
