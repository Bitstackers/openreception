part of management_tool.view;

/**
 *
 */
class Phonenumbers {
  final Logger _log = new Logger('$_libraryName.Phonenumbers');

  final DivElement element = new DivElement();
  bool _validationError = false;
  bool get validationError => _validationError;

  final ButtonElement _addNew = new ButtonElement()
    ..text = 'Indsæt ny tom'
    ..classes.add('create');

  Function onChange;

  final TextAreaElement _phonenumberInput = new TextAreaElement()
    ..style.height = '15em'
    ..classes.add('wide');

  /**
     *
     */
  Phonenumbers() {
    element.children = [_addNew, _phonenumberInput];
    _observers();
  }

  /**
   *
   */
  void _observers() {
    _addNew.onClick.listen((_) {
      final model.PhoneNumber pn = new model.PhoneNumber.empty()
        ..billing_type = 'dansk mobil'
        ..confidential = true
        ..description = 'Kort beskrivelse'
        ..endpoint = '00000000'
        ..tags = ['Kontor']
        ..type = 'mobil';

      phoneNumbers = phoneNumbers.toList()..add(pn);

      if (onChange != null) {
        onChange();
      }
    });

    _phonenumberInput.onInput.listen((_) {
      _validationError = false;
      _phonenumberInput.classes.toggle('error', false);
      try {
        final dlist = phoneNumbers;

        ///TODO: Validate endpoints
      } on FormatException {
        _validationError = true;
        _phonenumberInput.classes.toggle('error', true);
      }

      if (onChange != null) {
        onChange();
      }
    });
  }

  /**
   *
   */
  void set phoneNumbers(Iterable<model.PhoneNumber> pns) {
    _phonenumberInput.value = _jsonpp.convert(pns.toList(growable: false));
  }

  /**
   *
   */
  Iterable<model.PhoneNumber> get phoneNumbers => JSON
      .decode(_phonenumberInput.value)
      .map((m) => new model.PhoneNumber.fromMap(m));
}
