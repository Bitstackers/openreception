part of contact.view;

class DistributionsListComponent {
  final Element _parent;
  final Function _onChange;

  List<Reception> _colleagues = new List<Reception>();
  DistributionList _persistentList;

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

  List<DistributionListEntry> _extractEntries(UListElement ul) {
    List<DistributionListEntry> list = new List<DistributionListEntry>();
    for(LIElement li in ul.children) {
      if(li.dataset.containsKey('reception_id') && li.dataset.containsKey('contact_id')) {
        int receptionId = int.parse(li.dataset['reception_id']);
        int contactId = int.parse(li.dataset['contact_id']);
        int id;
        if(li.dataset.containsKey('id')) {
          id = int.parse(li.dataset['id']);
        }
        list.add(new DistributionListEntry()
          ..receptionId = receptionId
          ..contactId = contactId
          ..id = id);
      }
    }

    return list;
  }

  /**
   * Fetchs a contacts distribution list, and displays it.
   */
  Future load(int receptionId, int contactId) {
    return request.getColleagues(contactId).then((List<Reception> list) {
      this._colleagues = list;
    }).then((_) {
      return request.getDistributionList(receptionId, contactId).then((DistributionList list) {
        _populateUL(list);
      });
    }).catchError((error, stack) {
      log.error('Tried to load contact ${contactId} in reception: ${receptionId} distributionList but got: ${error} ${stack}');
    });
  }

