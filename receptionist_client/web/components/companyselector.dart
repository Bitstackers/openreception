part of components;

class CompanySelector {
  static const String                      _searchInputId = 'company-selector-searchbar';
  DivElement                               element;
  Context                                  context;
  SearchComponent<model.BasicReception> search;

  CompanySelector(DivElement this.element, Context this.context) {
    search = new SearchComponent<model.BasicReception>(element, context, _searchInputId)
      ..searchPlaceholder = 'Søg efter en virksomhed'
      ..whenClearSelection = whenClearSelection
      ..listElementToString = listElementToString
      ..searchFilter = searchFilter
      ..selectedElementChanged = elementSelected;

    initialFill();
    registerEventlisteners();
  }

  void initialFill() {
    storage.getReceptionList().then((model.ReceptionList list) {
      search.updateSourceList(list.toList(growable: false));
    });
  }

  void registerEventlisteners() {
    event.bus.on(event.receptionChanged).listen((model.BasicReception value) {
      if(value == model.nullReception) {
        search.clear();

      } else {
        search.selectElement(value, _receptionEquality);
      }
    });
  }

  bool _receptionEquality(model.BasicReception x, model.BasicReception y) => x.id == y.id;

  void whenClearSelection() {
    event.bus.fire(event.receptionChanged, model.nullReception);
  }

  String listElementToString(model.BasicReception reception, String searchText) {
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

  bool searchFilter(model.BasicReception reception, String searchText) {
    return reception.name.toLowerCase().contains(searchText.toLowerCase());
  }

  void elementSelected(model.BasicReception reception) {
    storage.getReception(reception.id).then((model.Reception value) {
      event.bus.fire(event.receptionChanged, value);
    });
  }
}