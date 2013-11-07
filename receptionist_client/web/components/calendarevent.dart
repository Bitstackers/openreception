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

class CalendarEvent {
//  model.CalendarEvent event;
  String notactive = '';
//  UListElement ul;

  CalendarEvent() { //UListElement this.ul
    String html = '''
      <h1 class="box-with-header-headline">
        <content select="[name=boxheader]"></content>
      </h1>
      <div class="box-with-header-content">
        <content select="[name=boxcontent]"></content>
      </div>
    ''';


  }

  void enteredView() {
//    notactive = event.active ? '' : 'calendar-event-notactive';
  }
}