  LIElement _createEntryRow(DistributionListEntry entry) {
    LIElement li = new LIElement()
      ..dataset['reception_id'] = entry.receptionId.toString()
      ..dataset['contact_id'] = entry.contactId.toString();

    if(entry.id != null) {
      li.dataset['id'] = entry.id.toString();
    }

    SpanElement element = new SpanElement();

    bool found = false;
    Reception reception = _colleagues.firstWhere((Reception r) => r.id == entry.receptionId, orElse: () => null);
    if(reception != null) {
      Contact colleague = reception.contacts.firstWhere((Contact c) => c.id == entry.contactId, orElse: () => null);
      if(colleague != null) {
        found = true;
        element.text = '${colleague.fullName} (${reception.fullName})';
      }
    }

    ImageElement deleteButton = new ImageElement(src: 'image/tp/red_plus.svg')
      ..alt = 'Slet'
      ..classes.add('small-button')
      ..onClick.listen((_) {
        li.parent.children.remove(li);
        _notifyChange();

        List<DistributionListEntry> allReadyInThelist;

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

    List<DistributionListEntry> allReadyInThelist = _extractEntries(ul);

    _populatePicker(picker, allReadyInThelist);

    li.children.add(picker);
    return li;
  }

  void _notifyChange() {
    if(_onChange != null) {
      _onChange();
    }
  }

  void _populateUL(DistributionList list) {
    this._persistentList = list;
    _ulTo.children
      ..clear()
      ..addAll(list.to.map(_createEntryRow))
      ..add(_createNewPickerRow(_toPicker, _ulTo));

    _ulCc.children
      ..clear()
      ..addAll(list.cc.map(_createEntryRow))
      ..add(_createNewPickerRow(_ccPicker, _ulCc));

    _ulBcc.children
      ..clear()
      ..addAll(list.bcc.map(_createEntryRow))
      ..add(_createNewPickerRow(_bccPicker, _ulBcc));
  }

  void _populatePicker(SelectElement picker, List<DistributionListEntry> allReadyInTheList) {
    picker.children.clear();
    picker.children.add(new OptionElement(data: 'Vælg'));
    for(Reception reception in _colleagues) {
      for(Contact contact in reception.contacts) {
        if(!allReadyInTheList.any((DistributionListEntry entry) => entry.contactId == contact.id && entry.receptionId == reception.id)) {
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

        DistributionListEntry entry = new DistributionListEntry()
          ..receptionId = receptionId
          ..contactId = contactId;

        int index = ul.children.length -1;
        ul.children.insert(index, _createEntryRow(entry));

        picker.selectedIndex = 0;
        picker.children.remove(pickedOption);
        _notifyChange();
      }
    });
  }

  Future save(int receptionId, int contactId) {
    DistributionList foundEntries = new DistributionList()
      ..to  = _extractEntries(_ulTo)
      ..cc  = _extractEntries(_ulCc)
      ..bcc = _extractEntries(_ulBcc);

    foundEntries.to.forEach((DistributionListEntry entry) => entry.role = 'to');
    foundEntries.cc.forEach((DistributionListEntry entry) => entry.role = 'cc');
    foundEntries.bcc.forEach((DistributionListEntry entry) => entry.role = 'bcc');

    //TESTING
    print('----- TO -----');
    foundEntries.to.forEach((e) => print('Id: ${e.id} Contact: ${e.contactId} Reception: ${e.receptionId}'));
    print('----- CC -----');
    foundEntries.cc.forEach((e) => print('Id: ${e.id} Contact: ${e.contactId} Reception: ${e.receptionId}'));
    print('----- BCC -----');
    foundEntries.bcc.forEach((e) => print('Id: ${e.id} Contact: ${e.contactId} Reception: ${e.receptionId}'));


    List<DistributionListEntry> deleteList = new List<DistributionListEntry>();

    //Deletes
    for(DistributionListEntry entry in _persistentList.to) {
      if(!foundEntries.to.any((DistributionListEntry e) => e.id == entry.id)) {
        //TODO delete [entry]
        print('Delete: Id: ${entry.id}');
        deleteList.add(entry);
      }
    }

    for(DistributionListEntry entry in _persistentList.cc) {
      if(!foundEntries.cc.any((DistributionListEntry e) => e.id == entry.id)) {
        //TODO delete [entry]
        print('Delete: Id: ${entry.id}');
        deleteList.add(entry);
      }
    }

    for(DistributionListEntry entry in _persistentList.bcc) {
      if(!foundEntries.bcc.any((DistributionListEntry e) => e.id == entry.id)) {
        //TODO delete [entry]
        print('Delete: Id: ${entry.id}');
        deleteList.add(entry);
      }
    }


    List<DistributionListEntry> insertList = new List<DistributionListEntry>();

    //Inserts
    for(DistributionListEntry entry in foundEntries.to) {
      if(entry.id == null) {
        //TODO insert [entry] as to
        print('Insert TO: Contact@Reception ${entry.contactId}@${entry.receptionId}');
        insertList.add(entry);
      }
    }

    for(DistributionListEntry entry in foundEntries.cc) {
      if(entry.id == null) {
        //TODO insert [entry] as cc
        print('Insert CC: Contact@Reception ${entry.contactId}@${entry.receptionId}');
        insertList.add(entry);
      }
    }

    for(DistributionListEntry entry in foundEntries.bcc) {
      if(entry.id == null) {
        //TODO insert [entry] as bcc
        print('Insert BCC: Contact@Reception ${entry.contactId}@${entry.receptionId}');
        insertList.add(entry);
      }
    }

    //Make sure all delete work is done, before Inserts starts.
    return Future.wait(
        deleteList.map((DistributionListEntry entry) => request.deleteDistributionListEntry(receptionId, contactId, entry.id)
            .catchError((error, stack) {
          log.error('Request to delete an distribution list entry failed. receptionId: "${receptionId}", contactId: "${receptionId}", entry: "${JSON.encode(entry)}" error: ${error} ${stack}');
          // Rethrow.
          throw error;
        })))
    .then((_) => Future.wait(
      insertList.map((DistributionListEntry entry) => request.createDistributionListEntry(receptionId, contactId, JSON.encode(entry))
            .catchError((error, stack) {
          log.error('Request to insert an distribution list entry failed. receptionId: "${receptionId}", contactId: "${receptionId}", entry: "${JSON.encode(entry)}" error: ${error} ${stack}');
          // Rethrow.
          throw error;
        }))
    ));
  }
}
