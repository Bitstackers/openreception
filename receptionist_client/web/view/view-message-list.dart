part of view;

abstract class MessageOverviewLabels {
  static const String PENDING = 'Afventer';
  static const String SENT = 'Sendt';
  static const String TAKEN_AT = 'Modtaget';
  static const String CALLER = 'Opkalder';
  static const String CONTEXT = 'Kontekst';
  static const String AGENT = 'Agent';
  static const String STATUS = 'Status';
}

/**
 * View of all messages.
 * 
 * Subscribes to newMessage events.
 */

class MessageList {
  Context context;
  DivElement element;
  TableElement table;
  TableSectionElement tableBody;
  TableRowElement _selectedRow = null;
  bool muted = true;
  ResendMessage messageView = new ResendMessage(querySelector("#resendmessage"));
  
  static final EventType selectedMessageChanged = new EventType(); 

  set selectedRow (TableRowElement newRow) {
    if (this._selectedRow != null) {
      this._selectedRow.classes.toggle('active', false);
    }

    newRow.classes.toggle('active', true);
    this._selectedRow = newRow;
    Service.Message.get (int.parse(newRow.dataset['messageID'])).then((model.Message message) {
      messageView.render(message);
    });
  }
    

  MessageList(DivElement this.element, Context this.context) {

    this.table     = this.element.querySelector('table');
    this.tableBody = table.querySelector('tbody');
    
    
    /// Event listeners
    this.table.querySelector('input').onClick.listen(headerCheckboxChange);
    
    // TODO: Pause listener when not in this context.
    event.bus.on(event.keyDown).listen((_) {
      if (this._selectedRow != null && this._selectedRow.nextNode is TableRowElement && !muted) {
        this.selectedRow =  this._selectedRow.nextNode;
      }
    }); 
    
    // TODO: Pause listener when not in this context.
    event.bus.on(event.keyUp).listen((_) {
      if (this._selectedRow != null && this._selectedRow.previousNode is TableRowElement && !muted) {
        this.selectedRow =  this._selectedRow.previousNode;
      }
    }); 

    event.bus.on(event.contextChanged).listen((Context newContext) {
        this.muted = (newContext != this.context);
    }); 

    this._setHeaderLabels();
    this.initialFill();
  }

  void initialFill() {
    Service.Message.list().then((model.MessageList messageList) {
      messageList.forEach ((model.Message message) {
        tableBody.children.add(createRow(message));
      });
    }).then((_) {this.selectedRow = this.tableBody.hasChildNodes() ? this.tableBody.children.first : null;});
  }

  void _setHeaderLabels() {
    this.element.querySelector('#message-overview-header-timestamp')..text = MessageOverviewLabels.TAKEN_AT;
    this.element.querySelector('#message-overview-header-caller')..text = MessageOverviewLabels.CALLER;
    this.element.querySelector('#message-overview-header-context')..text = MessageOverviewLabels.CONTEXT;
    this.element.querySelector('#message-overview-header-agent')..text = MessageOverviewLabels.AGENT;
    this.element.querySelector('#message-overview-header-status')..text = MessageOverviewLabels.STATUS;
  }

  TableRowElement createRow(model.Message message) {

    return new TableRowElement()
            ..dataset = {'messageID' : message.ID.toString()}
            ..children.addAll([new TableCellElement()
              ..children.add(new CheckboxInputElement()..tabIndex = -1)
              ..onClick.listen(messageCheckboxClick), 
           new TableCellElement()
              ..text = message.createdAt.toString(), 
           new TableCellElement()
              ..text = '${message.caller.name} (${message.caller.company})', 
           new TableCellElement()
              ..text = message.context.contact.name,
           new TableCellElement()
              ..text = message.takenByAgent['name'],
           new TableCellElement()
              ..text = (message.queueCount > 0 ? MessageOverviewLabels.PENDING : MessageOverviewLabels.SENT)]);
  }

  void headerCheckboxChange(event) {
    CheckboxInputElement target = event.target;
    bool checked = target.checked;

    for (TableRowElement item in tableBody.children.where((TableRowElement element) => !element.hidden)) {
      InputElement e = item.children.first.children.first;
      e.checked = checked;
    }
  }

  void messageCheckboxClick(_) {
    (this.table.querySelector('input') as CheckboxInputElement).checked = false;
  }
}


class MessageHeaderRow {
  
}

class ResendMessage {

  final DivElement element;
  
  ResendMessage (this.element);
  
  void render (model.Message message) {
    (this.element.querySelector("#resendmessagetext") as TextAreaElement).value = message.toMap['message'];
    
  }
}