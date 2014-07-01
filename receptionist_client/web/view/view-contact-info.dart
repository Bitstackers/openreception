/*                     This file is part of Bob
                   Copyright (C) 2012-, AdaHeads K/S

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
               model.Contact       contact              = model.nullContact;
               Context             context;
               UListElement        displayedContactList;
               DivElement          body;
               Element         get header  => element.querySelector('legend');
  static const int                 incrementSteps       = 20;
               InputElement        searchBox;
               model.Reception     nullReception        = model.nullReception;
               model.Reception     reception            = model.nullReception;
               List<model.Contact> filteredContactList  = new List<model.Contact>();
               String              placeholder          = 'søg...';
               String              title                = 'Medarbejdere';

               List<Element>   get nudges         => this.element.querySelectorAll('.nudge');
               void set nudgesHidden(bool hidden) => this.nudges.forEach((Element element) => element.hidden = hidden);


  ContactInfoSearch search;
  ContactInfoCalendar calendar;
  ContactInfoData data;

  ContactInfo(Element this.element, Context this.context) {

    this.header..text = title;

    DivElement contactinfo_search = querySelector('#contactinfo_search');
    Element contactinfo_calendar = querySelector('#contactinfo_calendar');
    DivElement contactinfo_data = querySelector('#contactinfo_data');

    search = new ContactInfoSearch(contactinfo_search, context, element);
    calendar = new ContactInfoCalendar(contactinfo_calendar, context, element);
    data = new ContactInfoData(contactinfo_data);


    ///Navigation shortcuts
    this.element.insertBefore(new Nudge(ContactInfoSearch.NavShortcut).element,  this.header);
    keyboardHandler.registerNavShortcut(ContactInfoSearch.NavShortcut, (_) => Controller.Context.changeLocation(new nav.Location(search.context.id, element.id, search.searchBox.id)));

    body = querySelector('#contactinfobody');

    _registerEventListeners();
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
