part of openreception.model;

abstract class Label {
  static const String URGENT = 'Haster';
}

class TemplateEmail extends Template {
  final DateFormat      _dateFormat = new DateFormat("dd-MM-yyyy' kl. 'HH:mm:ss");
  List<MessageEndpoint> _endpoints;
  final Message         _message;

  /**
   * Constructor.
   */
  TemplateEmail(Message this._message, List<MessageEndpoint> this._endpoints);

  /**
   *
   */
  String _renderEmailAddress(MessageEndpoint endpoint) =>
      '"${endpoint.recipient.contactName}" <${endpoint.address}>';

  Iterable<MessageEndpoint> _filterRole (List<MessageEndpoint> endpoints, String role)
     => endpoints.where((MessageEndpoint endpoint) => endpoint.recipient.role == role);

  Iterable<String> get toRecipients => _filterRole(_endpoints, Role.TO).map(_renderEmailAddress);

  Iterable<String> get ccRecipients => _filterRole(_endpoints, Role.CC).map(_renderEmailAddress);

  Iterable<String> get bccRecipients => _filterRole(_endpoints, Role.BCC).map(_renderEmailAddress);


  /**
   * TODO: Add caller number and company.
   */
  String _renderSubject() =>
      '${this._message.urgent ? '[${Label.URGENT.toUpperCase()}]' : ''} Besked fra ${this._message.caller.name}, ${this._message.caller.company} ${this._message.caller.phone}';


  String _renderBooleanFields() =>
      '${this._message.urgent ? '(X) ${Label.URGENT}' : ''}';


  String _renderTime(DateTime time) => _dateFormat.format(time);

/**
 * This is the actual "template". It uses a lot of iternal formatting
 * functions, but should be relatively easy to customize.
 */
  String get _renderedBody =>
'''Til ${_message.context.contactName}.

Der er besked fra ${_message.caller.name}, ${this._message.caller.company}.

Tlf. ${this._message.caller.phone}
Mob. ${this._message.caller.cellphone}

${this._renderBooleanFields()}

Vedr.:
${this._message.body}

Modtaget den ${this._renderTime(this._message.createdAt)}

Med venlig hilsen
${this._message.sender.name}
Responsum K/S
''';

  Map toJson() => {Role.TO        : this.toRecipients,
                   Role.CC        : this.ccRecipients,
                   Role.BCC       : this.bccRecipients,
                   'message_body' : this._renderedBody,
                   'from'         : this._message.sender.address,
                   'subject'      : this._renderSubject()};

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
