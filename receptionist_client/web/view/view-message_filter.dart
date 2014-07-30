part of view;

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

  ButtonElement get saveMessageButton            => this.element.querySelector('button.save');
  ButtonElement get resendMessageButton          => this.element.querySelector('button.resend');
  
  MessageFilter(Element this.element, Context this._context) {
    assert(element != null);

    body = querySelector('.message-search-box');

    agentSearch = new SearchComponent<String>(body.querySelector('#message-search-agent'), _context, 'message-search-agent-searchbar')
      ..searchPlaceholder = 'Agent...'
      ..updateSourceList(['Alle', '1', '2', '10'])
      ..selectElement('Alle')
      ..selectedElementChanged = (String text) {
        if (text != 'Alle') {
          model.MessageFilter.current.userID = int.parse(text);
        } else {
          model.MessageFilter.current.userID = null;
        }
        searchParametersChanged();
    };

    typeSearch = new SearchComponent<String>(body.querySelector('#message-search-type'), _context, 'message-search-type-searchbar')
      ..searchPlaceholder = 'Type...'
      ..updateSourceList(['Alle', 'Sendte', 'Gemte', 'Venter'])
      ..selectElement('Alle')
      ..selectedElementChanged = (String text) {
      switch (text) {
        case 'Sendte':
          model.MessageFilter.current.state = model.MessageState.Sent;          
          
          break;
          
        case 'Gemte':
          model.MessageFilter.current.state = model.MessageState.Saved;          
          break;
          
        case 'Venter':
          model.MessageFilter.current.state = model.MessageState.Pending;          
          break;

        default:
          break;
          
      }

      searchParametersChanged();
    };
      
    companySearch = new SearchComponent<model.BasicReception>(body.querySelector('#message-search-company'), _context, 'message-search-company-searchbar')
      ..searchPlaceholder = 'Virksomheder...'
      ..selectedElementChanged = (model.BasicReception receptionStub) {
      if (receptionStub == model.nullReception) {
        model.MessageFilter.current.receptionID = null;
        model.MessageFilter.current.contactID = null;
        contactSearch.updateSourceList([model.nullContact]);
        searchParametersChanged();
        return;
      }
        model.Reception.get(receptionStub.ID).then((model.Reception reception) {

            model.MessageFilter.current.receptionID = reception.ID;
            model.MessageFilter.current.contactID = null;
          searchParametersChanged();
          
          model.Contact.list(reception.ID).then((model.ContactList contacts) {
            contactSearch.updateSourceList([model.nullContact..name = 'Alle']..addAll(contacts));
          }).catchError((error) {
            contactSearch.updateSourceList(new model.ContactList.emptyList().toList(growable: false));
          });
        });
      }
      ..searchFilter = (model.BasicReception reception, String searchText) {
        return reception.name.toLowerCase().contains(searchText.toLowerCase());
      }
      ..listElementToString = companyListElementToString;

      storage.Reception.list().then((model.ReceptionList contacts) {
        companySearch.updateSourceList([model.nullReception..name = 'Alle']..addAll(contacts));
      });

    contactSearch = new SearchComponent<model.Contact>(body.querySelector('#message-search-contact'), _context, 'message-search-contact-searchbar')
      ..searchPlaceholder = 'Medarbejdere...'
      ..listElementToString = contactListElementToString
      ..searchFilter = (model.Contact contact, String searchText) {
        return contact.name.toLowerCase().contains(searchText.toLowerCase());
      }
      ..selectedElementChanged = (model.Contact contact) {
        if (contact == model.nullContact) {
          model.MessageFilter.current.contactID = null;
        } else {
          model.MessageFilter.current.contactID = contact.id;
        }
        
        searchParametersChanged();
      };

    //_context.registerFocusElement(body.querySelector('#message-search-print'));
    //_context.registerFocusElement(body.querySelector('#message-search-resend'));
    
  
      
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
    event.bus.fire(event.messageFilterChanged, model.MessageFilter.current);
  }
}
