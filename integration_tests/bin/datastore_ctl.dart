import 'dart:async';
import 'dart:io';
import 'dart:math' show Random;

import 'package:logging/logging.dart';
import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:orf/model.dart' as model;
import 'package:orf/filestore.dart' as filestore;

import 'package:orf/exceptions.dart';
import 'package:ort/support.dart' show Randomizer;

//import 'package:args/args.dart';

Random _rand = new Random(new DateTime.now().millisecondsSinceEpoch);

/// Returns a random element from [pool].
dynamic randomChoice(List pool) {
  if (pool.isEmpty) {
    throw new ArgumentError('Cannot find a random value in an empty list');
  }

  int index = _rand.nextInt(pool.length);

  return pool[index];
}

final model.User _systemUser = new model.User.empty()..name = 'datastore_ctl';

/**
 * Logs [record] to STDOUT | STDERR depending on [record] level.
 */
void logEntryDispatch(LogRecord record) {
  final String error = '${record.error != null
      ? ' - ${record.error}'
      : ''}'
      '${record.stackTrace != null
        ? ' - ${record.stackTrace}'
        : ''}';

  if (record.level.value > Level.INFO.value) {
    stderr.writeln('${record.time} - ${record}$error');
  } else {
    stdout.writeln('${record.time} - ${record}$error');
  }
}

/// Mock object generation command.
class _GenerateCommand extends Command {
  @override
  final name = 'generate';
  final description = 'Generate mock objects and store them in the datastore.\n'
      'If the store is reused, the existing objects will count towards the total '
      'and cause the generation count to be lower.';

  final Logger _log = new Logger('generate');

  _GenerateCommand() {
    // [argParser] is automatically created by the parent class.
    argParser
      ..addOption('filestore',
          abbr: 'f', help: 'Path to where the filestore is created')
      ..addFlag('reuse-store', negatable: false)
      ..addOption('organizations', help: 'Generates this many organizations.')
      ..addOption('receptions', help: 'Generates this many receptions.')
      ..addOption('contacts', help: 'Generates this many contacts.')
      ..addOption('reception-attr',
          help: 'Generates this many reception attribute sets.')
      ..addOption('users', help: 'Generates this many users.')
      ..addOption('dialplans', help: 'Generates this many dialplans.')
      ..addOption('ivrs', help: 'Generates this many ivr menus.');
  }

  model.ReceptionDialplan _generateDialplan() {
    final DateTime now = new DateTime.now();

    model.OpeningHour justNow = new model.OpeningHour.empty()
      ..fromDay = model.toWeekDay(now.weekday)
      ..toDay = model.toWeekDay(now.weekday)
      ..fromHour = now.hour
      ..toHour = now.hour + 1
      ..fromMinute = now.minute
      ..toMinute = now.minute;

    model.ReceptionDialplan rdp = new model.ReceptionDialplan()
      ..open = [
        new model.HourAction()
          ..hours = [justNow]
          ..actions = [
            new model.Notify('call-offer'),
            new model.Ringtone(1),
            new model.Playback('non-existing-file.wav'),
            new model.Enqueue('waitqueue')
          ]
      ]
      ..extension = 'test-${Randomizer.randomPhoneNumber()}'
          '-${new DateTime.now().millisecondsSinceEpoch}'
      ..defaultActions = [new model.Playback('sorry-dude-were-closed')];

    return rdp;
  }

  String get fileStorePath {
    final String value = argResults['filestore'];

    if (value == null || value.isEmpty) {
      throw new UsageException('filestore parameter must be supplied', '');
    }

    return value;
  }

  bool get reuseStore => argResults['reuse-store'];

  /// Casts the value of [argumentName] to an integer.
  ///
  /// Returns 0 if the [argumentName] is not supplied, and throws
  /// a [UsageException] if the argument value is not a valid integer.
  int _argToInt(ArgResults argResults, String argName) {
    if (argResults[argName] == null) {
      return 0;
    }

    try {
      return int.parse(argResults[argName]);
    } on FormatException {
      throw new UsageException(
          'Agument value for \'$argName\' is not a valid integer', '');
    }
  }

