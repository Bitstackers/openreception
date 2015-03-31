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

class Contact {
         final Element             element;
               model.Contact       contact              = model.Contact.noContact;
               Context             context;
               UListElement        displayedContactList;
               DivElement          body;
               Element         get header  => element.querySelector('legend');
  static const int                 incrementSteps       = 20;
               model.Reception     nullReception        = model.Reception.noReception;
               model.Reception     reception            = model.Reception.noReception;
               List<model.Contact> filteredContactList  = new List<model.Contact>();

               List<Element>   get nudges         => this.element.querySelectorAll('.nudge');
               void set nudgesHidden(bool hidden) => this.nudges.forEach((Element element) => element.hidden = hidden);
               bool get muted     => this.context != Context.current;


  ContactSearch search;
  ContactData data;

  Contact(Element this.element, Context this.context) {

    DivElement contactSelectorSearch = querySelector('#${Id.contactSelectorSearch}');
    Element contactCalendar = querySelector('#${Id.contactCalendar}');
    DivElement contactData = querySelector('#${Id.contactData}');

    search = new ContactSearch(contactSelectorSearch, context, element);
    data = new ContactData(contactData);

    Element contactDataHeader = querySelector('#${Id.contactDataHeader} legend');

    this.header.children = [Icon.Contacts,
                            new SpanElement()..text = Label.ReceptionContacts,
                            new Nudge(ContactSearch.NavShortcut).element];

    contactDataHeader.children = [Icon.Info,
                            new SpanElement()..text = Label.ContactInformation,
                            new Nudge(ContactSearch.NavShortcut).element];


    ///Navigation shortcuts
    keyboardHandler.registerNavShortcut(ContactSearch.NavShortcut, this._select);

    body = querySelector('#${Id.contactSelectorBody}');

    _registerEventListeners();
  }

  void _select (_) {
    if (!this.muted) {
      Controller.Context.changeLocation(new nav.Location(search.context.id, element.id, search.searchBox.id));
    }
  }

  void _registerEventListeners() {
    event.bus.on(event.keyNav).listen((bool isPressed) => this.nudgesHidden = !isPressed);
    //TODO old but is it required in some way?
    element.onClick.listen((_) {
      if(!search.hasFocus) {
        setFocus(search.searchBox.id);
      }
    });
  }
}
