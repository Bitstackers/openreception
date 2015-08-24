part of contact.view;

class DistributionsListComponent {
  final Element _parent;
  final Function _onChange;

  final Controller.Contact _contactController;
  final Controller.Reception _receptionController;
  final Controller.DistributionList _dlistController;

  ORModel.DistributionList _persistentList = new ORModel.DistributionList.empty();

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

  DistributionsListComponent(Element this._parent, Function this._onChange, this._contactController, this._dlistController, this._receptionController) {
    _setup();

    _registerEventListerns();
  }

  /**
   * Setup the DOM structure and graphical model.
   */
  void _setup() {
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
  }

  Set<ORModel.DistributionListEntry> _extractEntries(UListElement ul) {
    List<ORModel.DistributionListEntry> list = new List<ORModel.DistributionListEntry>();
    for(LIElement li in ul.children) {
      if(li.dataset.containsKey('reception_id') && li.dataset.containsKey('contact_id')) {
        int receptionId = int.parse(li.dataset['reception_id']);
        int contactId = int.parse(li.dataset['contact_id']);
        String receptionName = li.dataset['reception_name'];
        String contactName = li.dataset['contact_name'];

        list.add(new ORModel.DistributionListEntry()
          ..receptionID = receptionId
          ..receptionName = receptionName
          ..contactID = contactId
          ..contactName = contactName);
      }
    }

    return list.toSet();
  }

  /**
   * Fetchs a contacts distribution list, and displays it.
   */
  void load(ORModel.Contact contact) {
    _dlistController.list(contact.receptionID, contact.ID).then((ORModel.DistributionList dlist) {
        _populateUL(dlist);

        Map<int, String> receptionNameCache = {};

        return _receptionController.list().then((Iterable<ORModel.Reception> receptions) {
          receptions.forEach((ORModel.Reception r) => receptionNameCache[r.ID] = r.fullName);
         }).then((_) {
          return _contactController.colleagues(contact.ID).then((Iterable<ORModel.Contact> contacts) {
          _populatePicker(_toPicker, dlist.to, contacts, receptionNameCache);
          _populatePicker(_ccPicker, dlist.cc, contacts, receptionNameCache);
          _populatePicker(_bccPicker, dlist.bcc, contacts, receptionNameCache);
        });
      });
    });
 }

  LIElement _createEntryRow(ORModel.DistributionListEntry recipient) {

    LIElement li = new LIElement()
      ..dataset['reception_id'] = recipient.receptionID.toString()
      ..dataset['contact_id'] = recipient.contactID.toString()
      ..dataset['reception_name'] = recipient.receptionName
      ..dataset['contact_name'] = recipient.contactName;


    if(recipient.id != ORModel.DistributionListEntry.noId) {
      li.dataset['id'] = recipient.id.toString();
    }

    SpanElement element = new SpanElement();

    element.text = '${recipient.contactName} (${recipient.receptionName})';


    ImageElement deleteButton = new ImageElement(src: 'image/tp/red_plus.svg')
      ..alt = 'Slet'
      ..classes.add('small-button')
      ..onClick.listen((_) {
        li.parent.children.remove(li);
        _notifyChange();


      });

    li.children.addAll([deleteButton, element]);
    return li;
  }

  LIElement _createNewPickerRow(SelectElement picker, UListElement ul) {
    LIElement li = new LIElement();

    li.children.add(picker);
    return li;
  }

  void _notifyChange() {
    if(_onChange != null) {
      _onChange();
    }
  }

