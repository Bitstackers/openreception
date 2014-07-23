part of view;

abstract class MessageOverviewLabels {
  static const String PENDING = 'Afventer';
  static const String SENT = 'Sendt';
  static const String TAKEN_AT = 'Modtaget';
  static const String CALLER = 'Opkalder';
  static const String CONTEXT = 'Kontekst';
  static const String AGENT = 'Agent';
  static const String STATUS = 'Status';
  static const String PreviousPage = 'Forrige side';
  static const String NextPage = 'Næste side';
  static const String MessageArchive = 'Beskedarkiv';
  static const String ResendSelected = 'Gensend valgte';
  static const String Print = 'Udskriv';

  static Element get ArchiveIcon => new DocumentFragment.html ('''<i class=\"fa fa-archive"></i>''').children.first;
  static Element get PreviousIcon => new DocumentFragment.html ('''<i class=\"fa fa-chevron-left"></i>''').children.first;
  static Element get NextIcon => new DocumentFragment.html ('''<i class=\"fa fa-chevron-right"></i>''').children.first;
  static Element get PrintIcon => new DocumentFragment.html ('''<i class=\"fa fa-print"></i>''').children.first;
  static Element get SendIcon => new DocumentFragment.html ('''<i class=\"fa fa-send"></i>''').children.first;
}

/**
 * View of all messages.
 * 
 * Subscribes to newMessage events.
 */

class MessageList {
  static const String className           = '${libraryName}.MessageList';
  static const String NavShortcut         = 'A'; 
  static const String CommandPreviousPage = 'Q'; 
  static const String CommandNextPage     = 'W';
  static const String SelectedClass       = 'selected';
  static const int    viewLimit           = 16;
  
  static final messageDateFormat = new DateFormat('EEE, MMM d, HH:mm');
  
  List<Element> get nudges => this.element.querySelectorAll('.nudge');
  void set nudgesHidden(bool hidden) => this.nudges.forEach((Element element) => element.hidden = hidden);

  final Context context;
  final Element element;
  nav.Location location;
       Element lastActive = null;
       bool get muted     => this.context != Context.current;  
       bool get inFocus   => nav.Location.isActive(this.element);

  TableElement        get table     => this.element.querySelector('table');
  TableSectionElement get tableBody => this.table.querySelector('tbody');
  TableRowElement _selectedRow = null;
  
  Element get header => this.element.querySelector('legend'); 
  
  /// Button selector shortcuts.
  ButtonElement get nextPageButton               => this.element.querySelector('button.next');
  ButtonElement get previousPageButton           => this.element.querySelector('button.previous');
  ButtonElement get resendMultipleMessagesButton => this.element.querySelector('button.resend-multiple');
  ButtonElement get printMessageButton           => this.element.querySelector('button.print');

  /// Extracts the last (visualized) message ID from the DOM model.
  int get lastID => int.parse((this.tableBody.children.first as TableRowElement).dataset['messageID']);

  /// Extracts the first (visualized) message ID from the DOM model.
  int get firstID => int.parse((this.tableBody.children.last as TableRowElement).dataset['messageID']);
  
  static final EventType selectedMessageChanged = new EventType(); 

  TableRowElement  get selectedRow 
    => this.tableBody.children.firstWhere((TableRowElement child) 
      => child.classes.contains(SelectedClass), 
         orElse : () => new TableRowElement()..hidden = true);

  set selectedRow (TableRowElement newRow) {
    assert (newRow != null);

    this.selectedRow.classes.toggle(SelectedClass, false);
    if (this._selectedRow != null) {
      this._selectedRow.classes.toggle('active', false);
      newRow.focus();
    }

    newRow.classes.toggle('active', true);
    this._selectedRow = newRow;
    if (this.inFocus) {
      newRow.focus();
    }
    
    Service.Message.get (int.parse(newRow.dataset['messageID'])).then((model.Message message) {
      event.bus.fire(event.selectedEditMessageChanged, message);
    });
  }

  /**
   * Selects the widget and puts the default element in focus.
   */
  void _select(_) {
    if (!this.muted) {
      Controller.Context.changeLocation(this.location);
    }
  }

