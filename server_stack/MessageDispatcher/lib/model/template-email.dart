part of model;

abstract class Label {
  static const String URGENT = 'Haster';


}

class Email implements Template {

  /* The actual dateformat use for the concrete email. */
  DateFormat dateFormat = new DateFormat("dd-MM-yyyy' kl. 'HH:mm:ss"); // 11-04-2014 kl. 13:37:22

  /* Private  */
  Message _message;

  Email(Message this._message);

  List<String> _renderToRecipients() {
    List<String> recipients = new List<String>();
    this._message.recipients.forEach((Messaging_Contact recipient) {
      if (recipient.transport == 'email' && recipient.role == Role.TO) {
        recipients.add(this._renderEmailAddress(recipient));
      }
    });
    return recipients;
  }

  List<String> _renderCCRecipients() {
    List<String> recipients = new List<String>();
    this._message.recipients.forEach((Messaging_Contact recipient) {
      if (recipient.transport == 'email' && recipient.role== Role.CC) {
        recipients.add(this._renderEmailAddress(recipient));
      }
    });
    return recipients;
  }

  List<String> _renderBCCRecipients() {
    List<String> recipients = new List<String>();
    this._message.recipients.forEach((Messaging_Contact recipient) {
      if (recipient.transport == 'email' && recipient.role == Role.BCC) {
        recipients.add(this._renderEmailAddress(recipient));
      }
    });
    return recipients;
  }

  /**
   * TODO: Add callee number and company.
   */
  String _renderSubject() {
    return '${this._message.urgent ? '[${Label.URGENT.toUpperCase()}]' : ''} Besked fra ${this._message.calleeName}, ${this._message.calleeCompany} ${this._message.calleePhone}';
  }

  String _renderBooleanFields() {
    return '${this._message.urgent ? '(X) ${Label.URGENT}' : ''}';
  }

  String _renderTime(DateTime time) {
    return dateFormat.format(time);
  }

  String _renderBody() {
    return '''
Til ${_message.contextContactName}.

Der er besked fra ${_message.calleeName}, ${this._message.calleeCompany}.

Tlf. ${this._message.calleePhone}
Mob. ${this._message.calleeCellPhone}

${this._renderBooleanFields()}

Vedr.:
${this._message.body}

Modtaget den ${this._renderTime(this._message.receivedAt)}

Med venlig hilsen
${this._message.agentName}
Responsum K/S

''';
  }

  String _renderEmailAddress(Messaging_Contact recipient) {
    return '"${recipient.contactName}" <${recipient.address}>';
  }

  Map toMap() {
    return {
      Role.TO: this._renderToRecipients(),
      Role.CC: this._renderCCRecipients(),
      Role.BCC: this._renderBCCRecipients(),
      'message_body': this._renderBody(),
      'from' : this._message.agentAddress,
      'subject' : this._renderSubject()
    };
  }


  /**
   * Renders the email.
   */
  Envelope render() {
    Envelope envelope = new Envelope()
        ..fromName = this._message.agentName
        ..from = this._message.agentAddress
        ..subject = this._renderSubject()
        ..text = this._renderBody();
    this._message.recipients.forEach((Messaging_Contact recipient) {
      if (recipient.transport == 'e-mail') {

        envelope.recipients.add(recipient.address);
      }
    });

    return envelope;


  }
}


abstract class Email_Test {

  static void Run() {
    print("running tests");

    messageQueueList().then((List items) {
      Message.loadFromDatabase(items.first['message_id']).then((Message message) {
        Email template = new Email(message);

        print(JSON.encode({
          Role.TO: template._renderToRecipients(),
          Role.CC: template._renderCCRecipients(),
          Role.BCC: template._renderBCCRecipients(),
          'message_body': template._renderBody()
        }));

        /*        new Email (message).render().getContents().then((value) {
          print (value);
          
        });*/

      });

    });
  }
}
