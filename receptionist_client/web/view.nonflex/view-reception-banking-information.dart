/*                  This file is part of OpenReception
                   Copyright (C) 2012-, BitStackers K/S

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

class ReceptionBankingInformation {
  final Context context;
  final Element element;

  bool            hasFocus  = false;

  bool get muted => this.context != Context.current;

  static const String className = '${libraryName}.ReceptionAlternateNames';
  static const String NavShortcut = 'X';
  List<Element> get nudges => this.element.querySelectorAll('.nudge');
  void set nudgesHidden(bool hidden) => this.nudges.forEach((Element element) => element.hidden = hidden);

  Element         get header                 => this.element.querySelector('legend');
  UListElement    get bankingInformationList => this.element.querySelector('#${Id.receptionBankingInformationList}');

  ReceptionBankingInformation(Element this.element, Context this.context) {
    assert(element.attributes.containsKey(defaultElementId));

    ///Navigation shortcuts
    keyboardHandler.registerNavShortcut(NavShortcut, (_) => this._select());

    header.children = [Icon.Bank,
                       new SpanElement()..text = Label.ReceptionBankingInformation,
                       new Nudge(NavShortcut).element];

    registerEventListeners();
  }

  void _select() {
    if (!muted) {
      Controller.Context.changeLocation(new nav.Location(context.id, element.id, bankingInformationList.id));
    }
  }

  void registerEventListeners() {
    event.bus.on(event.keyNav).listen((bool isPressed) => this.nudgesHidden = !isPressed);

    Model.Reception.onReceptionChange.listen(render);

    element.onClick.listen((_) {
      event.bus.fire(event.locationChanged, new nav.Location(context.id, element.id, bankingInformationList.id));
    });

    event.bus.on(event.locationChanged).listen((nav.Location location) {
      bool active = location.widgetId == element.id;
      element.classes.toggle(CssClass.focus, active);
      if(active) {
        bankingInformationList.focus();
      }
    });
  }

  void render(Model.Reception reception) {
    bankingInformationList.children.clear();

    for(var bankingInformation in reception.bankingInformation) {
      bankingInformationList.children.add(new LIElement()
                        ..text = bankingInformation);
    }
  }
}
