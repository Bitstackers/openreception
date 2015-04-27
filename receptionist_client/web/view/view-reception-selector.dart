part of view;

/**
 * TODO (TL): Comment
 */
class ReceptionSelector extends ViewWidget {
  final Controller.Destination    _myDestination;
  final Model.UIReceptionSelector _ui;

  /**
   * Constructor.
   */
  ReceptionSelector(Model.UIModel this._ui,
                    Controller.Destination this._myDestination) {
    _observers();

    test(); // TODO (TL): Get rid of this testing code...
  }

  @override Controller.Destination get myDestination => _myDestination;
  @override Model.UIModel          get ui            => _ui;

  @override void onBlur(_){}
  @override void onFocus(_){}

  /**
   * Activate this widget if it's not already activated.
   */
  void activateMe(_) {
    navigateToMyDestination();
  }

  /**
   * Observers.
   */
  void _observers() {
    _navigate.onGo.listen(setWidgetState);

    _hotKeys.onAltV.listen(activateMe);

    _ui.onClick.listen(activateMe);
  }

  /// TODO (TL): Get rid of this. It's just here to test stuff. These
  /// [Reception] objects should come from one of Kims service methods.
  void test() {
    List<String> addresses = ['Et eller andet sted i Stenløse', 'Et eller andet sted i Hundested'];

    List<String> altNames = ['Chaching A/S', 'FooBar ApS'];

    List<String> bankInfo = ['Den Danske Bank 5555-56565656',
                             'Nordea 4444-23232323',
                             'BSCH 789988-1624346513',
                             'Swift: 226564831358463asdSd',
                             'Bitcoin adresse: #4545646546546812'];

    List<String> commands = ['Command 1',
                             'Command 2',
                             'Command 3',
                             'Command 4',
                             'Command 5'];

    List<String> email = ['foo@somedomain.host', 'bar@otherdomain.host'];

    String miniWiki = '''
## En spændende overskrift
Noget tekst der bare står i en <p>

* en liste
* med nogle punkter
* af forskellig slags

Og så lige en afsluttende bemærkning..
''';

    String product = 'Vi sælger gummiænder og andet hurlumhej til fester i badekar\nFooBar og stads';

    List<String> openingHours = ['Opening hour 1',
                                 'Opening hour 2',
                                 'Opening hour 3',
                                 'Opening hour 4',
                                 'Opening hour 5'];

    List<String> salesMen = ['Salesmen 1',
                             'Salesmen 2',
                             'Salesmen 3',
                             'Salesmen 4',
                             'Salesmen 5'];

    List<TelNum> telephoneNumbers = [new TelNum(1, '60431990', 'label 1', false),
                                     new TelNum(2, '60431991', 'label 2', false),
                                     new TelNum(3, '60431992', 'label 3', true),
                                     new TelNum(4, '60431993', 'label 4', false)];

    List<String> type = ['Vi svarer alle deres kald.',
                         'Deres support afdeling sender kald til os når de har ventet længere end 2 minutter hos dem.',
                         'Direktøren omstiller også sin mobil til os.'];

    List<String> VATNumbers = ['1212-5656',
                               '4545-8989',
                               '3232-5665 (holding selskab)',
                               '12122325-879798-55455 (Engelsk moderselskab)',
                               '1232-9666'];

    List<String> websites = ['www.responsum.dk',
                             'www.huset-responsum.dk',
                             'huset.responsum.dk',
                             'foo.bar',
                             'DoodleDaadle.com'];

    _ui.receptions = [new Reception(1, 'Responsum K/S')
                        ..addresses = addresses
                        ..altNames = altNames
                        ..bankInfo = bankInfo
                        ..commands = commands
                        ..email = email
                        ..miniWikiMarkdown = miniWiki
                        ..openingHours = openingHours
                        ..product = product
                        ..salesMen = salesMen
                        ..telephoneNumbers = telephoneNumbers
                        ..type = type
                        ..VATNumbers = VATNumbers
                        ..websites = websites
                      ,
                      new Reception(2, 'Bitstackers K/S')
                        ..addresses = addresses
                        ..altNames = altNames
                        ..bankInfo = bankInfo
                        ..commands = commands
                        ..email = email
                        ..miniWikiMarkdown = miniWiki
                        ..openingHours = openingHours
                        ..product = product
                        ..salesMen = salesMen
                        ..telephoneNumbers = telephoneNumbers
                        ..type = type
                        ..VATNumbers = VATNumbers
                        ..websites = websites
                      ,
                      new Reception(3, 'Loecke K/S')
                        ..addresses = addresses
                        ..altNames = altNames
                        ..bankInfo = bankInfo
                        ..commands = commands
                        ..email = email
                        ..miniWikiMarkdown = miniWiki
                        ..openingHours = openingHours
                        ..product = product
                        ..salesMen = salesMen
                        ..telephoneNumbers = telephoneNumbers
                        ..type = type
                        ..VATNumbers = VATNumbers
                        ..websites = websites
                      ,
                      new Reception(4, 'Another Loecke K/S')
                        ..addresses = addresses
                        ..altNames = altNames
                        ..bankInfo = bankInfo
                        ..commands = commands
                        ..email = email
                        ..miniWikiMarkdown = miniWiki
                        ..openingHours = openingHours
                        ..product = product
                        ..salesMen = salesMen
                        ..telephoneNumbers = telephoneNumbers
                        ..type = type
                        ..VATNumbers = VATNumbers
                        ..websites = websites
                      ,
                      new Reception(5, 'Another Responsum K/S')
                        ..addresses = addresses
                        ..altNames = altNames
                        ..bankInfo = bankInfo
                        ..commands = commands
                        ..email = email
                        ..miniWikiMarkdown = miniWiki
                        ..openingHours = openingHours
                        ..product = product
                        ..salesMen = salesMen
                        ..telephoneNumbers = telephoneNumbers
                        ..type = type
                        ..VATNumbers = VATNumbers
                        ..websites = websites
                      ,
                      new Reception(6, 'FooBar K/S')
                        ..addresses = addresses
                        ..altNames = altNames
                        ..bankInfo = bankInfo
                        ..commands = commands
                        ..email = email
                        ..miniWikiMarkdown = miniWiki
                        ..openingHours = openingHours
                        ..product = product
                        ..salesMen = salesMen
                        ..telephoneNumbers = telephoneNumbers
                        ..type = type
                        ..VATNumbers = VATNumbers
                        ..websites = websites];

  }
}
