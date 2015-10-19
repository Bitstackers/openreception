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

part of openreception.model;

abstract class Label {
  static const String URGENT = 'Haster';
}

class TemplateEmail extends Template {
  final DateFormat      _dateFormat = new DateFormat("dd-MM-yyyy' kl. 'HH:mm:ss");
  Iterable<MessageRecipient> _recipients;
  final Message         _message;
  final User _sender;

  /**
   * Constructor.
   */
  TemplateEmail(Message this._message, Iterable<MessageRecipient>
    this._recipients, final User this._sender);

  /**
   *
   */
  String _renderEmailAddress(MessageRecipient recipient) =>
      '"${recipient.contactName}" <${recipient.address}>';

  Iterable<MessageRecipient> _filterRole (List<MessageRecipient> recipients, String role)
     => recipients.where((MessageRecipient recipient) => recipient.role == role);

  Iterable<String> get toRecipients => _filterRole(_recipients, Role.TO).map(_renderEmailAddress);

  Iterable<String> get ccRecipients => _filterRole(_recipients, Role.CC).map(_renderEmailAddress);

  Iterable<String> get bccRecipients => _filterRole(_recipients, Role.BCC).map(_renderEmailAddress);


  /**
   * TODO: Add caller number and company.
   */
  String renderSubject() =>
      '${this._message.flag.urgent ? '[${Label.URGENT.toUpperCase()}]' : ''} '
      'Besked fra ${this._message.callerInfo.name}, '
      '${this._message.callerInfo.company} ${this._message.callerInfo.phone}';


  String _renderBooleanFields() =>
      '${this._message.flag.urgent ? '(X) ${Label.URGENT}' : ''}';


  String _renderTime(DateTime time) => _dateFormat.format(time);

/**
 * This is the actual "template". It uses a lot of iternal formatting
 * functions, but should be relatively easy to customize.
 */
  String get renderedBody =>
'''Til ${_message.context.contactName}.

Der er besked fra ${_message.callerInfo.name}, ${this._message.callerInfo.company}.

Tlf. ${this._message.callerInfo.phone}
Mob. ${this._message.callerInfo.cellPhone}

${this._renderBooleanFields()}

Vedr.:
${_message.body}

Modtaget den ${this._renderTime(this._message.createdAt)}

Med venlig hilsen
${_sender.name}
Responsum K/S
''';

  Map toJson() => {Role.TO        :toRecipients,
                   Role.CC        : ccRecipients,
                   Role.BCC       : bccRecipients,
                   'message_body' : renderedBody,
                   'from'         : _sender.address,
                   'subject'      : renderSubject()};

  /**
   * Renders the email for Dart:mailer. TODO!
   */
  /*Envelope render() =>
      new Envelope()
        ..fromName = this._message.sender.name
        ..from     = this._message.sender.address
        ..subject  = this._renderSubject()
        ..text     = this._renderedBody;*/
}
