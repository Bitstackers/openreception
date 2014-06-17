import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:Utilities/service.dart' as Service;
import '../lib/configuration.dart';


class InternalError extends StateError {

  InternalError(String message): super(message);
}

class NotFound extends StateError {

  NotFound(String message): super(message);
}

class NotAuthorized extends StateError {

  NotAuthorized(String message): super(message);
}

class BadRequest extends StateError {

  BadRequest(String message): super(message);
}

class clientSocket {
  
  String hostname = "";
  int    port     = 0;

  Socket callFlowClient = null;
  static Future<clientSocket> connect(String host, int port) {
    clientSocket newInstance = new clientSocket();
    newInstance.hostname = host;
    newInstance.port     = port;
    
    return newInstance._connect();
  }
  
  Future<clientSocket> _connect() {
    return Socket.connect(this.hostname, this.port).then((newSocket) {
      this.callFlowClient = newSocket;
      print('Connected to ${this.hostname}:${this.port}');
      return this;
    });
  }

  listenEventSocket() {
    Map socketRequest = {
      "resource": "event_socket",
      "parameters": {},
      "user": {
        "id": 10,
        "name": "Test agent 1100",
        "extension": "1100",
        "groups": ["Receptionist", "Administrator", "Service agent"],
        "identities": ["testagent1100@adaheads.com"],
        "remote_attributes": {}
      }
    };

    print (JSON.encode(socketRequest));
    this.callFlowClient.writeln(JSON.encode(socketRequest));
    this.callFlowClient.transform(UTF8.decoder).transform(new LineSplitter()).listen((String line) {
       Map json = JSON.decode(line);
       print (json);
      Service.Notification.broadcast(json, config.notificationServer, config.serverToken);
    }).onDone(() {
      print ('Disconnected from ${this.hostname}');
    });
  }
  
  Future<Response> command(Map command) {
    String buffer = "";

    final Completer<Response> completer = new Completer<Response>();

    this.callFlowClient.transform(UTF8.decoder).transform(new LineSplitter()).listen((String line) {
      if (completer.isCompleted) {
        print ("Returning early");
        return;
      }

      Response response = new Response.fromMap(JSON.decode(line));
      
      switch (response.status) {
        case ServerResponses.SUCCESS:
          completer.complete(response);
          break;
        
        case ServerResponses.NOT_FOUND:
          completer.completeError(new NotFound(response.errorText));
          break;
          
        case ServerResponses.BAD_REQUEST:
          completer.completeError(new BadRequest(response.errorText));
          break;
          
        case ServerResponses.PERMISSION_DENIED:
          completer.completeError(new NotAuthorized(response.errorText));
          break;

        default:
          completer.completeError(new InternalError(response.errorText));
          break;
      }

      this.callFlowClient.flush().then((_) {
        this.callFlowClient.close();
      });

    }).onError(completer.completeError);

    this.callFlowClient.write(JSON.encode(command) + '\n');
    return completer.future;
  }
}

abstract class ServerResponses {
  static const String UNDEFINED = 'UNDEFINED';
  static const String UNKNOWN_RESOURCE = 'UNKNOWN_RESOURCE';
  static const String PERMISSION_DENIED = 'PERMISSION_DENIED';
  static const String SUCCESS = 'SUCCESS';
  static const String BAD_REQUEST = 'BAD_REQUEST';
  static const String NOT_FOUND = 'NOT_FOUND';
  static const String INTERNAL_ERROR = 'INTERNAL_ERROR';

  static List<String> validResponses = [PERMISSION_DENIED, UNKNOWN_RESOURCE, 
                                        SUCCESS, BAD_REQUEST, 
                                        NOT_FOUND, INTERNAL_ERROR];

}

class Response {

  String _status = ServerResponses.UNDEFINED;
  String _errorText = null;
  Map _body = {};

  String get status => this._status;
  String get errorText => this._errorText;
  Map get content => this._body;


  Response.fromMap(Map map) {
    assert(ServerResponses.validResponses.contains(map['status'].toUpperCase()));

    this._status = map['status'];
    this._errorText = map['description'];
    this._body = map['response'];
  }

}
