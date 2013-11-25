part of components;

class MessageSearch{
  DivElement body;
  Box box;
  Context _context;
  DivElement element;
  SpanElement header;

  DivElement agent;
  DivElement type;
  DivElement company;
  DivElement contact;

  SearchComponent<String> agentSearch;
  SearchComponent<String> typeSearch;
  SearchComponent<model.BasicOrganization> companySearch;
  SearchComponent<model.Contact> contactSearch;

  String headerText = 'Søgning';
  MessageSearch(DivElement this.element, Context this._context) {
    assert(element != null);
    header = new SpanElement()
      ..text = headerText;

    String html = '''
      <div class="message-search-box">
        <div id="message-search-agent"></div>
        <div id="message-search-type"></div>
        <div id="message-search-company"></div>
        <div id="message-search-contact"></div>
        
        <button>Print</button>
        <button>Gensend valgte</button>
      </div>
    ''';

    DocumentFragment frag = new DocumentFragment.html(html);
    body = frag.querySelector('div');
    box = new Box.withHeader(element, header, body);

    agentSearch = new SearchComponent<String>(body.querySelector('#message-search-agent'), _context, 'message-search-agent-searchbar')
      ..searchPlaceholder = 'Agent'
      ..updateSourceList(['Trine', 'Thomas', 'Kim'])
      ..selectedElementChanged = searchParametersChanged;

    typeSearch = new SearchComponent<String>(body.querySelector('#message-search-type'), _context, 'message-search-type-searchbar')
      ..searchPlaceholder = 'Type'
      ..updateSourceList(['Sendte', 'Gemte', 'Kladder'])
      ..selectedElementChanged = searchParametersChanged;

    companySearch = new SearchComponent<model.BasicOrganization>(body.querySelector('#message-search-company'), _context, 'message-search-company-searchbar')
      ..searchPlaceholder = 'Virksomhed'
      ..selectedElementChanged = (model.BasicOrganization element) {
        storage.getOrganization(element.id).then((model.Organization value) {
          contactSearch.updateSourceList(value.contactList.toList(growable: false));
        });
      }
      ..searchFilter = (model.BasicOrganization org, String searchText) {
        return org.name.toLowerCase().contains(searchText.toLowerCase());
      }
      ..listElementToString = companyListElementToString
      ..selectedElementChanged = searchParametersChanged;

      storage.getOrganizationList().then((model.OrganizationList list) {
        companySearch.updateSourceList(list.toList(growable: false));
      });

    contactSearch = new SearchComponent<model.Contact>(body.querySelector('#message-search-contact'), _context, 'message-search-contact-searchbar')
      ..searchPlaceholder = 'Medarbejdere'
      ..listElementToString = contactListElementToString
      ..searchFilter = (model.Contact contact, String searchText) {
        return contact.name.toLowerCase().contains(searchText.toLowerCase());
      }
      ..selectedElementChanged = searchParametersChanged;
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

  void searchParametersChanged(_) {
    log.debug('messagesearch. The search parameters have changed.');
  }
}
