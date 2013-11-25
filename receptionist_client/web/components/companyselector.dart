part of components;

class CompanySelector {
  static const String                      _searchInputId = 'company-selector-searchbar';
  DivElement                               element;
  Context                                  context;
  SearchComponent<model.BasicOrganization> search;

  CompanySelector(DivElement this.element, Context this.context) {
    search = new SearchComponent<model.BasicOrganization>(element, context, _searchInputId)
      ..searchPlaceholder = 'Søg efter en virksomhed'
      ..whenClearSelection = whenClearSelection
      ..listElementToString = listElementToString
      ..searchFilter = searchFilter
      ..selectedElementChanged = elementSelected;

    initialFill();
    registerEventlisteners();
  }

  void initialFill() {
    storage.getOrganizationList().then((model.OrganizationList list) {
      search.updateSourceList(list.toList(growable: false));
    });
  }

  void registerEventlisteners() {
    event.bus.on(event.organizationChanged).listen((model.BasicOrganization value) {
      if(value == model.nullOrganization) {
        search.clear();

      } else {
        search.selectElement(value, _organizationEquality);
      }
    });
  }

  bool _organizationEquality(model.BasicOrganization x, model.BasicOrganization y) {
    return x.id == y.id;
  }

  void whenClearSelection() {
    event.bus.fire(event.organizationChanged, model.nullOrganization);
  }

  String listElementToString(model.BasicOrganization org, String searchText) {
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

  bool searchFilter(model.BasicOrganization org, String searchText) {
    return org.name.toLowerCase().contains(searchText.toLowerCase());
  }

  void elementSelected(model.BasicOrganization org) {
    storage.getOrganization(org.id).then((model.Organization value) {
      event.bus.fire(event.organizationChanged, value);
    });
  }
}