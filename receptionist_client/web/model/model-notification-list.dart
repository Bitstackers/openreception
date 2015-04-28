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
part of model;

class NotificationList extends IterableBase<Notification> {

  static const String className = '${libraryName}.NotificationList';

  List<Notification> _list = new List<Notification>();

  Iterator<Notification> get iterator => _list.iterator;

  Bus<Notification> _insert = new Bus<Notification>();
  Stream<Notification> get onInsert => this._insert.stream;

  Bus<Notification> _delete = new Bus<Notification>();
  Stream<Notification> get onDelete => this._delete.stream;

  /* Singleton instance - for quick and easy reference. */
  static NotificationList _instance    = new NotificationList();
  static NotificationList get instance => _instance;
  static                  set instance (NotificationList newList) => _instance = newList;

  /**
   *
   */
  NotificationList();

  /**
   *
   */
  void add(Notification notification) {
    this._list.add(notification);
    this._insert.fire(notification);

    /* Schedule the notification for removal. */
    new Timer(new Duration(seconds: 3), () {
      this.remove(notification);
    });
  }

  /**
   *
   */
  void remove(Notification notification) {
    if (this._list.remove(notification)) {
      this._delete.fire(notification);
    }
  }
}
