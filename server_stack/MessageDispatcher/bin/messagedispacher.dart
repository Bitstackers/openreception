import 'dart:io';
import 'dart:core';
import 'dart:async';
import 'dart:convert';

import 'package:args/args.dart';
import 'package:path/path.dart';

import 'package:openreception_framework/common.dart';
import 'package:openreception_framework/model.dart' as Model;

import '../lib/configuration.dart';
import '../lib/router.dart' as Router;

ArgResults parsedArgs;
ArgParser parser = new ArgParser();

/**
 * TODO: Initialize serverToken
 */

void main(List<String> args) {
  try {
    Directory.current = dirname(Platform.script.toFilePath());

    registerAndParseCommandlineArguments(args);

    if (showHelp()) {
      print(parser.getUsage());

      exit(1);

    } else {
      config = new Configuration(parsedArgs);
      config.whenLoaded()
        .then((_) => Router.startDatabase())
        .then((_) => Router.connectNotificationService())

        // HTTP interface is currently unsupported, due to database schema changes.
      // .then((_) => http.start(config.httpport, router.setup))
      .then((_) => periodicEmailSend()).catchError((e, stackTrace) => logger.errorContext('${e} : ${stackTrace}', 'main'));
    }
  } on ArgumentError catch (e, stackTrace) {
    logger.errorContext('main() ArgumentError ${e} : ${stackTrace}', 'main');
    print(parser.getUsage());

  } on FormatException catch (e, stackTrace) {
    logger.errorContext('main() FormatException ${e} : ${stackTrace}', 'main');
    print(parser.getUsage());

  } catch (e, stackTrace) {

    logger.errorContext('Unhandled exception ${e} : ${stackTrace}', 'main');
  }
}


List<Model.MessageRecipient> emailRecipients(Model.Message message) => message.recipients.where((Model.MessageRecipient recipient) => recipient.endpoints.contains(Model.MessageEndpointType.EMAIL)).toList();

List<Model.MessageEndpoint> emailEndpoints(List<Model.MessageEndpoint> endpoints) => endpoints.where((Model.MessageEndpoint endpoint) => endpoint.type == Model.MessageEndpointType.EMAIL).toList();

List<Model.MessageRecipient> smsRecipients(Model.Message message) => message.recipients.where((Model.MessageRecipient recipient) => recipient.endpoints.contains(Model.MessageEndpointType.SMS)).toList();

Timer reSchedule() => new Timer(new Duration(seconds: config.mailerPeriod), periodicEmailSend);


Future tryDispatch(Model.MessageQueueItem queueItem) {
  final String context = "tryDispatch";

  return queueItem.message(Router.messageStore).then((Model.Message message) {

    if (!message.recipients.hasRecipients) {
      logger.errorContext("No recipients detected on message with ID ${message.ID}!", context);

      queueItem.save(Router.messageQueueStore);

    } else {

      logger.debugContext('Dispatching to email recipients message with id ${message.ID} - queueID: ${queueItem.ID} ', context);

      Model.Template email = new Model.TemplateEmail(message)..endpoints = emailEndpoints(queueItem.unhandledEndpoints);

      String json = JSON.encode(email);

      /* Kick off a mailer process */
      return Process.start('python', [config.mailerScript, json]).then((process) {

        logger.errorContext('Kicking off mailer process', context);
        /// Redirect the output from the mailer to the logger.
        process.stdout.transform(UTF8.decoder).transform(new LineSplitter()).listen((String line) => logger.errorContext('Python mailer (stdout): ${line}', context));
        process.stderr.transform(UTF8.decoder).transform(new LineSplitter()).listen((String line) => logger.errorContext('Python mailer (stderr): ${line}', context));

        process.exitCode.then((int exitCode) {
          if (exitCode != 0) {
            logger.errorContext('Python mailer prematurely exits with code: ${exitCode},', context);
          } else {
            /// Remove the email endpoints, as they are now handled.
            queueItem.unhandledEndpoints.removeWhere((Model.MessageEndpoint ep)
                => emailEndpoints(queueItem.unhandledEndpoints).contains(ep));
          }

        }).whenComplete(() {
          queueItem.tries++;

          if (queueItem.unhandledEndpoints.isEmpty) {
            queueItem.archive(Router.messageQueueStore);
          }
          else {
            queueItem.save(Router.messageQueueStore);
          }
        });
      }).catchError((onError) => logger.errorContext("Failed to run mailer process. Error: ${onError}", context));;
    }
  });
}


/**
 * The Periodic task that passes emails on to the SMTP server.
 * As of now, this is done by an external mailer script.
 */
void periodicEmailSend() {

  int messageCount = null;
  DateTime start = new DateTime.now();

  final String context = "periodicEmailSend";

  Router.messageQueueStore.list(maxTries : config.maxTries).then((List<Model.MessageQueueItem> queuedMessages) {
    Future.forEach(queuedMessages, tryDispatch).whenComplete(() {
      logger.infoContext('Processed ${queuedMessages.length} messages in ${(new DateTime.now().difference(start)).inMilliseconds} milliseconds. Sleeping for ${config.mailerPeriod} seconds', context);
      reSchedule();
    });
  }).catchError((onError, stacktrace) => logger.errorContext("Failed to load database message. Error: ${onError}. Trace: ${stacktrace}", context));
}

void registerAndParseCommandlineArguments(List<String> arguments) {
  parser.addFlag('help', abbr: 'h', help: 'Output this help');
  parser.addOption('configfile', help: 'The JSON configuration file. Defaults to config.json');
  parser.addOption('httpport', help: 'The port the HTTP server listens on.  Defaults to ${Default.HTTPPort}');
  parser.addOption('dbuser', help: 'The database user');
  parser.addOption('dbpassword', help: 'The database password');
  parser.addOption('dbhost', help: 'The database host. Defaults to localhost');
  parser.addOption('dbport', help: 'The database port. Defaults to 5432');
  parser.addOption('dbname', help: 'The database name');

  parsedArgs = parser.parse(arguments);
}

bool showHelp() => parsedArgs['help'];
