part of view;

class ReceptionSelector {

  static const String className = '${libraryName}.ReceptionSelector';
  static const String NavShortcut = 'V';

  final DivElement                      element;
  final Context                         uiContext;
  SearchComponent<model.BasicReception> search;
  model.BasicReception                  selectedReception;
  bool get muted     => this.uiContext != Context.current;
  dynamic onSelectReception = () => null;

  List<Element> get nudges => this.element.querySelectorAll('.nudge');
  void set nudgesHidden(bool hidden) => this.nudges.forEach((Element element) => element.hidden = hidden);

  ReceptionSelector(DivElement this.element, Context this.uiContext) {
    assert (element.attributes.containsKey(defaultElementId));

    ///Navigation shortcuts
    keyboardHandler.registerNavShortcut(NavShortcut, this._select);

    String searchBoxId = element.attributes['data-default-element'];

    search = new SearchComponent<model.BasicReception>(element, uiContext, searchBoxId)
      ..searchPlaceholder = 'Søg efter en virksomhed'
      ..whenClearSelection = whenClearSelection
      ..listElementToString = listElementToString
      ..searchFilter = searchFilter
      ..selectedElementChanged = elementSelected;

    this.initialFill().then(this._registerEventlisteners);
  }

  void _select (_) {
    const String context = '${className}._select';
    log.debugContext('${this.uiContext} : ${Context.current}', context);

    if (!this.muted) {
      Controller.Context.changeLocation(new nav.Location(uiContext.id, element.id, element.attributes[defaultElementId]));
    }
  }

  Future initialFill() {
    return storage.Reception.list().then((model.ReceptionList list) {
      search.updateSourceList(list.toList(growable: false));
      return this.element.append(new Nudge(NavShortcut).element);
    });
  }

  void _registerEventlisteners(_) {
    event.bus.on(event.keyNav).listen((bool isPressed) => this.nudgesHidden = !isPressed);

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
    new Future(() => Controller.Reception.change (model.nullReception));
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

  void elementSelected(model.BasicReception receptionStub) {
    storage.Reception.get(receptionStub.ID).then((model.Reception reception) {
      Controller.Reception.change (reception);
      this.onSelectReception(); //Callback function.

    });
  }
}