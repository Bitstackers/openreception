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

/**
 *
 */

class Notification {
  Model.NotificationList nl = Model.NotificationList.instance;

  static final String id = Id.notifications;
  static final String className = '${libraryName}.Notification';
  static final DivElement node  = querySelector('#$id');

  /**
   * TODO
   */
  Notification() {
    registerEventListeners();
  }

  void registerEventListeners() {
    Model.NotificationList.instance.onInsert.listen((Model.Notification notification) {
      node.append(new HeadingElement.h4()
      ..text = notification.message..id = 'notification_${notification.ID}'
      ..classes.toggle(notification.type)
      ..onClick.listen((_) {nl.remove(notification);}));
    });

    Model.NotificationList.instance.onDelete.listen((Model.Notification notification) {
      try {
        querySelector('#notification_${notification.ID}').remove();
      } catch (error){
        null; // Ignore the request if the notification has already been removed.
      }
    });
  }
}
