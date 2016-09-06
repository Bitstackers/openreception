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

library ors.message_dispatcher;

import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:args/args.dart';
import 'package:emailer/emailer.dart';
import 'package:logging/logging.dart';
import 'package:orf/filestore.dart' as filestore;
import 'package:orf/model.dart' as model;
import 'package:orf/storage.dart' as storage;
import 'package:ors/configuration.dart';

///Logger
final Logger _log = new Logger('MessageDispatcher');

SmtpOptions options = new SmtpOptions()
  ..hostName = config.messageDispatcher.smtp.hostname
  ..port = config.messageDispatcher.smtp.port
  ..secure = config.messageDispatcher.smtp.secure
  ..password = config.messageDispatcher.smtp.password
  ..username = config.messageDispatcher.smtp.username
  ..name = config.messageDispatcher.smtp.name;

storage.MessageQueue messageQueue;

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

  messageQueue =
      new filestore.MessageQueue(parsedArgs['filestore'] + '/message_queue');
}

/**
 *
 */

Iterable<model.MessageEndpoint> emailRecipients(
        Iterable<model.MessageEndpoint> rcps) =>
    rcps.where((model.MessageEndpoint rcp) => [
          model.MessageEndpointType.emailTo,
          model.MessageEndpointType.emailCc,
          model.MessageEndpointType.emailBcc
        ].contains(rcp.type));

/**
 *
 */
Iterable<model.MessageEndpoint> smsRecipients(
        Iterable<model.MessageEndpoint> rcps) =>
    rcps.where((model.MessageEndpoint rcp) =>
        rcp.type == model.MessageEndpointType.sms);

/**
 * The Periodic task that passes emails on to the SMTP server.
 * As of now, this is done by an external mailer script.
 */
void periodicEmailSend() {
  DateTime start = new DateTime.now();

  messageQueue.list().then((Iterable<model.MessageQueueEntry> queuedMessages) {
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
Future tryDispatch(model.MessageQueueEntry queueItem) async {
  model.Message message = queueItem.message;

  if (queueItem.unhandledRecipients.isEmpty) {
    _log.info("No recipients left detected on message with ID ${message.id}!");
    return messageQueue.remove(queueItem.id);
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
  Iterable<model.MessageEndpoint> currentRecipients =
      emailRecipients(queueItem.unhandledRecipients);

  List<Address> to = new List<Address>.from(currentRecipients
      .where((mr) => mr.type == model.MessageEndpointType.emailTo)
      .map((mrto) => new Address(mrto.address.trim(), mrto.name)));

  List<Address> cc = new List<Address>.from(currentRecipients
      .where((mr) => mr.type == model.MessageEndpointType.emailCc)
      .map((mrto) => new Address(mrto.address.trim(), mrto.name)));

  List<Address> bcc = new List<Address>.from(currentRecipients
      .where((mr) => mr.type == model.MessageEndpointType.emailBcc)
      .map((mrto) => new Address(mrto.address.trim(), mrto.name)));

  if (currentRecipients.isNotEmpty) {
    model.TemplateEmail templateEmail =
        new model.TemplateEmail(message, queueItem.message.sender);
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
    model.Template templateSMS = new model.TemplateSMS(message);
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

  return messageQueue.update(queueItem);
}
