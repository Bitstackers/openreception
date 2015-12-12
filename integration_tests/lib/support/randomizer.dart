part of or_test_fw;

abstract class Randomizer {

  static int seed = new DateTime.now().millisecondsSinceEpoch;
  static Random rand = new Random(seed);

  static final List<String> events =
      ['Milk purchase',
       'Meeting with ${randomChoice(contacts)}',
       'All work and no play',
       'Roller coaster inspection',
       'Prepare world domination'];

  static final List<String> dialplanNote = [
    '',
    'Vacation dialplan',
    'Reserved for hang-overs',
    'Not longer needed',
    'Should really just be removed'
    ];

  static final List<String> contacts =
      ['Alexandra Kongstad Pedersen',
       'Anne And',
       'Gardenia Hø',
       'Hans Hansen',
       'Peter Petersen',
       'Tom Thomsen',
       'Petra Petrea',
       'Gunner Gunnersen',
       'Ole Olesen',
       'Helga Helgason',
       'Martinus Martinussen',
       'Bob Børgesen',
       'Charlie Carstensen',
       'Alice Arnesen',
       'Charlie Carstensen',
       'Bob Børgesen',
       'Bente Bogfinke',
       'Carla Cikade',
       'Dorthe Dådyr',
       'Eva Egern',
       'Frode Flyvemyre',
       'Gerda Ged',
       'Hans Havodder',
       'Ida Isfugl',
       'Jan Jordbi',
       'Karsten Klokkefrø',
       'Lars Latterfrø',
       'Maren Muldvarp',
       'Nille Natugle',
       'Ole Odder',
       'Petra Pindsvin',
       'Ronald Rødspætte',
       'Sune Syvsover',
       'Tulla Trane',
       'Ulla Undulat',
       'Verner Vaskebjørn',
       'Allan Abe',
       'Børge Bæver',
       'Carlo Connemara',
       'Dorian Dompap',
       'Eskild Edderfugl',
       'Frank Fritte',
       'Gunner Grævling',
       'Heidi Husmus',
       'Lars Latterfrø',
       'Frank Fritte',
       'Eskild Edderfugl',
       'Helga Helgason',
       'Martinus Martinussen',
       'Anja Hansen',
       'Astrid Bang',
       'Birgit Blomquist',
       'Janne Winther Andreasen',
       'Knud Jønsson',
       'Morten Smidt-Holm',
       'Naja Duelund',
       'Oda Olsen',
       'Gert Keld',
       'Perry Næbdyr',
       'Palle Letkniv',
       'Anders Sand',
       'Rie Gid S.Todder',
       'Kvak S. Alver',
       'Sigmund Sivsko'];

  static final List<String> titles =
      ['Forskningsleder/seniorforsker',
        'Forsker',
        'Administrationschef',
        'Kreditorbogholder',
        'Forskningsleder/seniorforsker',
        'Direktør',
        'Seniorforsker',
        'Sekretær/debitorbogholder',
        'Senior Superman',
        'Nattevagt',
        'Overlæge',
        'Underlæge',
        'Bussemandsskræmmer',
        'Spøgelsesjæger',
        'Grønthøster',
        'Blåhvalsjæger',
        'Myresluger',
        'Underdirektør',
        'Potteskjuler',
        'Hegnbestiger',
        'Glaspuster',
        'Næsepudser',
        'Kummebejser',
        'Skærmtrold',
        'Møntvender',
        'Bagvender',
        'Sivskofletter',
        'Ordkløver',
        'Tingfinder',
        'Sodavandsbæller',
        'Dynevender',
        'Endevender',
        'Vendekåbe',
        'Stoledanser',
        'Frisbeehenter',
        'IKEA-skab-samler',
        'Ringbind',
        'Stalker',
        'Blotter',
        'F5-Trykker',
        'Lusepuster',
        'Lyseslukker',
        'Sneglekoger',
        'Frølårsklipper',
        'Dåseåbner',
        'Hvidløgspresser',
        'Pruttens ejermand'];

