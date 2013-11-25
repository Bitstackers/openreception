part of components;

class Phonebooth {
  Box box;
  ButtonElement call;
  DivElement container;
  Context context;
  DivElement element;
  SpanElement header;
  InputElement inputField;
  SearchComponent<model.BasicOrganization> companySearch;
  model.Organization organizationSelected;

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
      <button id="phonebooth-button">${dialButtonText}</button>
    <div>
    ''';

    container = new DocumentFragment.html(html).querySelector('div');

    inputField = container.querySelector('#phonebooth-numberfield');
    call = container.querySelector('#phonebooth-button');
    companySearch = new SearchComponent<model.BasicOrganization>(container.querySelector('#phonebooth-company'), context, 'phonebooth-company-searchbar')
      ..searchPlaceholder = 'Søg på virksomheder...'
      ..selectedElementChanged = (model.BasicOrganization element) {
        storage.getOrganization(element.id).then((model.Organization value) {
          changeOrganization(value);
        });
      }
      ..searchFilter = (model.BasicOrganization org, String searchText) {
        return org.name.toLowerCase().contains(searchText.toLowerCase());
      }
      ..listElementToString = companyListElementToString;

      storage.getOrganizationList().then((model.OrganizationList list) {
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

  String companyListElementToString(model.BasicOrganization org, String searchText) {
    if(searchText == null || searchText.isEmpty) {
      return org.name;
    } else {
      String text = org.name;
      int matchIndex = text.toLowerCase().indexOf(searchText.toLowerCase());
      String before  = text.substring(0, matchIndex);
      String match   = text.substring(matchIndex, matchIndex + searchText.length);
      String after   = text.substring(matchIndex + searchText.length, text.length);
      return '${before}<em>${match}</em>${after}';
    }
  }

  void changeOrganization(model.Organization value) {
    if(value != null) {
      organizationSelected = value;
      call.disabled = value == model.nullOrganization;
    }
  }
}