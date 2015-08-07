part of contact.view;

class DistributionsListComponent {
  final Element _parent;
  final Function _onChange;

  List<ORModel.Reception> _colleagues = new List<ORModel.Reception>();
  ORModel.MessageRecipientList _persistentList = new ORModel.MessageRecipientList.empty();

  UListElement _ulTo = new UListElement()
    ..classes.add('zebra-even')
    ..classes.add('distributionlist');

  UListElement _ulCc = new UListElement()
    ..classes.add('zebra-even')
    ..classes.add('distributionlist');

  UListElement _ulBcc = new UListElement()
    ..classes.add('zebra-even')
    ..classes.add('distributionlist');

  SelectElement _toPicker = new SelectElement();
  SelectElement _ccPicker = new SelectElement();
  SelectElement _bccPicker = new SelectElement();

  DistributionsListComponent(Element this._parent, Function this._onChange) {
    LabelElement header = new LabelElement()
      ..text = 'Distributionsliste';

    LabelElement toLabel = new LabelElement()
      ..text = 'To'
      ..title = 'To';
    LabelElement ccLabel = new LabelElement()
      ..text = 'CC'
      ..title = 'Carbon Copy';
    LabelElement bccLabel = new LabelElement()
      ..text = 'BCC'
      ..title = 'Blind Carbon Copy';

    _parent.children.addAll([header,
                            toLabel,  _ulTo,
                            ccLabel,  _ulCc,
                            bccLabel, _ulBcc]);

    _registerEventListerns();
  }

  List<ORModel.MessageRecipient> _extractEntries(UListElement ul) {
    List<ORModel.MessageRecipient> list = new List<ORModel.MessageRecipient>();
    for(LIElement li in ul.children) {
      if(li.dataset.containsKey('reception_id') && li.dataset.containsKey('contact_id')) {
        int receptionId = int.parse(li.dataset['reception_id']);
        int contactId = int.parse(li.dataset['contact_id']);

        list.add(new ORModel.MessageRecipient()
          ..receptionID = receptionId
          ..contactID = contactId);
      }
    }

    return list;
  }

  /**
   * Fetchs a contacts distribution list, and displays it.
   * TODO: Fetch the associated contacts.
   */
  void load(ORModel.Contact contact) {
//    return request.getColleagues(contactId).then((List<ORModel.Reception> list) {
//      this._colleagues = list;
//    }).then((_) {
        _populateUL(contact.distributionList);

 }

  LIElement _createEntryRow(ORModel.MessageRecipient recipient) {
    LIElement li = new LIElement()
      ..dataset['reception_id'] = recipient.receptionID.toString()
      ..dataset['contact_id'] = recipient.contactID.toString();

//    if(recipient.id != null) {
//      li.dataset['id'] = recipient.id.toString();
//    }

    SpanElement element = new SpanElement();

    bool found = false;
//    ORModel.Reception reception = _colleagues.firstWhere((ORModel.Reception r) => r.ID == recipient.receptionId, orElse: () => null);
//    if(reception != null) {
//      ORModel.Contact colleague = reception.contacts.firstWhere((ORModel.Contact c) => c.ID == recipient.contactId, orElse: () => null);
//      if(colleague != null) {
//        found = true;
//        element.text = '${colleague.fullName} (${reception.fullName})';
//      }
//    }

    ImageElement deleteButton = new ImageElement(src: 'image/tp/red_plus.svg')
      ..alt = 'Slet'
      ..classes.add('small-button')
      ..onClick.listen((_) {
        li.parent.children.remove(li);
        _notifyChange();

        List<ORModel.MessageRecipient> allReadyInThelist;

        allReadyInThelist = _extractEntries(_ulTo);
        _populatePicker(_toPicker, allReadyInThelist);

        allReadyInThelist = _extractEntries(_ulCc);
        _populatePicker(_ccPicker, allReadyInThelist);

        allReadyInThelist = _extractEntries(_ulBcc);
        _populatePicker(_bccPicker, allReadyInThelist);

      });

    li.children.addAll([deleteButton, element]);
    return li;
  }

  LIElement _createNewPickerRow(SelectElement picker, UListElement ul) {
    LIElement li = new LIElement();

    List<ORModel.MessageRecipient> allReadyInThelist = _extractEntries(ul);

    _populatePicker(picker, allReadyInThelist);

    li.children.add(picker);
    return li;
  }

  void _notifyChange() {
    if(_onChange != null) {
      _onChange();
    }
  }

  void _populateUL(ORModel.MessageRecipientList list) {
    this._persistentList = list;
    _ulTo.children
      ..clear()
      ..addAll(list.recipients[ORModel.Role.TO].map(_createEntryRow))
      ..add(_createNewPickerRow(_toPicker, _ulTo));

    _ulCc.children
      ..clear()
      ..addAll(list.recipients[ORModel.Role.CC].map(_createEntryRow))
      ..add(_createNewPickerRow(_ccPicker, _ulCc));

    _ulBcc.children
      ..clear()
      ..addAll(list.recipients[ORModel.Role.BCC].map(_createEntryRow))
      ..add(_createNewPickerRow(_bccPicker, _ulBcc));
  }

