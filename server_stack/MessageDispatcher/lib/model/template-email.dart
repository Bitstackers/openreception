part of model;

abstract class Label {
  static const String URGENT = 'Haster';


}

class Email implements Template {

  /* The actual dateformat use for the concrete email. */
  DateFormat dateFormat = new DateFormat("dd-MM-yyyy' kl. 'HH:mm:ss"); // 11-04-2014 kl. 13:37:22

  Message               _message;
  List<MessageEndpoint> _recipients;

  static Future<Email> dereferenceRecipients(Message message)  {
    Email email = new Email._internal(message);
    return Database.MessageQueue.endpoints(message.ID).then((List<MessageEndpoint> endpoints) {
      return email
          .._recipients = endpoints.where((MessageEndpoint endpoint) => endpoint.type == 'email').toList();
      });
  }

  Email._internal (this._message);

  static String _renderEmail (MessageEndpoint endpoint) => '"${endpoint.name}" <${endpoint.address}>';
  static Iterable<MessageEndpoint> _filterRole (List<MessageEndpoint> endpoints, String role) 
     => endpoints.where((MessageEndpoint endpoint) => endpoint.role == role);
  
  List<String> get toRecipients => _filterRole(this._recipients, Role.TO).map(_renderEmail).toList();

  List<String> get ccRecipients => _filterRole(this._recipients, Role.CC).map(_renderEmail).toList();

  List<String> get bccRecipients => _filterRole(this._recipients, Role.BCC).map(_renderEmail).toList();


  /**
   * TODO: Add caller number and company.
   */
  String _renderSubject() => 
      '${this._message.urgent ? '[${Label.URGENT.toUpperCase()}]' : ''} Besked fra ${this._message.caller['name']}, ${this._message.caller['company']} ${this._message.caller['phone']}';
  

  String _renderBooleanFields() =>
      '${this._message.urgent ? '(X) ${Label.URGENT}' : ''}';
  

  String _renderTime(DateTime time) => 
      dateFormat.format(time);
  

  String get _renderedBody => 
'''Til ${_message.context.contactName}.

Der er besked fra ${_message.caller['name']}, ${this._message.caller['company']}.

Tlf. ${this._message.caller['phone']}
Mob. ${this._message.caller['cellphone']}

${this._renderBooleanFields()}

Vedr.:
${this._message.body}

Modtaget den ${this._renderTime(this._message.receivedAt)}

Med venlig hilsen
${this._message.sender.name}
Responsum K/S
''';

  Map toJson() {
    return {
      Role.TO        : this.toRecipients,
      Role.CC        : this.ccRecipients,
      
      Role.BCC       : this.bccRecipients,
      'message_body' : this._renderedBody,
      'from'         : this._message.sender.address,
      'subject'      : this._renderSubject()
    };
  }


  /**
   * Renders the email.
   */
  Envelope render() => 
      new Envelope()
        ..fromName = this._message.sender.name
        ..from     = this._message.sender.address
        ..subject  = this._renderSubject()
        ..text     = this._renderedBody;
}
