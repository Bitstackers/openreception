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

library openreception.message_dispatcher;

import 'dart:io';
import 'dart:core';
import 'dart:async';

import 'package:args/args.dart';
import 'package:emailer/emailer.dart';
import 'package:logging/logging.dart';
import 'package:openreception_framework/model.dart' as Model;

import '../lib/configuration.dart';
import '../lib/message_dispatcher/router.dart' as router;

/**
 * TODO: Initialize serverToken
 */

final Logger log = new Logger('MessageDispatcher');

SmtpOptions options = new SmtpOptions()
  ..hostName = config.messageDispatcher.smtp.hostname
  ..port = config.messageDispatcher.smtp.port;

void main(List<String> args) {

  ///Init logging. Inherit standard values.
  Logger.root.level = config.messageDispatcher.log.level;
  Logger.root.onRecord.listen(config.messageDispatcher.log.onRecord);

  ArgParser parser = new ArgParser()
    ..addFlag('help', abbr: 'h', help: 'Output this help', negatable: false)
    ..addOption('httpport',
        help: 'The port the HTTP server listens on.',
        defaultsTo: config.messageDispatcher.httpPort.toString());

  ArgResults parsedArgs = parser.parse(args);

  if (parsedArgs['help']) {
    print(parser.usage);
    exit(1);
  }

  router
      .start(port: int.parse(parsedArgs['httpport']))
      .then((_) => periodicEmailSend())
      .catchError(log.shout);
}

/**
 *
 */
Iterable<Model.MessageRecipient> emailRecipients(
        Iterable<Model.MessageRecipient> rcps) =>
    rcps.where((Model.MessageRecipient rcp) =>
        rcp.type == Model.MessageEndpointType.EMAIL);

/**
 *
 */
Iterable<Model.MessageRecipient> smsRecipients(
        Iterable<Model.MessageRecipient> rcps) =>
    rcps.where((Model.MessageRecipient rcp) =>
        rcp.type == Model.MessageEndpointType.SMS);

/**
 * The Periodic task that passes emails on to the SMTP server.
 * As of now, this is done by an external mailer script.
 */
void periodicEmailSend() {
  DateTime start = new DateTime.now();

  router.messageQueueStore
      .list(maxTries: config.messageDispatcher.maxTries)
      .then((Iterable<Model.MessageQueueItem> queuedMessages) {
    Future.forEach(queuedMessages, tryDispatch).whenComplete(() {
      log.info('Processed ${queuedMessages.length} messages in '
          '${(new DateTime.now().difference(start)).inMilliseconds} milliseconds.'
          ' Sleeping for ${config.messageDispatcher.mailerPeriod} seconds');
      reSchedule();
    });
  }).catchError((error, stackTrace) {
    /// TODO (KRC, TL): We need to figure out what to do here. As it stands we
    /// stop dispatching if the messageQueueStore call fails for some reason.
    ///
    /// A: If the messageQueueStore fails, we are in serious shit. Better to
    /// let the process die, and let supervisor restart it, rather than trying
    /// to recover at this point.
    log.severe('Failed to load database message');
    log.severe(error, stackTrace);
    exit(1);
  });
}

/**
 *
 */
Timer reSchedule() =>
    new Timer(config.messageDispatcher.mailerPeriod, periodicEmailSend);

/**
 *
 */
Future tryDispatch(Model.MessageQueueItem queueItem) async {
  Model.Message message = await router.messageStore.get(queueItem.messageID);
  Model.User user = await router.userStore.get(message.senderId);

  if (queueItem.unhandledRecipients.isEmpty) {
    log.info("No recipients left detected on message with ID ${message.ID}!");
    return router.messageQueueStore.archive(queueItem);
  }

  log.fine('Dispatching messageID ${message.ID} - queueID: ${queueItem.ID}');
  queueItem.tries++;

  ///Dispatch email recipients.
  Iterable<Model.MessageRecipient> currentRecipients =
      emailRecipients(queueItem.unhandledRecipients);
  Model.TemplateEmail template =
      new Model.TemplateEmail(message, currentRecipients, user);
  log.fine(template.toString());

  List to = currentRecipients.where((mr) => mr.role == Model.Role.TO)
      .map((mrto) => new Address(mrto.address, mrto.name))
      .toList(growable: false);

  List cc = currentRecipients.where((mr) => mr.role == Model.Role.CC)
      .map((mrto) => new Address(mrto.address, mrto.name))
      .toList(growable: false);

  List bcc = currentRecipients.where((mr) => mr.role == Model.Role.BCC)
      .map((mrto) => new Address(mrto.address, mrto.name))
      .toList(growable: false);

  Email email =
    new Email(new Address(user.googleUsername, user.name), 'home.gir.dk')
     ..to = to
     ..cc = cc
     ..bcc = bcc
     ..subject = template.renderSubject()
     ..partText = template.renderedBody;

  new SmtpClient(options).send(email);

  /// Update the handled recipient set.

  queueItem.handledRecipients = currentRecipients;
  print(queueItem.unhandledRecipients);

  ///Dispatch sms recipients.
  currentRecipients = smsRecipients(queueItem.unhandledRecipients);

  ///FIXME(TL): Do aweome-sms-emailer-related-rainbow-magic-stuff here.
//  Model.Template sms =
//      new Model.TemplateSms (message, currentRecipients, user);
//  log.fine(sms.toString());
  queueItem.handledRecipients = currentRecipients;

  return router.messageQueueStore.save(queueItem);
}