  static final List<String> companyNames = [
        'Acme inc',
        'Wayne Enterprise',
        'Ghostbusters A/S',
        'Slamtroldmanden',
        'Kødbollen A/S',
        'Blomme\'s Gartneri',
        'Hummerspecialisten ApS',
        'Gnaske-Grønt ApS',
        'Firmanavn_der_fortæller_om_samtlige_produkter_hos_os A/S',
        'BulgurKompaniget A/S',
        'Andefødder Aps',
        'Spirevippen I/S',
        'Petersen\'s Globale Kobberudvinding',
        'PingPong ApS',
        'Kasper\'s Køkken A/S',
        'Den Varme Radiator ApS',
        'KludeCentralen ApS',
        'MobileAdvolaterne A/S',
        'Bogforlaget A/S',
        'Revisor Søren ApS',
        'Den Varme Radiator ApS',
        'KludeCentralen ApS',
        'MobileAdvolaterne A/S',
        'Bogforlaget A/S',
        'Revisor Søren ApS',
        'Kalle\'s Dyrefoder ApS',
        'Fantasibureauet A/S',
        'Fem Flade fisk I/S',
        'Advokatkontoret',
        'Gave-Ideer ApS',
        'Det Tredie Firmanavn I/S',
        'Kraniosakralklinikken ApS',
        'Hvalbøffer A/S',
        'De gode ideer ApS',
        'Super-supporten A/S',
        'Doozerne A/S',
        'Sublim Forskning A/S',
        'Hårtotten ApS',
        'Alt til katten A/S',
        'Sjov og Spas',
        'Humørbomben K/S',
        'Kurts kartoffelskrællerservice',
        'Det absolutte nulpunkt',
        'Den hellige ko-kebab',
        'Peters pottemageri',
        'Reklamegas Aps',
        'Lenes lækre lune lagner I/S',
        'Grine-Gerts anti-depressiver',
        'Kasse-kompaniet',
        'Hårstiverne'];

  static final List<String> messageBodies = [
    'I\'m selling these fine leather jackets',
    'Please call me back regarding stuff',
    'I love the smell of pastry',
    'Regarding your enlargement',
    'Nigerian royalties wish to send you money',
    'Call back soon',
    'The cheese has started to smell',
    'Are you paying for that?',
    'Imagination land called',
    'Roller coasters purchase',
    'These are not the droids you are looking for. Come to me for new ones!',
    'All your base are belong',
    'I would love to change the world, but they won\'t give me the source code'];

  static final List<String> callerNames = [
    'Bob Barker',
    'Mister Green',
    'Walter White',
    'Boy Wonder',
    'Batman',
    'Perry the Platypus',
    'Ferb Fletcher',
    'Phineas Flynn',
    'Candace Flynn',
    'Dr. Heinz Doofenshmirtz',
    'Reed Richards (Mr. Fantastic)',
    'Peter Parker (Spiderman)',
    'Bruce Banner (the Hulk)',
    'Matt Murdock (Daredevil)',
    'Susan Storm (Invisible Girl)',
    'Scott Summers (Cyclops)',
    'Stephen Strange (Dr. Strange)',
    'Darkwing Duck'];

  //TODO: Check that these match the flags in the framework.
  static final List<List<String>> flagsLists = [
    [],
    ["pleaseCall"],
    ['urgent.','pleaseCall'],
    ['hasCalled', 'pleaseCall'],
    ["willCallBack"],
    ["urgent"],
    ["urgent","willCallBack"]];

