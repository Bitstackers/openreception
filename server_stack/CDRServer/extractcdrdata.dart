import 'package:xml/xml.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';

class CallLogEntry {
  
  XmlElement _workingNode;
  
  String                 get uuid               => (_workingNode.query('variables').query('uuid').first as XmlElement).text;
  String                 get lastBridgedTo      => (_workingNode.query('variables').query('last_bridge_to').first as XmlElement).text;
  String                 get extension_dialed   => (_workingNode.query({'profile_index' : '1'}).query('destination_number').first as XmlElement).text;
  String                 get direction          => (_workingNode.query('channel_data').query('direction').first as XmlElement).text; 
  int                    get duration           => int.parse ((_workingNode.query('duration').first as XmlElement).text);
  int                    get waitsec            => int.parse ((_workingNode.query('waitsec').first as XmlElement).text);
  
  XmlCollection<XmlNode> get _appLog            => _workingNode.query('app_log').queryAll('application');
  XmlCollection          get _reception_id_node => _workingNode.query('reception_id');

  
  int receptionID () {
    if (this._reception_id_node.isEmpty) {
        return 0;
    } 
      else {
      return int.parse(this._reception_id_node.first.text);
    }
  }
  
  bool inbound () {
    return this.direction == "inbound";
  }
  
  CallLogEntry (XmlElement workingNode) {
    this._workingNode = workingNode;
  }
  
  factory CallLogEntry.fromXMLString(String xml) {
    return new CallLogEntry(XML.parse(xml));
  }
 
  
  String toString() {
    return "${this.uuid} ${this.direction} call to reception with ID ${this.receptionID()} (${this.extension_dialed}) duration: ${this.duration}s (waited ${this.waitsec}s)";
  }
  
}

main(){
  Directory logDir = new Directory("/usr/local/freeswitch/log/xml_cdr");
  
  print(new DateTime.now());
  
  logDir.list(recursive: false, followLinks: false).forEach((element) {
    var file = new File(element.path);
    Future<String> finishedReading = file.readAsString(encoding: ASCII);
    finishedReading.then((text) => logEntry (text));
    });
  
  
}

void logEntry (String xmlBuffer) {
  //print (xmlBuffer);
  CallLogEntry currentEntry = new CallLogEntry.fromXMLString(xmlBuffer); 
  
  if (currentEntry.duration > 5) { 
    print (currentEntry.toString());
    print (currentEntry.lastBridgedTo);
  }
}