  void _populateUL(ORModel.DistributionList list) {
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

  void _populatePicker(SelectElement picker,
                       Iterable<ORModel.DistributionListEntry> contactDistributionList,
                       Iterable<ORModel.Contact> contacts,
                       Map<int, String> receptionNameCache) {
    picker.children.clear();
    picker.children.add(new OptionElement(data: 'Vælg'));
    contacts.forEach((ORModel.Contact contact) {
      String displayedText = '${contact.fullName} (${contact.receptionID})';
      picker.children.add(new OptionElement(data: displayedText)
        ..dataset['reception_id'] = contact.receptionID.toString()
        ..dataset['contact_id'] = contact.ID.toString()
        ..dataset['reception_name'] = receptionNameCache.containsKey(contact.receptionID) ? receptionNameCache[contact.receptionID] : '??'
        ..dataset['contact_name'] = contact.fullName.toString());
    });
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
        String receptionName = pickedOption.dataset['reception_name'];
        String contactName = pickedOption.dataset['contact_name'];

        ORModel.DistributionListEntry entry = new ORModel.DistributionListEntry()
          ..contactName = contactName
          ..receptionName = receptionName
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
    ORModel.DistributionList foundEntries = new ORModel.DistributionList.empty();

    _extractEntries(_ulTo).forEach((ORModel.DistributionListEntry dle) {
      dle..role = ORModel.Role.TO;
      foundEntries.add(dle);
    });

    _extractEntries(_ulCc).forEach((ORModel.DistributionListEntry dle) {
      dle..role = ORModel.Role.CC;
      foundEntries.add(dle);
    });

    _extractEntries(_ulBcc).forEach((ORModel.DistributionListEntry dle) {
      dle..role = ORModel.Role.BCC;
      foundEntries.add(dle);
    });

    //TESTING
    print('----- TO -----');
    foundEntries.to.forEach((e) => print('Id: ${e.id} Contact: ${e.contactID} Reception: ${e.receptionID}'));
    print('----- CC -----');
    foundEntries.cc.forEach((e) => print('Id: ${e.id} Contact: ${e.contactID} Reception: ${e.receptionID}'));
    print('----- BCC -----');
    foundEntries.bcc.forEach((e) => print('Id: ${e.id} Contact: ${e.contactID} Reception: ${e.receptionID}'));


    List<ORModel.DistributionListEntry> deleteList = new List<ORModel.DistributionListEntry>();

    //Deletes
    for(ORModel.DistributionListEntry entry in _persistentList.to) {
      if(!foundEntries.to.any((ORModel.DistributionListEntry e) => e.id == entry.id)) {
        //TODO delete [entry]
        print('Delete: Id: ${entry.id}');
        deleteList.add(entry);
      }
    }

    for(ORModel.DistributionListEntry entry in _persistentList.cc) {
      if(!foundEntries.cc.any((ORModel.DistributionListEntry e) => e.id == entry.id)) {
        //TODO delete [entry]
        print('Delete: Id: ${entry.id}');
        deleteList.add(entry);
      }
    }

    for(ORModel.DistributionListEntry entry in _persistentList.bcc) {
      if(!foundEntries.bcc.any((ORModel.DistributionListEntry e) => e.id == entry.id)) {
        //TODO delete [entry]
        print('Delete: Id: ${entry.id}');
        deleteList.add(entry);
      }
    }


    List<ORModel.DistributionListEntry> insertList = new List<ORModel.DistributionListEntry>();

    //Inserts
    for(ORModel.DistributionListEntry entry in foundEntries.to) {
      if(entry.id == ORModel.DistributionListEntry.noId) {
        //TODO insert [entry] as to
        print('Insert TO: Contact@Reception ${entry.contactID}@${entry.receptionID}');
        insertList.add(entry..role = ORModel.Role.TO);
      }
    }

    for(ORModel.DistributionListEntry entry in foundEntries.cc) {
      if(entry.id == ORModel.DistributionListEntry.noId) {
        //TODO insert [entry] as cc
        print('Insert CC: Contact@Reception ${entry.contactID}@${entry.receptionID}');
        insertList.add(entry..role = ORModel.Role.CC);
      }
    }

    for(ORModel.DistributionListEntry entry in foundEntries.bcc) {
      if(entry.id == ORModel.DistributionListEntry.noId) {
        //TODO insert [entry] as bcc
        print('Insert BCC: Contact@Reception ${entry.contactID}@${entry.receptionID}');
        insertList.add(entry..role = ORModel.Role.BCC);
      }
    }

    //Make sure all delete work is done, before Inserts starts.
    return Future.wait(
        deleteList.map((ORModel.DistributionListEntry entry) =>
            _dlistController.removeRecipient(entry.id)
            .catchError((error, stack) {
          log.error('Request to delete an distribution list entry failed. receptionId: "${receptionId}", contactId: "${receptionId}", entry: "${JSON.encode(entry)}" error: ${error} ${stack}');
          // Rethrow.
          throw error;
        })))
    .then((_) => Future.wait(
      insertList.map((ORModel.DistributionListEntry entry) =>
          _dlistController.addRecipient(receptionId, contactId, entry)
            .catchError((error, stack) {
          log.error('Request to insert an distribution list entry failed. receptionId: "${receptionId}", contactId: "${receptionId}", entry: "${JSON.encode(entry)}" error: ${error} ${stack}');
          // Rethrow.
          throw error;
        }))
    ));
  }
}
