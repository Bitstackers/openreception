part of components;

class CompanySelector {
  DivElement                            element;
  Context                               context;
  SearchComponent<model.BasicReception> search;
  model.BasicReception                  selectedReception;

  CompanySelector(DivElement this.element, Context this.context) {
    if(element.attributes.containsKey('data-default-element')) {
      String searchBoxId = element.attributes['data-default-element'];
        
      search = new SearchComponent<model.BasicReception>(element, context, searchBoxId)
        ..searchPlaceholder = 'Søg efter en virksomhed'
        ..whenClearSelection = whenClearSelection
        ..listElementToString = listElementToString
        ..searchFilter = searchFilter
        ..selectedElementChanged = elementSelected;
    
      initialFill();
      registerEventlisteners(); 
    } else {
      log.error('components.CompanySelector.CompanySelector() element does not have a data-default-element.');
    }
  }

  void initialFill() {
    storage.getReceptionList().then((model.ReceptionList list) {
      search.updateSourceList(list.toList(growable: false));
    });
  }

  void registerEventlisteners() {
    event.bus.on(event.receptionChanged).listen((model.BasicReception value) {
      if(value == model.nullReception && selectedReception != model.nullReception) {
        search.clearSelection();
        
      } else {
        search.selectElement(value, _receptionEquality);
      }
      selectedReception = value;
    });
  }

  bool _receptionEquality(model.BasicReception x, model.BasicReception y) => x.id == y.id;

  void whenClearSelection() {
    new Future(() => event.bus.fire(event.receptionChanged, model.nullReception));
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
    storage.Reception.get(reception.id).then((model.Reception value) {
      event.bus.fire(event.receptionChanged, value);
    });
  }
}