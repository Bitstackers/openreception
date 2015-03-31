/*                  This file is part of OpenReception
                   Copyright (C) 2014-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of view;

class ReceptionSelector {
  static final Logger log = new Logger('${libraryName}.ReceptionSelector');

  static const String className = '${libraryName}.ReceptionSelector';
  static const String NavShortcut = 'V';

  final DivElement                       element;
  final Context                          uiContext;
  Component.SearchComponent<model.ReceptionStub>   search;
  model.ReceptionStub                    selectedReception = new model.ReceptionStub.none();
  bool get muted     => this.uiContext != Context.current;
  dynamic onSelectReception = () => null;

  List<Element> get nudges => this.element.querySelectorAll('.nudge');
  void set nudgesHidden(bool hidden) => this.nudges.forEach((Element element) => element.hidden = hidden);

  ReceptionSelector(DivElement this.element, Context this.uiContext) {
    assert (element.attributes.containsKey(defaultElementId));

    ///Navigation shortcuts
    keyboardHandler.registerNavShortcut(NavShortcut, this._select);

    String searchBoxId = element.attributes['data-default-element'];

    search = new Component.SearchComponent<model.ReceptionStub>(element, uiContext, searchBoxId)
      ..searchPlaceholder = Label.ReceptionSearch
      ..whenClearSelection = whenClearSelection
      ..listElementToString = listElementToString
      ..searchFilter = searchFilter
      ..selectedElementChanged = elementSelected;

    this.initialFill().then(this._registerEventlisteners);
  }

  void _select (_) {
    log.finest('${this.uiContext} : ${Context.current}');

    if (!this.muted) {
      Controller.Context.changeLocation(new nav.Location(uiContext.id, element.id, element.attributes[defaultElementId]));
    }
  }

  Future initialFill() {
    return storage.Reception.list().then((List<model.ReceptionStub> list) {
      search.updateSourceList(list.toList(growable: false));
      return this.element.append(new Nudge(NavShortcut).element);
    });
  }

  void _registerEventlisteners(_) {
    event.bus.on(event.keyNav).listen((bool isPressed) => this.nudgesHidden = !isPressed);

    model.Reception.onReceptionChange.listen((model.Reception value) {
      if(value == model.Reception.noReception && selectedReception.isNotNull()) {
        search.clearSelection();

      } else {
        search.selectElement(value.toStub(), _receptionEquality);
      }
      selectedReception = value.toStub();
    });
  }

  bool _receptionEquality(model.ReceptionStub x, model.ReceptionStub y) => x.ID == y.ID;

  void whenClearSelection() {
    new Future(() => Controller.Reception.change (model.Reception.noReception));
  }

  String listElementToString(model.ReceptionStub reception, String searchText) {
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

  bool searchFilter(model.ReceptionStub reception, String searchText) {
    return reception.name.toLowerCase().contains(searchText.toLowerCase());
  }

  void elementSelected(model.ReceptionStub receptionStub) {
    storage.Reception.get(receptionStub.ID).then((model.Reception reception) {
      Controller.Reception.change (reception);
      this.onSelectReception(); //Callback function.

    });
  }
}