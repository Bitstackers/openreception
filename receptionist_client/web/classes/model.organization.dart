/*                                Bob
                   Copyright (C) 2012-, AdaHeads K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This library is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License and
  a copy of the GCC Runtime Library Exception along with this program;
  see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see
  <http://www.gnu.org/licenses/>.
*/
part of model;

final Organization nullOrganization = new Organization._null();

class Event{
  DateTime _start;
  DateTime _stop;
  String content;

  String get start => _formatTimestamp(_start);
  String get stop => _formatTimestamp(_stop);

  Event(DateTime this._start, DateTime this._stop, String this.content);

  /**
   * Format the [DateTime] [stamp] timestamp into a string. If [stamp] is today
   * then return hour:minute, else return hour:minute day/month.
   */
  String _formatTimestamp(DateTime stamp) {
    StringBuffer output = new StringBuffer();
    DateTime now = new DateTime.now();
    String hourMinute = new DateFormat.Hm().format(stamp);

    output.write(new DateFormat.Hm().format(stamp).toString());

    if (new DateFormat.Md().format(stamp) != new DateFormat.Md().format(now)) {
      String day = new DateFormat.d().format(stamp);
      String month = new DateFormat.M().format(stamp);
      String dayMonth = '${day}/${month}';

      output.write(' ${dayMonth}');
    }

    return output.toString();
  }
}

/**
 * TODO comment
 */
class Organization{
  ContactList _contactlist = nullContactList;
  ContactList get contacts => _contactlist;

  List<Event> events = new List<Event>();
  String greeting = "";
  int id = -1;
  String name = "";

  Organization(Map json) {
    if(json.containsKey('contacts')) {
      _contactlist = new ContactList(json['contacts']);
      json.remove('contacts');
    }

    id = json['organization_id'];
    name = json['full_name'];
    greeting = json['greeting'];

    events.add(new Event(new DateTime.now().add(new Duration(hours: 2)), new DateTime.now().add(new Duration(hours: 4)), 'Salgsmøde'));
    events.add(new Event(new DateTime.now(), new DateTime.now().add(new Duration(hours: 1, days: 1)), 'Kursus'));
    events.add(new Event(new DateTime.now().add(new Duration(hours: 1)), new DateTime.now().add(new Duration(hours: 3)), 'Ombygning'));
  }

  Organization._null();

  String toString() => '${name}-${id}';
}