  static final userNames = [
        'Bob Børgesen',
        'Alice Arnesen',
        'Charlie Carstensen',
        'Dorthe Didriksen',
        'Erik Einersen',
        'Frede Frandsen',
        'Gurli Gunnersen',
        'Heidi Hermansen',
        'Ida Iversen',
        'Julius Jensen',
        'Rasmine Rapmund',
        'Signe Snaksom',
        'Sanne Sludrechartol',
        'Miranda Migrene',
        'Tage Fortalsom',
        'Mogens Morgenånde',
        'Bengt Blidrøst',
        'Svend Skrap',
        'Børge Bralder',
        'Buller Bredmund',
        'Ove Overlæbe',
        'Misse Mundvand'];

  static List<String> organizationFlags =
    ['VIP', '', 'Charity', 'Pro bono', 'Bad credit'];

  static List<String> billingTypes =
    ['Cash', 'Invoice', 'Account', 'Labor', 'Up front'];

  static String randomEvent() => randomChoice(events);

  static String randomCompany() => randomChoice(companyNames);
  static String randomUsername() => randomChoice(userNames);
  static String randomTitle() => randomChoice(titles);
  static String randomCallerName() => randomChoice(callerNames);
  static String randomContactName() => randomChoice(contacts);
  static String randomMessageBody() => randomChoice(messageBodies);
  static List<String> randomMessageFlags() => randomChoice(flagsLists);
  static String randomEndpointType() => randomChoice(Model.MessageEndpointType.types);
  static String randomRecipientRole() => randomChoice(Model.Role.RECIPIENT_ROLES);
  static String randomContactType() => randomChoice(Model.ContactType.types);
  static String randomDialplanNote() => randomChoice(dialplanNote);

  /**
   * Generates a random [Model.IvrMenu].
   */
  static Model.IvrMenu randomIvrMenu() =>
      new Model.IvrMenu('menu-${randomPhoneNumber()}', randomPlayback())
        ..entries = randomIvrEntries();

  /**
   *
   */
  static List<Model.IvrEntry> randomIvrEntries() =>
      ['1','2','3','4','5','6','7','8','9','*','#']
        .take(rand.nextInt(4)+1).map(randomIvrEntry).toList();

  /**
    * Generates a random [Model.IvrEntry] action.
    */
   static Model.IvrEntry randomIvrEntry(String digit) =>
     randomChoice([
       randomIvrTopmenu,
       randomIvrSubmenu,
       randomIvrTransfer,
       randomIvrVoicemail,
       ])(digit);

  /**
   *
   */
  static Model.IvrTopmenu randomIvrTopmenu(String digit) =>
      new Model.IvrTopmenu(digit);

  /**
   *
   */
  static Model.IvrSubmenu randomIvrSubmenu(String digit) =>
      new Model.IvrSubmenu(digit, 'submenu_${rand.nextInt(100)}');

  /**
   *
   */
  static Model.IvrTransfer randomIvrTransfer(String digit) =>
      new Model.IvrTransfer(digit, randomTransfer());

  /**
   *
   */
  static Model.IvrVoicemail randomIvrVoicemail(String digit) =>
      new Model.IvrVoicemail(digit, randomVoicemail());


  /**
   * Generates a random [Model.ReceptionDialplan].
   */
  static Model.ReceptionDialplan randomDialplan() =>
      new Model.ReceptionDialplan()
        ..open = randomDialplanHourActions()
        ..extension = '${randomPhoneNumber()}-${new DateTime.now().millisecondsSinceEpoch}'
        ..defaultActions = randomDialplanActions()
        ..note = randomDialplanNote()
        ..active = rand.nextBool();

  /**
   *
   */
  static List<Model.HourAction> randomDialplanHourActions() =>
      new List.generate(rand.nextInt(4)+1, (_) => randomHourAction());

  /**
   *
   */
  static Model.HourAction randomHourAction() =>
      new Model.HourAction()
        ..actions = randomDialplanActions()
        ..hours = randomOpeningHours();

  /**
   *
   */
  static List<Model.OpeningHour> randomOpeningHours() =>
      new List.generate(rand.nextInt(4)+1, (_) => randomOpeningHour());

