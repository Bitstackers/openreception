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

part of components;

class ContactInfo {
               DivElement          body;
               Box                 box;
               model.Contact       contact              = model.nullContact;
               String              contextId;
               UListElement        displayedContactList;
               DivElement          element;
               SpanElement         header;
  static const int                 incrementSteps       = 20;
               InputElement        searchBox;
               model.Organization  nullOrganization     = model.nullOrganization;
               model.Organization  organization         = model.nullOrganization;
               List<model.Contact> filteredContactList  = new List<model.Contact>();
               String              placeholder          = 'søg...';
               String              title                = 'Medarbejdere';

  ContactInfoSearch search;
  ContactInfoCalendar calendar;
  ContactInfoData data;

  ContactInfo(DivElement this.element, String this.contextId) {
    header = new SpanElement()
    ..text = title;

    HeadingElement contactInfoHeader = querySelector('#contactinfohead')
        ..children.add(header);

    DivElement contactinfo_search = querySelector('#contactinfo_search');
    DivElement contactinfo_calendar = querySelector('#contactinfo_calendar');
    DivElement contactinfo_data = querySelector('#contactinfo_data');

    search = new ContactInfoSearch(contactinfo_search, contextId);
    calendar = new ContactInfoCalendar(contactinfo_calendar, contextId);
    data = new ContactInfoData(contactinfo_data);

    body = querySelector('#contactinfobody');
    box = new Box.withHeaderStatic(element, contactInfoHeader, body);

    _registerEventListeners();
  }

  void _registerEventListeners() {
    element.onClick.listen((_) {
      if(!search.hasFocus && !calendar.hasFocus) {
        setFocus(search.searchBox.id);
      }
    });
  }
}