  Future run() async {
    print(argResults.arguments);
    final int receptionCount = _argToInt(argResults, 'receptions');
    final int organizationCount = _argToInt(argResults, 'organizations');
    final int receptionAttrCount = _argToInt(argResults, 'reception-attr');
    final int dialplanCount = _argToInt(argResults, 'dialplans');
    final int contactCount = _argToInt(argResults, 'contacts');
    final int ivrCount = _argToInt(argResults, 'ivrs');
    final int userCount = _argToInt(argResults, 'users');

    final Directory fsDir = new Directory(fileStorePath);
    if (fsDir.existsSync() && !reuseStore) {
      throw new UsageException(
          'Filestore path already exist. '
          'Please supply a non-existing path or use the --reuse-store flag.',
          '');
    }

    final datastore = new filestore.DataStore(fileStorePath);

    // Create users.
    if (userCount > 0) {
      _log.info('Creating  ${userCount} test-users');
      (await Future.wait(new List(userCount).map((_) async {
        final randUser = Randomizer.randomUser();
        final org = await datastore.userStore.create(randUser, _systemUser);

        _log.info('Created user ${org.name}');
      })))
          .toList(growable: false);
    }

    // Create organizations.
    if (organizationCount > 0) {
      _log.info('Creating  ${organizationCount} test-organizations');
      (await Future.wait(new List(organizationCount).map((_) async {
        final randOrg = Randomizer.randomOrganization();
        final org =
            await datastore.organizationStore.create(randOrg, _systemUser);

        _log.info('Created organization ${org.name}');
      })))
          .toList(growable: false);
    }

    // Load the current list of organizations.
    final List<model.OrganizationReference> orgs =
        (await datastore.organizationStore.list()).toList(growable: false);

    // Create receptions.
    if (receptionCount > 0 && orgs.isEmpty) {
      throw new UsageException(
          'Cannot create receptions in datastore with no organizations',
          'Please create at least one organization before creating reception.');
    }

    if (receptionCount > 0) {
      _log.info('Creating  ${receptionCount} test-receptions');
      await Future.wait(new List(receptionCount).map((_) async {
        final org = await randomChoice(orgs);
        final randRec = Randomizer.randomReception()..oid = org.id;

        final rec = await datastore.receptionStore.create(randRec, _systemUser);

        _log.info('Created reception ${rec.name} owned by ${org.name}');

        return rec;
      }));
    }

    // Load the current list of receptions.
    final List<model.ReceptionReference> recs =
        (await datastore.receptionStore.list()).toList(growable: false);

    // Create contacts.
    if (contactCount > 0) {
      _log.info('Creating  ${contactCount} test-contacts');
      await Future.wait(new List(contactCount).map((_) async {
        final newContact = Randomizer.randomBaseContact();

        final con =
            await datastore.contactStore.create(newContact, _systemUser);

        _log.info('Created contact ${con.name}');
        return con;
      }));
    }

    // Load the current list of contacts.
    final List<model.BaseContact> cons =
        (await datastore.contactStore.list()).toList(growable: false);

    // Create reception attributes.
    if (receptionAttrCount > 0 && cons.isEmpty) {
      throw new UsageException(
          'Cannot create reception attributes in datastore with no contacts',
          'Please create at least one contact before creating reception'
          'attribute sets .');
    }

    // Generate reception attribute sets.
    await Future.wait(new List(receptionAttrCount).map((_) async {
      final con = randomChoice(cons);
      final rec = randomChoice(recs);

      try {
        await datastore.contactStore.data(con.id, rec.id);
        _log.warning(
            'Skipping adding contact ${con.name} to reception ${rec.name}.'
            ' Contact already exist in reception.');
      } on NotFound {
        final attributes = Randomizer.randomAttributes();
        attributes
          ..cid = con.id
          ..receptionId = rec.id;

        await datastore.contactStore.addData(attributes, _systemUser);

        _log.info('Adding contact ${con.name} to reception ${rec.name}');
      } on ClientError {
        _log.warning(
            'Failed Adding contact ${con.name} to reception ${rec.name}');
      }
    }));

    // Create dialplans
    if (dialplanCount > 0) {
      _log.info('Creating  ${dialplanCount} test-dialplans');
      await Future.wait(new List(dialplanCount).map((_) async {
        final dp = _generateDialplan();

        await datastore.receptionDialplanStore.create(dp, _systemUser);
        _log.info('Created dialplan ${dp.extension}');
        return dp;
      }));
    }

    // Create IVR menus
    if (ivrCount > 0) {
      _log.info('Creating  ${ivrCount} test-ivr-menus');
      await Future.wait(new List(ivrCount).map((_) async {
        final menu = Randomizer.randomIvrMenu();

        await datastore.ivrStore.create(menu, _systemUser);
        _log.info('Created IVR menu ${menu.name}');
        return menu;
      }));
    }
  }
}

