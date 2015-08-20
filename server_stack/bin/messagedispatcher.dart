import 'dart:io';
import 'dart:core';
import 'dart:async';

import 'package:args/args.dart';
//import 'package:emailer/emailer.dart';
import 'package:path/path.dart';
import 'package:logging/logging.dart';
import 'package:openreception_framework/model.dart' as Model;

import '../lib/configuration.dart';
import '../lib/message_dispatcher/configuration.dart' as msgdisp;
import '../lib/message_dispatcher/router.dart' as Router;

ArgResults parsedArgs;
ArgParser parser = new ArgParser();

/**
 * TODO: Initialize serverToken
 */

final Logger log = new Logger ('MessageDispatcher');

void main(List<String> args) {
  ///Init logging. Inherit standard values.
  Logger.root.level = Configuration.messageDispatcher.log.level;
  Logger.root.onRecord.listen(Configuration.messageDispatcher.log.onRecord);

  try {
    Directory.current = dirname(Platform.script.toFilePath());

    registerAndParseCommandlineArguments(args);

    if (showHelp()) {
      print(parser.usage);

      exit(1);

    } else {
      msgdisp.config = new msgdisp.Configuration(parsedArgs);
      msgdisp.config.whenLoaded()
        .then((_) => Router.startDatabase())
        .then((_) => Router.connectNotificationService())

        // HTTP interface is currently unsupported, due to database schema changes.
      // .then((_) => http.start(config.httpport, router.setup))
      .then((_) => periodicEmailSend())
      .catchError(log.shout);
    }
  } catch(error, stackTrace) {
    log.shout(error, stackTrace);
  }
}
//
///**
// *
// */
//List<Model.MessageEndpoint> emailEndpoints(List<Model.MessageEndpoint> endpoints) =>
//    endpoints.where((Model.MessageEndpoint endpoint) =>
//        endpoint.type == Model.MessageEndpointType.EMAIL).toList();
//


/**
 * The Periodic task that passes emails on to the SMTP server.
 * As of now, this is done by an external mailer script.
 */
void periodicEmailSend() {
  DateTime start = new DateTime.now();

  Router.messageQueueStore.list(maxTries : msgdisp.config.maxTries).then((List<Model.MessageQueueItem> queuedMessages) {
    Future.forEach(queuedMessages, tryDispatch).whenComplete(() {
      log.info('Processed ${queuedMessages.length} messages in ${(new DateTime.now().difference(start)).inMilliseconds} milliseconds. Sleeping for ${msgdisp.config.mailerPeriod} seconds');
      //reSchedule();
    });
  }).catchError((error, stackTrace) {
    /// TODO (KRC, TL): We need to figure out what to do here. As it stands we
    /// stop dispatching if the messageQueueStore call fails for some reason.
    log.severe('Failed to load database message');
    log.severe (error, stackTrace);
  });
}

/**
 *
 */
void registerAndParseCommandlineArguments(List<String> arguments) {
  parser.addFlag('help', abbr: 'h', help: 'Output this help');
  parser.addOption('configfile', help: 'The JSON configuration file. Defaults to config.json');
  parser.addOption('httpport', help: 'The port the HTTP server listens on.  Defaults to ${msgdisp.Default.HTTPPort}');
  parser.addOption('dbuser', help: 'The database user');
  parser.addOption('dbpassword', help: 'The database password');
  parser.addOption('dbhost', help: 'The database host. Defaults to localhost');
  parser.addOption('dbport', help: 'The database port. Defaults to 5432');
  parser.addOption('dbname', help: 'The database name');

  parsedArgs = parser.parse(arguments);
}

/**
 *
 */
Timer reSchedule() =>
    new Timer(new Duration(seconds: msgdisp.config.mailerPeriod), periodicEmailSend);

/**
 *
 */
bool showHelp() => parsedArgs['help'];
//
///**
// *
// */
//List<Model.DistributionListEntry> smsRecipients(Model.Message message) =>
//    message.recipients.where((Model.DistributionListEntry recipient) =>
//        recipient.endpoints.contains(Model.MessageEndpointType.SMS)).toList();

/**
 *
 */
Future tryDispatch(Model.MessageQueueItem queueItem) {
  return new Future(() {
    log.severe('MessageDispatcher is currently disable due to heavy refactoring');
  });

//  return queueItem.message(Router.messageStore).then((Model.Message message) {
//
//    if (!message.recipients.hasRecipients) {
//      log.severe ("No recipients detected on message with ID ${message.ID}!");
//      queueItem.tries++;
//      queueItem.create(Router.messageQueueStore);
//
//    } else {
//
//      return new Future(() {
//        log.fine('Dispatching messageID ${message.ID} - queueID: ${queueItem.ID}');
//        Model.Template email = new Model.TemplateEmail(message, emailEndpoints(queueItem.unhandledRecipients));
//        log.fine(email.toString());

//        process.exitCode.then((int exitCode) {
//          if (exitCode != 0) {
//            log.severe('Python mailer prematurely exits with code: ${exitCode},');
//          } else {
//            /// Remove the email endpoints, as they are now dispatched to.
//            queueItem.unhandledEndpoints.removeWhere((Model.MessageEndpoint ep)
//                => emailEndpoints(queueItem.unhandledEndpoints).contains(ep));
//          }
//
//        }).whenComplete(() {
//          queueItem.tries++;
//
//          if (queueItem.unhandledEndpoints.isEmpty) {
//            queueItem.archive(Router.messageQueueStore);
//          }
//          else {
//            if (queueItem.tries >= msgdisp.config.maxTries) {
//              //TODO: Figure out what to do with the message, once it reaches
//              // this point.
//
//            }
//            queueItem.save(Router.messageQueueStore);
//          }
//        });
//
//      });
//    }
// });
}
