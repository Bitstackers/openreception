import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:args/args.dart';
import 'package:path/path.dart';

import 'package:OpenReceptionFramework/common.dart';
import '../lib/configuration.dart';
import '../lib/database.dart' as Database;

import '../lib/model.dart' as Model;

ArgResults parsedArgs;
ArgParser parser = new ArgParser();

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
      .then((_) => Database.startDatabase())
      // HTTP interface is currently unsupported, due to database schema changes.
      // .then((_) => http.start(config.httpport, router.setup))
      .then((_) => periodicEmailSend())
      .catchError((e, stackTrace) => logger.errorContext('${e} : ${stackTrace}', 'main'));
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

/**
 * The Periodic task that passes emails on to the SMTP server.
 * As of now, this is done by an external mailer script.
 */
void periodicEmailSend() {

  int messageCount = null;
  DateTime start   = new DateTime.now();

  final String context = "periodicEmailSend";

  Database.messageQueueList().then((List<Map> items) {

    messageCount = items.length;

    items.forEach((Map queueEntry) {
      new Model.Message.stub(queueEntry['message_id']).load().then((Model.Message message) {
        logger.debugContext('Trying to dispatch message with id ${queueEntry['message_id']} - queueID: ${queueEntry['queue_id']} ',context );
        Model.Email.dereferenceRecipients(message).then((Model.Email email) {
          if (!message.hasRecipients) {
            logger.errorContext("No email recipients detected on message with ID ${queueEntry['message_id']}!", context);
          } else {
            String json = JSON.encode(email);
  
            /* Kick off a mailer process */
            Process.start('python', [config.mailerScript, json]).then((process) {

              process.exitCode.then((int exitCode) {
                if (exitCode != 0) {
                  logger.errorContext('Python mailer prematurely exits with code: ${exitCode},', context);
                } else {
                  Database.MessageQueue.remove(queueEntry['queue_id']);
                }
              });

              process.stdout.transform(UTF8.decoder).transform(new LineSplitter()).listen((String line) {
                logger.errorContext('Python mailer (stdout): ${line}', context);
              });
              process.stderr.transform(UTF8.decoder).transform(new LineSplitter()).listen((String line) {
                logger.errorContext('Python mailer (stderr): ${line}',context);
              });

            }).catchError((onError) {
              logger.errorContext("Failed to run mailer process. Error: ${onError}", context);
            });
         };
        }).catchError((onError, stacktrace) {
          logger.errorContext("Failed to load database message. Error: ${onError}. Trace: ${stacktrace}", context);
          // TODO mark the queueEntry as failed.
          
        });

      });
    });

    }).whenComplete(() {
    logger.infoContext('Processed $messageCount messages in ${(new DateTime.now().difference(start)).inMilliseconds} milliseconds. Sleeping for ${config.mailerPeriod} seconds..', context);
    messageCount = null;
    new Timer(new Duration(seconds: config.mailerPeriod), periodicEmailSend);
  });
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