class _ManageCommand extends Command {
  @override
  final name = 'manage';
  final description = 'Manage different configuration setting and global'
      'flags of the datastore.';

  /// The filesystem path to the filestore.
  ///
  /// Throws [UsageException] if the passed value is empty or unsupplied.
  String get fileStorePath {
    final String value = argResults['filestore'];

    if (value == null || value.isEmpty) {
      throw new UsageException('filestore parameter must be supplied', '');
    }

    return value;
  }

  _ManageCommand() {
    // [argParser] is automatically created by the parent class.
    argParser
      ..addOption('filestore',
          abbr: 'f',
          help: 'Path to the filestore. '
              'A new path is created in ${Directory.systemTemp.path}, '
              'if omitted.')
      ..addFlag('reuse-store', negatable: false)
      ..addOption('add-admin-identity',
          help: 'Add a new user with supplied'
              ' admin identity.');
  }

  // [run] may also return a Future.
  Future run() async {
    if (!new Directory(fileStorePath).existsSync()) {
      throw new UsageException('Path ${fileStorePath} does not exist', '');
    }

    final filestore.DataStore datastore =
        new filestore.DataStore(fileStorePath);

    final String adminIdentity = argResults['add-admin-identity'];

    try {
      await datastore.userStore.getByIdentity(adminIdentity);

      throw new UsageException(
          'User with identity ${adminIdentity} already exists', '');
    } on NotFound {
      final user = new model.User.empty()
        ..address = adminIdentity
        ..identities = new Set.from([adminIdentity])
        ..groups = new Set.from([model.UserGroups.administrator]);

      await datastore.userStore.create(user, _systemUser);
    }
  }
}

class _CreateCommand extends Command {
  @override
  final name = 'create';
  final description = 'Create a new filestore'
      'flags of the datastore.';
  final Logger _log = new Logger('create');

  String get fileStorePath {
    final String value = argResults['filestore'];

    if (value == null || value.isEmpty) {
      throw new UsageException('filestore parameter must be supplied', '');
    }

    return value;
  }

  _CreateCommand() {
    // [argParser] is automatically created by the parent class.
    argParser
      ..addOption('filestore',
          abbr: 'f', help: 'Path to where the filestore is created');
  }

  // [run] may also return a Future.
  Future run() async {
    if (new Directory(fileStorePath).existsSync()) {
      throw new UsageException('Path $fileStorePath already exists', '');
    } else {
      new Directory(fileStorePath).createSync();
    }

    final datastore = new filestore.DataStore(fileStorePath);
    _log.info('Created new filestore in $fileStorePath');

    final user = new model.User.empty()
      ..address = ''
      ..groups = new Set.from([model.UserGroups.administrator]);

    await datastore.userStore.create(user, _systemUser);
  }
}

