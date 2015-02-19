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

class ContactInfo {
         final Element             element;
               Box                 box;
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


  ContactInfoSearch search;
  ContactCalendar calendar;
  ContactInfoData data;

  ContactInfo(Element this.element, Context this.context) {

    DivElement contactinfo_search = querySelector('#contactinfo_search');
    Element contactinfo_calendar = querySelector('#contactinfo_calendar');
    DivElement contactinfo_data = querySelector('#contactinfo_data');

    search = new ContactInfoSearch(contactinfo_search, context, element);
    calendar = new ContactCalendar(contactinfo_calendar, context, element);
    data = new ContactInfoData(contactinfo_data);

    Element contactinfopanelHeader = querySelector('#contactinfopanel legend');

    this.header.children = [Icon.Contacts,
                            new SpanElement()..text = Label.ReceptionContacts,
                            new Nudge(ContactInfoSearch.NavShortcut).element];

    contactinfopanelHeader.children = [Icon.Info,
                            new SpanElement()..text = Label.ContactInformation,
                            new Nudge(ContactInfoSearch.NavShortcut).element];


    ///Navigation shortcuts
    keyboardHandler.registerNavShortcut(ContactInfoSearch.NavShortcut, this._select);

    body = querySelector('#contactinfobody');

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
      if(!search.hasFocus && !calendar.hasFocus) {
        setFocus(search.searchBox.id);
      }
    });
  }
}
