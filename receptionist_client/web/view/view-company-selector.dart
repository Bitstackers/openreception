part of view;

class CompanySelector {
  DivElement                            element;
  Context                               context;
  SearchComponent<model.BasicReception> search;
  model.BasicReception                  selectedReception;
  List<Element> get nudges => this.element.querySelectorAll('.nudge');

  CompanySelector(DivElement this.element, Context this.context) {
    assert (element.attributes.containsKey(defaultElementId));
    
    String searchBoxId = element.attributes['data-default-element'];
        
    search = new SearchComponent<model.BasicReception>(element, context, searchBoxId)
      ..searchPlaceholder = 'Søg efter en virksomhed'
      ..whenClearSelection = whenClearSelection
      ..listElementToString = listElementToString
      ..searchFilter = searchFilter
      ..selectedElementChanged = elementSelected;
    
    this.initialFill().then(this._registerEventlisteners); 
  }

  Future initialFill() {
    return storage.Reception.list().then((model.ReceptionList list) {
      search.updateSourceList(list.toList(growable: false));
      return this.element.append(new Nudge('V').element); 
    });
  }

  void _registerEventlisteners(_) {
    event.bus.on(event.keyMeta).listen((bool isPressed) {
      this.hideNudges(!isPressed);
    });
    
    event.bus.on(event.receptionChanged).listen((model.BasicReception value) {
      if(value == model.nullReception && selectedReception != model.nullReception) {
        search.clearSelection();
        
      } else {
        search.selectElement(value, _receptionEquality);
      }
      selectedReception = value;
    });
  }

  bool _receptionEquality(model.BasicReception x, model.BasicReception y) => x.ID == y.ID;

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

  void hideNudges(bool hidden) {
    nudges.forEach((Element element) {
      element.hidden = hidden;
    });
  }

  bool searchFilter(model.BasicReception reception, String searchText) {
    return reception.name.toLowerCase().contains(searchText.toLowerCase());
  }

  void elementSelected(model.BasicReception reception) {
    storage.Reception.get(reception.ID).then((model.Reception value) {
      event.bus.fire(event.receptionChanged, value);
    });
  }
}