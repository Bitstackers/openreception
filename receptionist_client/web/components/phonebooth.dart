part of components;

class Phonebooth {
  Box box;
  ButtonElement call;
  DivElement container;
  Context context;
  DivElement element;
  SpanElement header;
  InputElement inputField;
  SearchComponent<model.BasicReception> companySearch;
  model.Reception receptionSelected;

  final String headerText = 'Telefon';
  final String dialButtonText = 'Ring op';
  final String dialFieldPlaceholder = 'Indtast nummer';
  final String companyPlaceholder = 'Virksomhed';

  Phonebooth(DivElement this.element, Context this.context) {
    header = new SpanElement()
      ..text = headerText;

    String html = '''
    <div>
      <div id="phonebooth-company"></div>
      <input id="phonebooth-numberfield" type="search" placeholder="${dialFieldPlaceholder}"></input>
      <button id="phonebooth-button" disabled="disabled">${dialButtonText}</button>
    <div>
    ''';

    container = new DocumentFragment.html(html).querySelector('div');

    inputField = container.querySelector('#${id.PHONEBOOTH_NUMBERFIELD}');
    call = container.querySelector('#phonebooth-button');
    companySearch = new SearchComponent<model.BasicReception>(container.querySelector('#phonebooth-company'), context, 'phonebooth-company-searchbar')
      ..searchPlaceholder = 'Søg på virksomheder...'
      ..selectedElementChanged = (model.BasicReception element) {
        storage.getReception(element.id).then((model.Reception value) {
          changeReception(value);
        });
      }
      ..searchFilter = (model.BasicReception reception, String searchText) {
        return reception.name.toLowerCase().contains(searchText.toLowerCase());
      }
      ..listElementToString = companyListElementToString;

      storage.getReceptionList().then((model.ReceptionList list) {
        companySearch.updateSourceList(list.toList(growable: false));
      });

    box = new Box.withHeader(element, header, container);

    context.registerFocusElement(inputField);
    context.registerFocusElement(call);

    registerEventListeners();
  }

  void registerEventListeners() {
    call.onClick.listen((_) {
      dial();
      inputField.value = '';
    });

    inputField.onKeyDown.listen((KeyboardEvent event) {
      if(event.keyCode == Keys.ENTER) {
        dial();
        inputField.value = '';
      }
    });
    
    element.onClick.listen((MouseEvent e) {
      event.bus.fire(event.locationChanged, new nav.Location(context.id, element.id, (e.target as HtmlElement).id));
    });
    
    event.bus.on(event.locationChanged).listen((nav.Location location) {
      bool active = location.widgetId == element.id;
      element.classes.toggle(FOCUS, active);
      if(active) {
        inputField.focus();
      }
    });
  }

  void dial() {
    if(receptionSelected != model.nullReception) {
      String dialStrig = inputField.value;
      protocol.originateCallFromExtension(receptionSelected.id, dialStrig).then((protocol.Response<Map> response) {
        if(response.status == protocol.Response.OK) {
          log.info('Ringede op til ${dialStrig}', toUserLog: true);
          log.info('Agent ${configuration.userId} called ${dialStrig} of fik ${response.data['call']['id']}');

        } else {
          log.info('Forsøgte at ringe op til ${dialStrig} men fejlede', toUserLog: true);
          log.info('Agent ${configuration.userId} called ${dialStrig} but failed. ${response.statusText}');
        }
      });

    } else {
      log.debug('phonebooth. There is no reception selected.');
    }
  }

  String companyListElementToString(model.BasicReception reception, String searchText) {
    if(searchText == null || searchText.isEmpty) {
      return reception.name;
    } else {
      String text = reception.name;
      int matchIndex = text.toLowerCase().indexOf(searchText.toLowerCase());
      String before  = text.substring(0, matchIndex);
      String match   = text.substring(matchIndex, matchIndex + searchText.length);
      String after   = text.substring(matchIndex + searchText.length, text.length);
      return '${before}<em>${match}</em>${after}';
    }
  }

  void changeReception(model.Reception value) {
    if(value != null) {
      receptionSelected = value;
      call.disabled = value == model.nullReception;
    }
  }
}