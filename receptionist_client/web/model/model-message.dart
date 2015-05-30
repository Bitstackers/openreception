/*                  This file is part of OpenReception
                   Copyright (C) 2014-, BitStackers K/S

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

abstract class Role {
  static final String TO             = "to";
  static final String CC             = "cc";
  static final String BCC            = "bcc";
  static final String RECIPIENTS     = "recipients";
  static final String TAKEN_BY_AGENT = "taken_by_agent";

  static final List<String> RECIPIENT_ROLES = [TO,CC,BCC];

}

abstract class MessageFlag {
  static final String PleaseCall   = 'pleaseCall';
  static final String willCallBack = 'willCallBack';
  static final String Called       = 'called';
  static final String Urgent       = 'urgent';
  static final String Draft        = 'draft';
}

class Message extends ORModel.Message {

  static final String className = libraryName + ".Message";

  static const int noID = 0;

  static Set<int> selectedMessages = new Set<int>();

  void clearRecipients() => this.recipients.recipients.clear();

  Message.fromMap(Map map) : super.fromMap(map);

//  Future<Message> saveTMP() => Service.Message.store.save(this)
//      .then((ORModel.Message message) => new Message.fromMap(message.asMap));
//
//  Future sendTMP() => Service.Message.store.enqueue(this);
}