// class _DatastoreCtrlConfig {
//   final bool showHelp;
//   final bool reuseStore;
//   final String datastorePath;
//   final int receptionCount;
//   final int organizationCount;
//   final int receptionDataCount;
//   final int dialplanCount;
//   final int contactCount;
//   final int ivrCount;
//   final int userCount;
//   final ArgParser parser;
//
//   factory _DatastoreCtrlConfig.fromArguments(List<String> args) {
//     var runner = new CommandRunner(
//         'datastore_ctl',
//         'OpenReception Datastore'
//         'modification and mock object generation tool');
//
//     // final parser = new ArgParser()
//     //   ..addFlag('help', abbr: 'h', help: 'Output this help', negatable: false)
//     //   ..addOption('filestore',
//     //       abbr: 'f',
//     //       help: 'Path to the filestore. '
//     //           'A new path is created in ${Directory.systemTemp.path}, '
//     //           'if omitted.')
//     //   ..addFlag('reuse-store', negatable: false)
//     //   ..addCommand('admin', new ArgParser())
//     //   ..addCommand(new _GenerateCommand());
//     //
//     // final ArgResults parsedArgs = parser.parse(args);
//     // final String fileStorePath =
//     //     parsedArgs['filestore'] != null ? parsedArgs['filestore'] : '';
//     // final bool reuse = parsedArgs['reuse-store'];
//     // final bool help = parsedArgs['help'];
//     final String commandName = '';
//     //parsedArgs.command != null ? parsedArgs.command : '';
//
//     final int rCount = commandName == 'generate'
//         ? int.parse(parsedArgs.command['generate-receptions'])
//         : 0;
//
//     final int oCount = commandName == 'generate'
//         ? int.parse(parsedArgs.command['generate-organizations'])
//         : 0;
//
//     final int rdCount = commandName == 'generate'
//         ? int.parse(parsedArgs.command['generate-reception-data'])
//         : 0;
//     final int dpCount = commandName == 'generate'
//         ? int.parse(parsedArgs.command['generate-dialplans'])
//         : 0;
//     final int cCount = commandName == 'generate'
//         ? int.parse(parsedArgs.command['generate-contacts'])
//         : 0;
//     final int iCount = commandName == 'generate'
//         ? int.parse(parsedArgs.command['generate-ivrs'])
//         : 0;
//     final int uCount = commandName == 'generate'
//         ? int.parse(parsedArgs.command['generate-users'])
//         : 0;
//
//     return new _DatastoreCtrlConfig._internal(
//         parser,
//         help,
//         reuse,
//         fileStorePath,
//         rCount,
//         oCount,
//         rdCount,
//         dpCount,
//         cCount,
//         iCount,
//         uCount);
//   }
//
//   _DatastoreCtrlConfig._internal(
//       this.parser,
//       this.showHelp,
//       this.reuseStore,
//       this.datastorePath,
//       this.receptionCount,
//       this.organizationCount,
//       this.receptionDataCount,
//       this.dialplanCount,
//       this.contactCount,
//       this.ivrCount,
//       this.userCount);
// }

/**
 *
 */
Future main(args) async {
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen(logEntryDispatch);
  Logger _log = new Logger('datastore_ctl');

  var runner = new CommandRunner(
      "datastore_ctl", 'OpenReception datastore management tool')
    ..addCommand(new _ManageCommand())
    ..addCommand(new _CreateCommand())
    ..addCommand(new _GenerateCommand());

  try {
    await runner.run(args);
  } on UsageException catch (error) {
    print(error);
    print(runner.usage);
    exit(64); // Exit code 64 indicates a usage error.
  } catch (error) {
    print(error);
  }

  // _DatastoreCtrlConfig conf = new _DatastoreCtrlConfig.fromArguments(args);
  //
  // if (conf.showHelp) {
  //   print(conf.parser.usage);
  //   exit(1);
  // }
  //
  // final Directory fsDir = new Directory(conf.datastorePath);
  // if (fsDir.existsSync() && !conf.reuseStore) {
  //   print('Filestore path already exist. '
  //       'Please supply a non-existing path or use the --reuse-store flag.');
  //   print(conf.parser.usage);
  //   exit(1);
  // }
  //
  // final TestEnvironmentConfig envConfig = new TestEnvironment().envConfig;
  // await envConfig.load();
  // TestEnvironment env = new TestEnvironment(path: conf.datastorePath);
  //
  // if (conf.datastorePath.isEmpty) {
  //   ServiceAgent sa = await env.createsServiceAgent();
  //
  //   _log.info('Creating  ${conf.organizationCount} test-organizations');
  //   List<model.Organization> orgs = (await Future.wait(
  //           new List(conf.organizationCount)
  //               .map((_) async => sa.createsOrganization())))
  //       .toList(growable: false);
  //
  //   if (orgs.isNotEmpty) {
  //     _log.info('Creating  ${conf.receptionCount} test-receptions');
  //     List<model.Reception> recs = (await Future.wait(
  //             new List(conf.organizationCount).map(
  //                 (_) async => sa.createsReception(await randomChoice(orgs)))))
  //         .toList(growable: false);
  //
  //     _log.info('Creating  ${conf.organizationCount} organizations');
  //     new List(40)
  //         .map((_) async => sa.addsContactToReception(
  //             await sa.createsContact(), await randomChoice(recs)))
  //         .toList();
  //
  //     new List(10)
  //         .map((_) async => await sa.createsDialplan(mustBeValid: true));
  //
  //     new List(10).map((_) async => await sa.createsIvrMenu());
  //   }
  // }
}
