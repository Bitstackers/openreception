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

part of controller;

/**
 * Activate browser popup notifications.
 */
class Popup {
  final Uri      _errorIcon;
  final Uri      _infoIcon;
  final Uri      _successIcon;
  final Duration _timeout = new Duration(seconds: 3);

  /**
   * Constructor.
   */
  Popup(this._errorIcon, this._infoIcon, this._successIcon);

  void error(String title, String body, {Duration closeAfter}) {
    _schedulePopupForClose(new Html.Notification(title, body: body, icon: _errorIcon.path), closeAfter);
  }

  void info(String title, String body, {Duration closeAfter}) {
    _schedulePopupForClose(new Html.Notification(title, body: body, icon: _infoIcon.path), closeAfter);
  }

  void _schedulePopupForClose(Html.Notification notification, Duration timeout) {
    Duration closeAfter = _timeout;

    if(timeout != null) {
      closeAfter = timeout;
    }

    new Timer(closeAfter, () {
      notification.close();
    });
  }

  void success(String title, String body, {Duration closeAfter}) {
    _schedulePopupForClose(new Html.Notification(title, body: body, icon: _successIcon.path), closeAfter);
  }
}
