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

  static String randomEvent() => randomChoice(events);

  static String randomCompany() => randomChoice(companyNames);
  static String randomTitle() => randomChoice(titles);
  static String randomCallerName() => randomChoice(callerNames);
  static String randomMessageBody() => randomChoice(messageBodies);
  static List<String> randomMessageFlags() => randomChoice(flagsLists);


  static String randomPhoneNumber() {
    int firstDigit = rand.nextInt(8)+2;
    List<int> lastDigits = new List<int>.generate(8, (_) => rand.nextInt(10));
    List<int> digits = [firstDigit]..addAll(lastDigits);

    return digits.join('');
  }

  static String randomLocalExtension() => rand.nextInt(501).toString();


  /**
   * Constructs and returns a [Message] object with random content.
   *
   * The returned object still needs to have its context, user and
   * recipients set before it is a valid parameter to a messageStore.
   */
  static Model.Message randomMessage() {
    Model.Message message = new Model.Message();
    message..body = randomMessageBody()
        ..caller = randomCaller()
        ..createdAt = new DateTime.now()
        ..flags = randomMessageFlags();

    return message;
  }

  /**
   * Construct a random MessageCaller object.
   */
  static Model.MessageCaller randomCaller() =>
    new Model.MessageCaller()
      ..cellphone = randomPhoneNumber()
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