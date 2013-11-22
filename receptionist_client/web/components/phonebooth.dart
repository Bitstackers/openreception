part of components;

class Phonebooth {
  Box box;
  ButtonElement call;
  DivElement container;
  DivElement element;
  SpanElement header;
  InputElement inputField;

  final String headerText = 'Telefon';
  final String dialButtonText = 'Ring op';
  final String dialFieldPlaceholder = 'Indtast nummer';
  final String companyPlaceholder = 'Virksomhed';

  Phonebooth(DivElement this.element) {
    header = new SpanElement()
      ..text = headerText;

    String html = '''
    <div>
      <input id="phonebooth-company" type="text" placeholder="${companyPlaceholder}" value="Adaheads" readonly></input>
      <input id="phonebooth-numberfield" type="search" placeholder="${dialFieldPlaceholder}"></input>
      <button id="phonebooth-button">${dialButtonText}</button>
    <div>
    ''';

    container = new DocumentFragment.html(html).querySelector('div');

    inputField = container.querySelector('#phonebooth-numberfield');
    call = container.querySelector('#phonebooth-button');

    box = new Box.withHeader(element, header, container);

    registerEventListeners();
  }

  void registerEventListeners() {
    call.onClick.listen((_) {
      dial();
    });

    inputField.onKeyDown.listen((KeyboardEvent event) {
      if(event.keyCode == Keys.ENTER) {
        dial();
      }
    });
  }

  void dial() {
    String dialStrig = inputField.value;
    protocol.originateCall(dialStrig).then((protocol.Response<Map> response) {
      print('phonebooth: ${response.data.toString()}');
    });
  }
}