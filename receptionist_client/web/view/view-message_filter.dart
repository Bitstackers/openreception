part of view;

class MessageFilter{
  DivElement body;
  Context _context;
  Element element;
  SpanElement header;

  SearchComponent<String> agentSearch;
  SearchComponent<String> typeSearch;
  SearchComponent<model.ReceptionStub> companySearch;
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
          model.MessageFilter.current.messageState = ORModel.MessageState.Sent;

          break;

        case 'Gemte':
          model.MessageFilter.current.messageState = ORModel.MessageState.Saved;
          break;

        case 'Venter':
          model.MessageFilter.current.messageState = ORModel.MessageState.Pending;
          break;

        default:
          model.MessageFilter.current.messageState = null;
          break;

      }

      searchParametersChanged();
    };

    companySearch = new SearchComponent<model.ReceptionStub>(body.querySelector('#message-search-company'), _context, 'message-search-company-searchbar')
      ..searchPlaceholder = 'Virksomheder...'
      ..selectedElementChanged = (model.ReceptionStub receptionStub) {
      if (receptionStub.isNull()) {
        model.MessageFilter.current.receptionID = null;
        model.MessageFilter.current.contactID = null;
        contactSearch.updateSourceList([model.Contact.noContact]);
        searchParametersChanged();
        return;
      }
        storage.Reception.get(receptionStub.ID).then((model.Reception reception) {

          model.MessageFilter.current.receptionID = reception.ID;
          model.MessageFilter.current.contactID = null;
          searchParametersChanged();

          model.Contact.list(reception.ID).then((List<model.Contact> contacts) {
            contactSearch.updateSourceList([model.Contact.noContact..fullName = 'Alle']..addAll(contacts));
          }).catchError((error) {
            contactSearch.updateSourceList(new model.ContactList.emptyList().toList(growable: false));
          });
        });
      }
      ..searchFilter = (model.ReceptionStub reception, String searchText) {
        return reception.name.toLowerCase().contains(searchText.toLowerCase());
      }
      ..listElementToString = companyListElementToString;

      storage.Reception.list().then((List<model.ReceptionStub> receptions) {
        companySearch.updateSourceList(receptions.toList());
      });

    contactSearch = new SearchComponent<model.Contact>(body.querySelector('#message-search-contact'), _context, 'message-search-contact-searchbar')
      ..searchPlaceholder = 'Medarbejdere...'
      ..listElementToString = contactListElementToString
      ..searchFilter = (model.Contact contact, String searchText) {
        return contact.fullName.toLowerCase().contains(searchText.toLowerCase());
      }
      ..selectedElementChanged = (model.Contact contact) {
        if (contact == model.Contact.noContact) {
          model.MessageFilter.current.contactID = null;
        } else {
          model.MessageFilter.current.contactID = contact.ID;
        }

        searchParametersChanged();
      };
  }


  String companyListElementToString(model.ReceptionStub reception, String searchText) {
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
      return contact.fullName;
    } else {
      String text = contact.fullName;
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
