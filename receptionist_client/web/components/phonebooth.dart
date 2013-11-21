part of components;

class Phonebooth {
  DivElement element;
  ButtonElement call;
  InputElement inputField;

  Phonebooth(DivElement this.element) {
    call = new ButtonElement()
      ..text = 'Ring op';

    inputField = new TextInputElement()
      ..placeholder = 'Indtask telefon nummer';

    element.children.addAll([inputField, call]);

    registerEventListeners();
  }

  void registerEventListeners() {
    call.onClick.listen((_) {
      String dialStrig = inputField.value;
      protocol.originateCall(dialStrig).then((protocol.Response<Map> response) {
        print('phonebooth: ${response.data.toString()}');
      });
    });
  }
}