  /**
   *
   */
  static Model.OpeningHour randomOpeningHour() =>
      new Model.OpeningHour.empty()
        ..fromDay = randomWeekDay()
        ..toDay = randomWeekDay()
        ..fromHour = rand.nextInt(24)
        ..toHour = rand.nextInt(24)
        ..fromMinute = rand.nextInt(60)
        ..toMinute = rand.nextInt(60);

  /**
   *
   */
  static randomWeekDay() =>
      randomChoice(Model.WeekDay.values);


  /**
   * Generates a random-sized list of random [Model.Action] objects.
   */
  static List<Model.Action> randomDialplanActions() {
    //Number of actions to generate.
    final int numActions = rand.nextInt(5)+2;

    return new List.generate(numActions, (_) => randomAction());
  }

  /**
   * Generates a random [Model.Playback] action.
   */
  static Model.Playback randomPlayback() =>
      new Model.Playback('somefile',
          wrapInLock : rand.nextBool(),
          note : randomDialplanNote());

  /**
   * Generates a random [Model.Transfer] action.
   */
  static Model.Transfer randomTransfer() =>
      new Model.Transfer(randomPhoneNumber(),
          note : randomCallerName());

  /**
   * Generates a random [Model.Voicemail] action.
   */
  static Model.Voicemail randomVoicemail()=>
      new Model.Voicemail('vm-${randomPhoneNumber()}',
          recipient : randomGmail(),
          note : randomDialplanNote());

  /**
   * Generates a random [Model.Enqueue] action.
   */
  static Model.Enqueue randomEnqueue()=>
      new Model.Enqueue('queue-${rand.nextInt(100)}',
          holdMusic : 'playlist-${rand.nextInt(100)}',
          note : randomDialplanNote());

  /**
   * Generates a random [Model.Notify] action.
   */
  static Model.Notify randomNotify()=>
      new Model.Notify('event-${rand.nextInt(100)}');

  /**
   * Generates a random [Model.Ringtone] action.
   */
  static Model.Ringtone randomRingtone()=>
      new Model.Ringtone(rand.nextInt(4)+1);

  /**
   * Generates a random [Model.Ivr] action.
   */
  static Model.Ivr randomIvr()=>
      new Model.Ivr('menu-${rand.nextInt(100)}',
          note : randomDialplanNote());
  /**
   * Generates a random [Model.Action] action.
   */
  static Model.Action randomAction() =>
    randomChoice([randomVoicemail, randomEnqueue, randomNotify, randomRingtone,
      randomIvr, randomTransfer, randomPlayback])();

  /**
   * Generates a random 8-digit phone number.
   */
  static String randomPhoneNumber() {
    int firstDigit = rand.nextInt(8)+2;
    List<int> lastDigits = new List<int>.generate(8, (_) => rand.nextInt(10));
    List<int> digits = [firstDigit]..addAll(lastDigits);

    return digits.join('');
  }

  /**
   *
   */
  static String randomUserEmail() =>
    'employee${rand.nextInt(100)}@us.com';

  /**
   *
   */
  static String randomPeer() =>
    '11${rand.nextInt(10)}${rand.nextInt(10)}';

  /**
   *
   */
  static String randomString (int length) =>
    new String.fromCharCodes
      (new List.generate(length, (index) => rand.nextInt(33)+89));

  /**
   *
   */
  static String randomGmail() =>
    'employee${rand.nextInt(10)}${rand.nextInt(10)}@gmail.com';

  /**
   *
   */
  static String randomPortait() =>
    'employee${rand.nextInt(10)}${rand.nextInt(10)}.png';

  /**
   *
   */
  static Model.User randomUser() =>
    new Model.User.empty()
      ..address = randomUserEmail()
      ..googleAppcode = randomString(20)
      ..googleUsername = randomGmail()
      ..name = randomUsername()
      ..peer = randomPeer();

  static String randomLocalExtension() => rand.nextInt(501).toString();