  MessageList(Element this.element, Context this.context) {
    this.location = new nav.Location(context.id, element.id, this.tableBody.id);
    
    this._setHeaderLabels();

    ///Navigation shortcuts
    keyboardHandler.registerNavShortcut(NavShortcut, this._select);
    this.header.append(new Nudge(NavShortcut).element);

    /// Event listeners
    this.table.querySelector('input').onClick.listen(headerCheckboxChange);

    event.bus.on(event.keyNav).listen((bool isPressed) => this.nudgesHidden = !isPressed);
    
    element.onClick.listen((Event event) {
      if (!this.inFocus)
        Controller.Context.changeLocation(this.location);
        
        if (event.target is TableRowElement) {
          this.selectedRow = event.target; 
        }
    });
    event.bus.on(event.locationChanged).listen((nav.Location location) {
      element.classes.toggle(FOCUS, location.targets(this.element));

      if (location.targets(this.element)) {
        this.selectedRow.focus();
      }
    });
  
    void listNavigation(KeyboardEvent e) {

      if (e.keyCode == Keys.PGUP){
        if (this._selectedRow != null && !muted) {
          CheckboxInputElement checkbox = this._selectedRow.querySelector('input'); 
          checkbox.checked = !checkbox.checked;
          e.preventDefault();
        }
      }
      
      if (e.keyCode == Keys.SPACE){
        if (this._selectedRow != null && !muted) {
          CheckboxInputElement checkbox = this._selectedRow.querySelector('input'); 
          checkbox.checked = !checkbox.checked;
          e.preventDefault();
        }
      }

        else if (e.keyCode == Keys.DOWN){
          if (this._selectedRow != null && this._selectedRow.nextNode is TableRowElement && !muted) {
            this.selectedRow =  this._selectedRow.nextNode;
            e.preventDefault();
          } 
          // Scroll through pages.
          //else if (this._selectedRow.nextNode == null) {
          //  this.previousPageButton.click();
          //}
          e.preventDefault();
        } else if (e.keyCode == Keys.UP){
          if (this._selectedRow != null && this._selectedRow.previousNode is TableRowElement && !muted) {
            this.selectedRow =  this._selectedRow.previousNode;
            e.preventDefault();
          }
        }
    }
    
    nextPageButton.onClick.listen((_) {
      this.loadData(this.lastID + viewLimit + 1);
    });
    
    previousPageButton.onClick.listen((_) {
      this.loadData(this.firstID-1);
    });

    window.onKeyDown.listen(listNavigation);

    event.bus.on(event.Previous).listen((_) {
      this.previousPageButton.click();
    });

    event.bus.on(event.Next).listen((_) {
        this.nextPageButton.click();
    });

    this.loadData(model.Message.noID);
  }

  void loadData(int fromID) {
    if (fromID != model.Message.noID  && fromID < model.Message.noID) {
      return;
    }
    
    
    //this.tableBody.children = [new ProgressElement()];
    this.nextPageButton.disabled = true;
    this.previousPageButton.disabled = true;
    
    Storage.Message.list(lastID: fromID, limit: viewLimit).then((model.MessageList messageList) {
      tableBody.children.clear();
      messageList.forEach ((model.Message message) {
        tableBody.children.add(createRow(message));
      });
    }).then((_) {
      this.selectedRow = this.tableBody.hasChildNodes() ? this.tableBody.children.first : null;
    }).whenComplete(() {
      this.nextPageButton.disabled = false;
      this.previousPageButton.disabled = false;
    });
  }

  void _setHeaderLabels() {
    this.element.querySelector('#message-overview-header-timestamp').text = MessageOverviewLabels.TAKEN_AT;
    this.element.querySelector('#message-overview-header-caller').text = MessageOverviewLabels.CALLER;
    this.element.querySelector('#message-overview-header-context').text = MessageOverviewLabels.CONTEXT;
    this.element.querySelector('#message-overview-header-agent').text = MessageOverviewLabels.AGENT;
    this.element.querySelector('#message-overview-header-status').text = MessageOverviewLabels.STATUS;

   this.previousPageButton
     ..children = [MessageOverviewLabels.PreviousIcon, 
                   new SpanElement()..text = MessageOverviewLabels.PreviousPage];
    
   this.nextPageButton
     ..children = [new SpanElement()..text = MessageOverviewLabels.NextPage,
                   MessageOverviewLabels.NextIcon];
    
   this.printMessageButton
     ..children = [MessageOverviewLabels.PrintIcon,
                   new SpanElement()..text = MessageOverviewLabels.Print];

   this.resendMultipleMessagesButton
     ..children = [MessageOverviewLabels.SendIcon,
                   new SpanElement()..text = MessageOverviewLabels.ResendSelected];

   this.header
     ..children = [MessageOverviewLabels.ArchiveIcon,
                   new SpanElement()..text = MessageOverviewLabels.MessageArchive];
  }

  TableRowElement createRow(model.Message message) {

    return new TableRowElement()
            ..tabIndex = -1
            ..dataset = {'messageID' : message.ID.toString()}
            ..children.addAll([new TableCellElement()
              ..children.add(new CheckboxInputElement()..tabIndex = -1)
              ..onClick.listen(messageCheckboxClick), 
           new TableCellElement()
              ..text = messageDateFormat.format(message.createdAt), 
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
