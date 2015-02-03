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

part of view;

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
  static const int    viewLimit           = 30;

  static final TableRowElement noRow      = (new TableRowElement()..hidden = true);

  static final messageDateFormat = new DateFormat('EEE, MMM d, HH:mm');

  List<Element> get nudges => this.element.querySelectorAll('.nudge');
  void set nudgesHidden(bool hidden) => this.nudges.forEach((Element element) => element.hidden = hidden);

  final Context context;
  final Element element;
  nav.Location location;
       Element lastActive = null;
       bool get muted     => this.context != Context.current;
       bool get inFocus   => nav.Location.isActive(this.element);

       bool get _busy => !this.loadingProgress.hidden;
            set _busy (bool busy) => this.loadingProgress.hidden = !busy;

  TableElement        get table     => this.element.querySelector('table');
  TableSectionElement get tableBody => this.table.querySelector('tbody');
  TableRowElement _selectedRow = null;

  Element get header => this.element.querySelector('legend');

  /// Button selector shortcuts.
  ButtonElement get resendMultipleMessagesButton => this.element.querySelector('button.resend-multiple');
  ButtonElement get printMessageButton           => this.element.querySelector('button.print');
  Element       get loadingProgress              => this.element.querySelector('progress.loading');

  /// Extracts the last (visualized) message ID from the DOM model.
  int get lastID => int.parse(this.firstRow != null ? this.firstRow.dataset['messageID'] : '0');

  /// Extracts the first (visualized) message ID from the DOM model.
  int get lowerID => int.parse(this.lastRow != null ? lastRow.dataset['messageID'] : '0');

  TableRowElement get firstRow => this.tableBody.children.first;
  TableRowElement get lastRow  => this.tableBody.children.last;

  static final EventType selectedMessageChanged = new EventType();

  /**
   * Extracts the currently selected row.
   * Returns a non-visible dummy row if no row i selected to avoid null
   * exceptions.
   */
  TableRowElement get selectedRow
    => this.tableBody.children.firstWhere((TableRowElement child)
      => child.classes.contains(SelectedClass),
         orElse : () => noRow);

  TableRowElement rowOf(int messageID)
    => this.tableBody.children.firstWhere((TableRowElement child)
      => child.dataset['messageID'] == messageID,
         orElse : () => noRow);

  set selectedRow (TableRowElement newRow) {
    bool isHeader(TableRowElement row) =>
        !row.dataset.containsKey('messageID');

    if (newRow == null || !(newRow is TableRowElement || isHeader(newRow))) {
      return;
    }

    if (this._selectedRow != null) {
      this._selectedRow.classes.toggle(SelectedClass, false);
      newRow.focus();
    }

    newRow.classes.toggle(SelectedClass, true);
    this._selectedRow = newRow;
    if (this.inFocus) {
      newRow.focus();
    }

    model.Message.selectedMessages = [int.parse(newRow.dataset['messageID'])].toSet();
    event.bus.fire(event.selectedMessagesChanged, null);
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

    model.MessageList.instance.events.on(model.MessageList.stateChange).listen((model.Message message) {
      TableRowElement messageRow = this.rowOf(message.ID);
      if(messageRow != noRow) {
          messageRow = this.createRow(message);
      }
    });

    event.bus.on(event.messageFilterChanged).listen((model.MessageFilter filter) {
      this.loadData(model.Message.noID);
    });

    /**
     * Clicks inside the widget area marks up the widget at directly selects
     * any table entry it targets.
     */
    element.onClick.listen((Event event) {
      if (!this.inFocus)
        Controller.Context.changeLocation(this.location);
        if (event.target is TableRowElement) {
          this.selectedRow = event.target;
        } else if (event.target is TableCellElement) {
          this.selectedRow = (event.target as TableCellElement).parent;
        }
    });

    event.bus.on(event.locationChanged).listen((nav.Location location) {
      element.classes.toggle(FOCUS, location.targets(this.element));

      if (location.targets(this.element)) {
        this.selectedRow.focus();
      }

    });

    model.MessageList.instance.events.on(model.MessageList.add).listen((int messageID) {
      const String context = '${className}.add (listener)';

      /// Hacky way of fetching message and determining if is affected by the current filter.
      Storage.Message.list (filter: model.MessageFilter.current, lastID: messageID, limit: 1)
        .then ((List<model.Message> messages) {

        TableRowElement existingRow = this.tableBody.children.firstWhere((TableRowElement row) => row.dataset['messageID'] == messageID.toString(), orElse: () => null);

        if (existingRow != null) {
          existingRow = this.createRow(messages.first);
        }
        else if (messages.length > 0) {
            this.tableBody.insertBefore(this.createRow(messages.first), this.firstRow);
              this.selectedRow == this.firstRow;
            this.lastRow.remove();
          }
        });

      log.debugContext('Got new message with ID ${messageID}', context);
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
          else if (this._selectedRow.nextNode == null) {
            if (!this._busy && this.lowerID-1 != model.Message.noID ) {
              this._busy = true;
              Storage.Message.list(lastID : this.lowerID-1, limit: viewLimit , filter : model.MessageFilter.current).then((List<model.Message> messages) {
                messages.forEach((model.Message message) => this.tableBody.append(createRow(message)));

              }).whenComplete(() => this._busy = false);
            }
          }
          e.preventDefault();
        } else if (e.keyCode == Keys.UP){
          if (this._selectedRow != null && this._selectedRow.previousNode is TableRowElement && !muted) {
            this.selectedRow =  this._selectedRow.previousNode;
            e.preventDefault();
          }
        }
    }

    this.tableBody.onKeyDown.listen(listNavigation);

    this.loadData(model.Message.noID);
  }

  void loadData(int fromID) {
    if (fromID != model.Message.noID  && fromID < model.Message.noID) {
      return;
    }

    Storage.Message.list(lastID: fromID, limit: viewLimit, filter : model.MessageFilter.current)
      .then((List<model.Message> messageList) {
      tableBody.children.clear();
      messageList.forEach ((model.Message message) {
        tableBody.children.add(createRow(message));
      });
    }).then((_) {
      this.selectedRow = this.tableBody.hasChildNodes() ? this.tableBody.children.first : null;
    }).whenComplete(() => this._busy = false);
  }

  void _setHeaderLabels() {
    this.element.querySelector('#message-overview-header-timestamp').text = Label.MessageTakenAt;
    this.element.querySelector('#message-overview-header-caller')   .text = Label.Caller;
    this.element.querySelector('#message-overview-header-context')  .text = Label.Context;
    this.element.querySelector('#message-overview-header-agent')    .text = Label.Agent;
    this.element.querySelector('#message-overview-header-status')   .text = Label.Status;

   this.printMessageButton
     ..children = [Icon.Print,
                   new SpanElement()..text = Label.Print];

   this.resendMultipleMessagesButton
     ..children = [Icon.Send,
                   new SpanElement()..text = Label.MessageResendSelected];

   this.header
     ..children = [Icon.Archive,
                   new SpanElement()..text = Label.MessageArchive];
  }

  TableRowElement createRow(model.Message message) {

    // Formatting helper function.
    String callerInfo () {
      if (message.caller.name.isNotEmpty && message.caller.company.isNotEmpty) {
        return '${message.caller.name}, ${message.caller.company}';

      } else if (message.caller.company.isNotEmpty) {
        return message.caller.company;

      } else if (message.caller.name.isNotEmpty) {
        return message.caller.name;
      }

      return Label.No_Information;
    }

    return new TableRowElement()
            ..tabIndex = -1
            ..dataset = {'messageID' : message.ID.toString()}
            ..children.addAll([new TableCellElement()
              ..children.add(new CheckboxInputElement()..tabIndex = -1)
              ..onClick.listen(messageCheckboxClick),
           new TableCellElement()
              ..text = message.createdAt != null? messageDateFormat.format(message.createdAt) : "??",
           new TableCellElement()
              ..text = '${callerInfo()}',
           new TableCellElement()
              ..text = '${message.context.contactName} (${message.context.receptionName})',
           new TableCellElement()
              ..text = message.sender.name,
           new TableCellElement()
              ..children = [_messageStatusIcon (message)]]);
  }

  /**
   *
   */

  Element _messageStatusIcon (model.Message message) {
    if (message.enqueued) {
      return Icon.Enqueued..title = Label.MessageToolTipEnqueued;
    }

    if (message.sent) {
      return Icon.Sent..title = Label.MessageToolTipSent;
    }

    if (!message.sent && ! message.enqueued) {
      return Icon.Saved..title = Label.MessageToolTipSent;
    }

    return Icon.Unknown..title = Label.MessageToolTipUnknown;
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