  void _populatePicker(SelectElement picker, List<ORModel.MessageRecipient> allReadyInTheList) {
    picker.children.clear();
    picker.children.add(new OptionElement(data: 'Vælg'));
    for(ORModel.Reception reception in _colleagues) {
      for(ORModel.Contact contact in reception.contacts) {
        if(!allReadyInTheList.any((ORModel.MessageRecipient entry) => entry.contactId == contact.id && entry.receptionId == reception.id)) {
          String displayedText = '${contact.fullName} (${reception.fullName})';
          picker.children.add(new OptionElement(data: displayedText)
            ..dataset['reception_id'] = reception.id.toString()
            ..dataset['contact_id'] = contact.id.toString());
        }
      }
    }
  }

  void _registerEventListerns() {
    _registerPicker(_toPicker, _ulTo);
    _registerPicker(_ccPicker, _ulCc);
    _registerPicker(_bccPicker, _ulBcc);
  }

  void _registerPicker(SelectElement picker, UListElement ul) {
    picker.onChange.listen((_) {
      if(picker.selectedIndex != 0) {
        OptionElement pickedOption = picker.options[picker.selectedIndex];
        int receptionId = int.parse(pickedOption.dataset['reception_id']);
        int contactId = int.parse(pickedOption.dataset['contact_id']);

        ORModel.MessageRecipient entry = new ORModel.MessageRecipient()
          ..receptionID = receptionId
          ..contactID = contactId;

        int index = ul.children.length -1;
        ul.children.insert(index, _createEntryRow(entry));

        picker.selectedIndex = 0;
        picker.children.remove(pickedOption);
        _notifyChange();
      }
    });
  }

  Future save(int receptionId, int contactId) {
    ORModel.MessageRecipientList foundEntries = new ORModel.MessageRecipientList.empty()
      ..to  = _extractEntries(_ulTo)
      ..cc  = _extractEntries(_ulCc)
      ..bcc = _extractEntries(_ulBcc);

    foundEntries.to.forEach((ORModel.MessageRecipient entry) => entry.role = 'to');
    foundEntries.cc.forEach((ORModel.MessageRecipient entry) => entry.role = 'cc');
    foundEntries.bcc.forEach((ORModel.MessageRecipient entry) => entry.role = 'bcc');

    //TESTING
    print('----- TO -----');
    foundEntries.to.forEach((e) => print('Id: ${e.id} Contact: ${e.contactId} Reception: ${e.receptionId}'));
    print('----- CC -----');
    foundEntries.cc.forEach((e) => print('Id: ${e.id} Contact: ${e.contactId} Reception: ${e.receptionId}'));
    print('----- BCC -----');
    foundEntries.bcc.forEach((e) => print('Id: ${e.id} Contact: ${e.contactId} Reception: ${e.receptionId}'));


    List<ORModel.MessageRecipient> deleteList = new List<ORModel.MessageRecipient>();

    //Deletes
    for(ORModel.MessageRecipient entry in _persistentList.to) {
      if(!foundEntries.to.any((ORModel.MessageRecipient e) => e.id == entry.id)) {
        //TODO delete [entry]
        print('Delete: Id: ${entry.id}');
        deleteList.add(entry);
      }
    }

    for(ORModel.MessageRecipient entry in _persistentList.cc) {
      if(!foundEntries.cc.any((ORModel.MessageRecipient e) => e.id == entry.id)) {
        //TODO delete [entry]
        print('Delete: Id: ${entry.id}');
        deleteList.add(entry);
      }
    }

    for(ORModel.MessageRecipient entry in _persistentList.bcc) {
      if(!foundEntries.bcc.any((ORModel.MessageRecipient e) => e.id == entry.id)) {
        //TODO delete [entry]
        print('Delete: Id: ${entry.id}');
        deleteList.add(entry);
      }
    }


    List<ORModel.MessageRecipient> insertList = new List<ORModel.MessageRecipient>();

    //Inserts
    for(ORModel.MessageRecipient entry in foundEntries.to) {
      if(entry.id == null) {
        //TODO insert [entry] as to
        print('Insert TO: Contact@Reception ${entry.contactId}@${entry.receptionId}');
        insertList.add(entry);
      }
    }

    for(ORModel.MessageRecipient entry in foundEntries.cc) {
      if(entry.id == null) {
        //TODO insert [entry] as cc
        print('Insert CC: Contact@Reception ${entry.contactId}@${entry.receptionId}');
        insertList.add(entry);
      }
    }

    for(ORModel.MessageRecipient entry in foundEntries.bcc) {
      if(entry.id == null) {
        //TODO insert [entry] as bcc
        print('Insert BCC: Contact@Reception ${entry.contactId}@${entry.receptionId}');
        insertList.add(entry);
      }
    }

    //Make sure all delete work is done, before Inserts starts.
    return Future.wait(
        deleteList.map((ORModel.MessageRecipient entry) => request.deleteDistributionListEntry(receptionId, contactId, entry.id)
            .catchError((error, stack) {
          log.error('Request to delete an distribution list entry failed. receptionId: "${receptionId}", contactId: "${receptionId}", entry: "${JSON.encode(entry)}" error: ${error} ${stack}');
          // Rethrow.
          throw error;
        })))
    .then((_) => Future.wait(
      insertList.map((ORModel.MessageRecipient entry) => request.createDistributionListEntry(receptionId, contactId, JSON.encode(entry))
            .catchError((error, stack) {
          log.error('Request to insert an distribution list entry failed. receptionId: "${receptionId}", contactId: "${receptionId}", entry: "${JSON.encode(entry)}" error: ${error} ${stack}');
          // Rethrow.
          throw error;
        }))
    ));
  }
}
