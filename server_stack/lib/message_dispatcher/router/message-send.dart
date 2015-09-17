/*                  This file is part of OpenReception
                   Copyright (C) 2014-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of openreception.message_dispatcher.router;

void messageSend(HttpRequest request) {

  final String context = "messageserver.router.sendMessage";

  extractContent(request).then((String content) {
    logger.debug(content);
    Map data;

    //Check If the format of the message is valid.
    try {
      data = JSON.decode(content);
      if(!data.containsKey('to') || !(data['to'] is List)) {
        request.response.statusCode = HttpStatus.BAD_REQUEST;
        String response = JSON.encode(
            {'status'     : 'bad request',
             'description': 'The syntax for "to" is wrong'});
        writeAndClose(request, response);
        return null;
      }

      if(data.containsKey('cc') && !(data['cc'] is List)) {
        request.response.statusCode = HttpStatus.BAD_REQUEST;
        String response = JSON.encode(
            {'status'     : 'bad request',
             'description': 'The syntax for "cc" is wrong'});
        writeAndClose(request, response);
        return null;
      }
     
      if(data.containsKey('bcc') && !(data['bcc'] is List)) {
        request.response.statusCode = HttpStatus.BAD_REQUEST;
        String response = JSON.encode(
            {'status'     : 'bad request',
             'description': 'The syntax for "bcc" is wrong'});
        writeAndClose(request, response);
        return null;
      }
    } catch(e) {
      request.response.statusCode = 400;
      String response = JSON.encode(
          {'status'     : 'bad request',
           'description': 'passed message argument is too long, missing or invalid',
           'error'      : e.toString()});
      writeAndClose(request, response);
      return null;
    }

    //Check if there are any contacts.
    if(data['to'].length == 0) {
      request.response.statusCode = 400;
      String response = JSON.encode(
          {'status'     : 'bad request',
           'description': 'passed message argument "to" does not have any entries.'});
      writeAndClose(request, response);
      return null;
    }

    //    writeAndClose(request, JSON.encode({'status': 'Success'}));
    
    String message     = data['message'];
    String subject     = data['subject'];
    int toContactId    = data['to_contact_id'];
    String takenFrom   = data['takenFrom'];
    int takeByAgent     = 10;
    bool urgent             = data['urgent'];
    DateTime createdAt      = new DateTime.now();

    
//    return tempSMTP(message, subject, ['kim.rostgaard@gmail.com']).then((_) {
//      writeAndClose(request, JSON.encode({'status': 'Success'}));
//    });
    
    
    return db.createSendMessage(message, subject, toContactId, takenFrom, takeByAgent, urgent, createdAt).then((Map result) {
      db.Message message = new db.Message(result['id']);
      
      // Harvest each field for recipients.
      ['bcc','cc','to'].forEach ((String role) {
        (data[role] as List).forEach((contact_string) =>  message.addRecipient(new db.Messaging_Contact(contact_string, role)));
      });
      
      return db.addRecipientsToSendMessage(message.sqlRecipients()).then((Map result) {
        db.populateQueue(message).then((queueSize) {
          logger.debugContext("inserted $queueSize elements in queue.", context);
        });

        writeAndClose(request, JSON.encode(result));
      });
    });
       
  }).catchError((error) => serverError(request, error.toString()));
}

Future<int> getUserID (HttpRequest request, Uri authUrl) {
    try {
      if(request.uri.queryParameters.containsKey('token')) {      
        String path = 'token/${request.uri.queryParameters['token']}/validate';
        Uri url = new Uri(scheme: authUrl.scheme, host: authUrl.host, port: authUrl.port, path: path);
        return http.get(url).then((response) {
          if (response.statusCode == 200) {
            logger.debugContext (response.body, "common.AH_HTTPRequest.getUserID()");
            return JSON.decode(response.body)['id'];
          } else {
            return 0;
          }
        }).catchError((error) {
          return 0;
        });
        
      } else {
        return new Future.value(false);
      }
    } catch (e) {
      logger.critical('utilities.httpserver.auth() ${e} authUrl: "${authUrl}"');
    }
}
  
Future tempSMTP(String message, String subject, List<String> recipients) {
  // If you want to use an arbitrary SMTP server, go with `new SmtpOptions()`.
  // This class below is just for convenience. There are more similar classes available.
  var options = new GmailSmtpOptions()
    ..username = config.emailUsername
    ..password = config.emailPassword; // Note: if you have Google's "app specific passwords" enabled,
                                        // you need to use one of those here.
  
  // Create our email transport.
  var emailTransport = new SmtpTransport(options);
  
  // Create our mail/envelope.
  var envelope = new Envelope()
    ..fromName = config.emailFromName
    ..from     = config.emailFrom
    ..recipients.addAll(recipients)
    ..subject = subject
    ..text = message;

  // Email it.
  return emailTransport.send(envelope)
    .then((success) => log('Email sent! $success'))
    .catchError((e) => logger.error('Error occured when sending mail: $e'));
}

