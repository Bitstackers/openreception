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

library openreception.server.message_dispatcher;

import 'dart:io';
import 'dart:core';
import 'dart:async';

import 'package:args/args.dart';
import 'package:emailer/emailer.dart';
import 'package:logging/logging.dart';
import 'package:openreception.framework/model.dart' as Model;

import 'package:openreception.server/configuration.dart';
import 'package:openreception.server/message_dispatcher/router.dart' as router;

///Logger
final Logger _log = new Logger('MessageDispatcher');

SmtpOptions options = new SmtpOptions()
  ..hostName = config.messageDispatcher.smtp.hostname
  ..port = config.messageDispatcher.smtp.port
  ..secure = config.messageDispatcher.smtp.secure
  ..password = config.messageDispatcher.smtp.password
  ..username = config.messageDispatcher.smtp.username
  ..name = config.messageDispatcher.smtp.name;

void main(List<String> args) {
  ///Init logging. Inherit standard values.
  Logger.root.level = config.messageDispatcher.log.level;
  Logger.root.onRecord.listen(config.messageDispatcher.log.onRecord);

  ArgParser parser = new ArgParser()
    ..addFlag('help', abbr: 'h', help: 'Output this help', negatable: false)
    ..addOption('filestore', abbr: 'f', help: 'Path to the filestore backend')
    ..addOption('httpport',
        help: 'The port the HTTP server listens on.',
        defaultsTo: config.messageDispatcher.httpPort.toString());

  ArgResults parsedArgs = parser.parse(args);

  if (parsedArgs['help']) {
    print(parser.usage);
    exit(1);
  }

  if (parsedArgs['filestore'] == null) {
    print('Filestore path is required');
    print(parser.usage);
    exit(1);
  }

  router
      .start(port: int.parse(parsedArgs['httpport']))
      .then((_) => periodicEmailSend())
      .catchError(_log.shout);
}

/**
 *
 */

Iterable<Model.MessageEndpoint> emailRecipients(
        Iterable<Model.MessageEndpoint> rcps) =>
    rcps.where((Model.MessageEndpoint rcp) => [
          Model.MessageEndpointType.email,
          Model.MessageEndpointType.emailTo,
          Model.MessageEndpointType.emailCc,
          Model.MessageEndpointType.emailBcc
        ].contains(rcp.type));

/**
 *
 */
Iterable<Model.MessageEndpoint> smsRecipients(
        Iterable<Model.MessageEndpoint> rcps) =>
    rcps.where((Model.MessageEndpoint rcp) =>
        rcp.type == Model.MessageEndpointType.sms);

/**
 * The Periodic task that passes emails on to the SMTP server.
 * As of now, this is done by an external mailer script.
 */
void periodicEmailSend() {
  DateTime start = new DateTime.now();

  router.messageQueueStore
      .list()
      .then((Iterable<Model.MessageQueueEntry> queuedMessages) {
    Future.forEach(queuedMessages, tryDispatch).whenComplete(() {
      _log.info('Processed ${queuedMessages.length} messages in '
          '${(new DateTime.now().difference(start)).inMilliseconds} milliseconds.'
          ' Sleeping for ${config.messageDispatcher.mailerPeriod} seconds');
      reSchedule();
    });
  }).catchError((error, stackTrace) {
    _log.severe('Failed to load database message');
    _log.severe(error, stackTrace);
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
Future tryDispatch(Model.MessageQueueEntry queueItem) async {
  Model.Message message = queueItem.message;

  if (queueItem.unhandledRecipients.isEmpty) {
    _log.info("No recipients left detected on message with ID ${message.id}!");
    return router.messageQueueStore.remove(queueItem.id);
  }

  final String senderAddress =
      config.messageDispatcher.staticSenderAddress.isNotEmpty
          ? config.messageDispatcher.staticSenderAddress
          : queueItem.message.sender.address;

  final String senderName = config.messageDispatcher.staticSenderName.isNotEmpty
      ? config.messageDispatcher.staticSenderName
      : queueItem.message.sender.name;

  _log.fine('Dispatching messageID ${message.id} - queueID: ${queueItem.id}');
  queueItem.tries++;

  ///Dispatch email recipients.
  Iterable<Model.MessageEndpoint> currentRecipients =
      emailRecipients(queueItem.unhandledRecipients);

  List<Address> to = new List<Address>.from(currentRecipients
      .where((mr) =>
          mr.type == Model.MessageEndpointType.emailTo ||
          mr.type == Model.MessageEndpointType.email)
      .map((mrto) => new Address(mrto.address.trim(), mrto.name)));

  List<Address> cc = new List<Address>.from(currentRecipients
      .where((mr) => mr.type == Model.MessageEndpointType.emailCc)
      .map((mrto) => new Address(mrto.address.trim(), mrto.name)));

  List<Address> bcc = new List<Address>.from(currentRecipients
      .where((mr) => mr.type == Model.MessageEndpointType.emailBcc)
      .map((mrto) => new Address(mrto.address.trim(), mrto.name)));

  if (currentRecipients.isNotEmpty) {
    Model.TemplateEmail templateEmail =
        new Model.TemplateEmail(message, queueItem.message.sender);
    Email email = new Email(new Address(senderAddress, senderName),
        config.messageDispatcher.smtp.hostname)
      ..to = to
      ..cc = cc
      ..bcc = bcc
      ..subject = templateEmail.subject
      ..partText = templateEmail.bodyText
      ..partHtml = templateEmail.bodyHtml;

    await new SmtpClient(options).send(email).then((_) {
      /// Update the handled recipient set.
      queueItem.handledRecipients = currentRecipients;
    }).catchError((error, stackTrace) {
      _log.shout(
          'Failed to dispatch to email recipients '
          '<${currentRecipients.join(';')}> '
          '(messageID:${queueItem.message.id}, queueID:${queueItem.id})',
          error,
          stackTrace);
    });
  }

  ///Dispatch sms recipients.
  currentRecipients = smsRecipients(queueItem.unhandledRecipients);

  if (currentRecipients.isNotEmpty) {
    Model.Template templateSMS = new Model.TemplateSMS(message);
    Email sms = new Email(new Address(senderAddress, senderName),
        config.messageDispatcher.smtp.hostname)
      ..to = new List<Address>.from(currentRecipients.map((mrto) => new Address(
          mrto.address + config.messageDispatcher.smsKey.trim(), '')))
      ..partText = templateSMS.bodyText;

    await new SmtpClient(options).send(sms).then((_) {
      queueItem.handledRecipients = currentRecipients;
    }).catchError((error, stackTrace) {
      _log.shout(
          'Failed to dispatch to sms recipients '
          '<${currentRecipients.join(';')}> '
          '(messageID:${queueItem.message.id}, queueID:${queueItem.id})',
          error,
          stackTrace);
    });
  }

  return router.messageQueueStore.update(queueItem);
}
