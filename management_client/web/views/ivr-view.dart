library ivr_view;

import 'dart:html';

import '../lib/eventbus.dart';
import '../lib/model.dart';
import '../lib/request.dart' as request;
import '../lib/searchcomponent.dart';

class IvrView {
  String viewName = 'ivr';

  DivElement element;
  DivElement receptionOuterSelector;
  UListElement menuList;
  ButtonElement newButton;
  ButtonElement saveButton;
  TableSectionElement contentBody;

  SearchComponent receptionPicker;
  IvrView(DivElement this.element) {
    menuList = element.querySelector('#ivr-menu-list');
    newButton = element.querySelector('#ivr-new-menu');
    saveButton = element.querySelector('#ivr-save');
    contentBody = element.querySelector('#ivr-content-body');

    receptionOuterSelector = element.querySelector('#ivr-receptionpicker');
    receptionPicker = new SearchComponent<Reception>(receptionOuterSelector,
        'ivr-reception-searchbox')
        ..listElementToString = receptionToSearchboxString
        ..searchFilter = receptionSearchHandler;

    fillSearchComponent();

    registrateEventHandlers();
  }

  void registrateEventHandlers() {
    bus.on(windowChanged).listen((Map event) {
      element.classes.toggle('hidden', event['window'] != viewName);
    });

    receptionPicker.selectedElementChanged = (Reception reception) {
      loadReceptionData(reception.id);
    };

    newButton.onClick.listen((_) {
      //TODO
    });

    saveButton.onClick.listen((_) {
      //TODO
    });
  }

  void loadReceptionData(int receptionId) {
    renderMenuList(['First', 'Second', 'Taxi${receptionId*318}']);
  }

  String receptionToSearchboxString(Reception reception, String searchterm) {
    return '${reception.full_name}';
  }

  bool receptionSearchHandler(Reception reception, String searchTerm) {
    return reception.full_name.toLowerCase().contains(searchTerm.toLowerCase());
  }

  void fillSearchComponent() {
    request.getReceptionList().then((List<Reception> list) {
      list.sort((a, b) => a.full_name.compareTo(b.full_name));
      receptionPicker.updateSourceList(list);
    });
  }

  void renderMenuList(List menus) {
    menuList.children.addAll(menus.map(makeMenuListItem));
  }

  LIElement makeMenuListItem(item) {
    return new LIElement()
      ..children.addAll(
          [new SpanElement()
            ..text = item.toString()
            ..onClick.listen((_) {
                loadIVR(item);
              }),
           new ImageElement(src: 'image/tp/line.svg')..classes.add('ivr-small-button'),
           new ImageElement(src: 'image/tp/red_plus.svg')..classes.add('ivr-small-button')]);
  }

  void loadIVR(Ivr) {

  }
}