  /**
   *
   */
  static String randomOrganizationFlag() =>
    randomChoice(organizationFlags);

  /**
   *
   */
  static String randomBillingType() =>
    randomChoice(billingTypes);

  /**
   * Constructs and returns a [Organization] object with random content.
   *
   * The returned object is does not have a valid ID.
   */
  static Model.Organization randomOrganization() =>
    new Model.Organization.empty()
      ..billingType = randomBillingType()
      ..flag = randomOrganizationFlag()
      ..fullName = randomCompany();

  static Model.BaseContact randomBaseContact() =>
      new Model.BaseContact.empty()
       ..contactType = randomContactType()
       ..fullName    = randomContactName()
       ..enabled     = rand.nextBool();


  static Model.Contact randomContact() =>
      new Model.Contact.empty()
       ..contactType = randomContactType()
       ..fullName    = randomContactName()
       ..enabled     = rand.nextBool()
       ..contactType = randomChoice(Model.ContactType.types);

  /**
   * Constructs and returns a [Reception] object with random content.
   *
   * The returned object is does not have a valid ID, nor organizationID.
   */
  static Model.Reception randomReception() =>
    new Model.Reception.empty()
      ..dialplan = '12340001'
      ..addresses = []
      ..alternateNames = []
      ..attributes = {}
      ..bankingInformation = []
      ..customerTypes = ['Not defined']
      ..emailAddresses = []
      ..enabled = true
      ..extraData = Uri.parse ('http://localhost/test')
      ..fullName = 'Test test'
      ..greeting = 'Go away'
      ..handlingInstructions = ['Hang up']
      ..lastChecked = new DateTime.now()
      ..openingHours = []
      ..otherData = 'Nope'
      ..product = 'Butter'
      ..salesMarketingHandling = []
      ..shortGreeting = 'Please go'
      ..telephoneNumbers = [new Model.PhoneNumber.empty()
                              ..value = '56 33 21 44']
      ..vatNumbers = []
      ..websites = []
      ..organizationId = 1;

  /**
   *
   */
  static Model.DistributionListEntry randomDistributionListEntry() =>
    new Model.DistributionListEntry()
      ..contactID = rand.nextInt(4)
      ..contactName = randomCallerName()
      ..receptionID = rand.nextInt(4)
      ..receptionName = randomCompany()
      ..role = randomRecipientRole();


  /**
   * Constructs and returns a [Message] object with random content.
   *
   * The returned object still needs to have its context, user and
   * recipients set before it is a valid parameter to a messageStore.
   */
  static Model.Message randomMessage() {
    Model.Message message = new Model.Message.empty();
    message..body = randomMessageBody()
        ..callId = 'call-id-${new DateTime.now().millisecondsSinceEpoch}'
        ..callerInfo = randomCaller()
        ..createdAt = new DateTime.now()
        ..flag = new Model.MessageFlag(randomMessageFlags());

    return message;
  }

  /**
   * Creates a random MessageEndpoint.
   */
  static Model.MessageEndpoint randomMessageEndpoint() =>
    new Model.MessageEndpoint.empty()
      ..address = randomGmail()
      ..confidential = rand.nextBool()
      ..description = randomString(22)
      ..enabled = rand.nextBool()
      ..type = randomEndpointType();

  /**
   * Construct a random MessageCaller object.
   */
  static Model.CallerInfo randomCaller() =>
    new Model.CallerInfo.empty()
      ..cellPhone = randomPhoneNumber()
      ..company = randomCompany()
      ..localExtension = randomLocalExtension()
      ..name = '${randomTitle()} ${randomCallerName()}'
      ..phone = randomPhoneNumber();

  static dynamic randomChoice (List pool) {
    if(pool.isEmpty) {
      throw new ArgumentError('Cannot find a random value in an empty list');
    }

    int index = rand.nextInt(pool.length);

    return pool[index];
  }
}