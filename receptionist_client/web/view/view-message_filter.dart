part of view;

abstract class MessageFilterLabels {

  static const String Resend = 'Gensend';
  static const String EditMessage = 'Rediger besked';
  static const String Filter = 'Filtrér beskeder';
  static const String Save = 'Gem';
}

class MessageFilter{
  DivElement body;
  Context _context;
  Element element;
  SpanElement header;

  DivElement agent;
  DivElement type;
  DivElement company;
  DivElement contact;

  SearchComponent<String> agentSearch;
  SearchComponent<String> typeSearch;
  SearchComponent<model.BasicReception> companySearch;
  SearchComponent<model.Contact> contactSearch;

  ButtonElement get saveMessageButton            => this.element.querySelector('button.previous');
  ButtonElement get resendMessageButton          => this.element.querySelector('button.resend');
  
  String selectedAgent;
  String selectedType;
  model.BasicReception selectedCompany = model.nullReception;
  model.Contact selectedContact = model.nullContact;

  String headerText = 'Søgning';
  MessageFilter(Element this.element, Context this._context) {
    assert(element != null);

    body = querySelector('.message-search-box');

    agentSearch = new SearchComponent<String>(body.querySelector('#message-search-agent'), _context, 'message-search-agent-searchbar')
      ..searchPlaceholder = 'Agent...'
      ..updateSourceList(['Alle', 'Trine', 'Thomas', 'Kim'])
      ..selectElement('Alle')
      ..selectedElementChanged = (String text) {
        selectedAgent = text;
        searchParametersChanged();
    };

    typeSearch = new SearchComponent<String>(body.querySelector('#message-search-type'), _context, 'message-search-type-searchbar')
      ..searchPlaceholder = 'Type...'
      ..updateSourceList(['Alle', 'Sendte', 'Gemte', 'Kladder'])
      ..selectElement('Alle')
      ..selectedElementChanged = (String text) {
        selectedType = text;
        searchParametersChanged();
      };

    companySearch = new SearchComponent<model.BasicReception>(body.querySelector('#message-search-company'), _context, 'message-search-company-searchbar')
      ..searchPlaceholder = 'Virksomheder...'
      ..selectedElementChanged = (model.BasicReception reception) {
        model.Reception.get(reception.ID).then((model.Reception value) {
          selectedCompany = value;
          searchParametersChanged();
          
          model.Contact.list(value.ID).then((model.ContactList list) {
            contactSearch.updateSourceList(list.toList(growable: false));
          }).catchError((error) {
            contactSearch.updateSourceList(new model.ContactList.emptyList().toList(growable: false));
          });
        });
      }
      ..searchFilter = (model.BasicReception reception, String searchText) {
        return reception.name.toLowerCase().contains(searchText.toLowerCase());
      }
      ..listElementToString = companyListElementToString;

      storage.Reception.list().then((model.ReceptionList list) {
        companySearch.updateSourceList(list.toList(growable: false));
      });

    contactSearch = new SearchComponent<model.Contact>(body.querySelector('#message-search-contact'), _context, 'message-search-contact-searchbar')
      ..searchPlaceholder = 'Medarbejdere...'
      ..listElementToString = contactListElementToString
      ..searchFilter = (model.Contact contact, String searchText) {
        return contact.name.toLowerCase().contains(searchText.toLowerCase());
      }
      ..selectedElementChanged = (model.Contact contact) {
        selectedContact = contact;
        searchParametersChanged();
      };

    //_context.registerFocusElement(body.querySelector('#message-search-print'));
    //_context.registerFocusElement(body.querySelector('#message-search-resend'));
    
    this._setLabels();
  }
  
  void _setLabels() {
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

  String contactListElementToString(model.Contact contact, String searchText) {
    if(searchText == null || searchText.isEmpty) {
      return contact.name;
    } else {
      String text = contact.name;
      int matchIndex = text.toLowerCase().indexOf(searchText.toLowerCase());
      String before  = text.substring(0, matchIndex);
      String match   = text.substring(matchIndex, matchIndex + searchText.length);
      String after   = text.substring(matchIndex + searchText.length, text.length);
      return '${before}<em>${match}</em>${after}';
    }
  }

  void searchParametersChanged() {
    log.debug('messagesearch. The search parameters have changed.');
    //event.bus.fire(event.messageSearchFilterChanged,
    //    new MessageSearchFilter(selectedAgent, selectedType, selectedCompany, selectedContact));
  }
}
