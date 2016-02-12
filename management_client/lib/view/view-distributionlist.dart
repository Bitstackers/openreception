part of management_tool.view;

class DistributionsListChange {
  final Change type;
  final model.DistributionListEntry entry;

  DistributionsListChange.add(this.entry) : type = Change.created;
  DistributionsListChange.remove(this.entry) : type = Change.deleted;
}

/**
 *
 */
class DistributionsList {
  final Logger _log = new Logger('$_libraryName.DistributionsList');

  final DivElement element = new DivElement();

  final Queue _changes = new Queue();

  Stream<DistributionsListChange> get changes => _changeBus.stream;
  final Bus<DistributionsListChange> _changeBus =
      new Bus<DistributionsListChange>();

  final controller.Contact _contactController;
  final controller.Reception _receptionController;
  final controller.DistributionList _dlistController;
  model.Contact _owner;

  /// Local cached copy.
  model.DistributionList _persistentList = new model.DistributionList.empty();

  final ButtonElement _saveButton = new ButtonElement()
    ..text = 'Gem'
    ..classes.add('save')
    ..disabled = true;

  final UListElement _ulTo = new UListElement()
    ..classes.add('zebra-even')
    ..classes.add('distributionlist');

  final UListElement _ulCc = new UListElement()
    ..classes.add('zebra-even')
    ..classes.add('distributionlist');

  final UListElement _ulBcc = new UListElement()
    ..classes.add('zebra-even')
    ..classes.add('distributionlist');

  SelectElement _toPicker = new SelectElement();
  SelectElement _ccPicker = new SelectElement();
  SelectElement _bccPicker = new SelectElement();


  final PreElement _tmpTextInput = new PreElement();

  /**
   *
   */
  DistributionsList(this._contactController, this._dlistController,
      this._receptionController) {

    element.children = [_tmpTextInput];

    //_setup();

    //_registerEventListerns();
  }

  /**
   * Setup the DOM structure and graphical model.
   */
  void _setup() {

    ParagraphElement toLabel = new ParagraphElement()
      ..text = 'Til'
      ..title = 'To';
    ParagraphElement ccLabel = new ParagraphElement()
      ..text = 'cc'
      ..title = 'Carbon Copy';
    ParagraphElement bccLabel = new ParagraphElement()
      ..text = 'bcc'
      ..title = 'Blind Carbon Copy';

    _saveButton.onClick.listen((_) async {
      _saveButton.disabled = true;

      await Future.doWhile(() async {
        if (_changes.isEmpty) {
          return false;
        }

        await _changes.removeFirst()();
        return true;
      }).whenComplete(() => _saveButton.disabled = _changes.isEmpty);
    });

    element.children.addAll([
      _saveButton,
      toLabel,
      _ulTo,
      ccLabel,
      _ulCc,
      bccLabel,
      _ulBcc
    ]);
  }

  /**
   *
   */
  Set<model.DistributionListEntry> _extractEntries(UListElement ul) {
    List<model.DistributionListEntry> list =
        new List<model.DistributionListEntry>();
    ul.children.where((e) => e is LIElement).forEach((li) {
      if (li.dataset.containsKey('reception_id') &&
          li.dataset.containsKey('contact_id')) {
        int receptionId = int.parse(li.dataset['reception_id']);
        int contactId = int.parse(li.dataset['contact_id']);
        String receptionName = li.dataset['reception_name'];
        String contactName = li.dataset['contact_name'];

        list.add(new model.DistributionListEntry()
          ..receptionID = receptionId
          ..receptionName = receptionName
          ..contactID = contactId
          ..contactName = contactName);
      }
    });

    return list.toSet();
  }

  /**
   * Fetchs a contacts distribution list, and displays it.
   */
  void set owner(model.Contact contact) {
    _owner = contact;

    _dlistController
        .list(contact.receptionID, contact.ID)
        .then((model.DistributionList dlist) async {
      _populateUL(dlist);

      Iterable<model.Reception> rs = await _receptionController.list();
      Map<int, String> receptionNameCache = {};
      rs.forEach((model.Reception r) => receptionNameCache[r.ID] = r.name);

      return _receptionController
          .list()
          .then((Iterable<model.Reception> receptions) {
        receptions.forEach(
            (model.Reception r) => receptionNameCache[r.ID] = r.fullName);
      }).then((_) {
        return _contactController
            .colleagues(contact.ID)
            .then((Iterable<model.Contact> contacts) {
          _populatePicker(_toPicker, dlist.to, contacts, receptionNameCache);
          _populatePicker(_ccPicker, dlist.cc, contacts, receptionNameCache);
          _populatePicker(_bccPicker, dlist.bcc, contacts, receptionNameCache);
        });
      });
    });
  }

  /**
   *
   */
  LIElement _createEntryRow(model.DistributionListEntry entry) {
    LIElement li = new LIElement()
      ..dataset['reception_id'] = entry.receptionID.toString()
      ..dataset['contact_id'] = entry.contactID.toString()
      ..dataset['reception_name'] = entry.receptionName
      ..dataset['contact_name'] = entry.contactName;

    if (entry.id != model.DistributionListEntry.noId) {
      li.dataset['id'] = entry.id.toString();
    }

    SpanElement element = new SpanElement();

    element.text = '${entry.contactName} (${entry.receptionName})';

    ImageElement deleteButton = new ImageElement(src: 'image/tp/red_plus.svg')
      ..alt = 'Slet'
      ..classes.add('small-button')
      ..onClick.listen((_) {
        li.parent.children.remove(li);

        _changes.add(() => _dlistController.removeRecipient(entry.id));
        _notifyChange();
      });

    li.children.addAll([deleteButton, element]);
    return li;
  }

  /**
   *
   */
  LIElement _createNewPickerRow(SelectElement picker, UListElement ul) {
    LIElement li = new LIElement();

    li.children.add(picker);
    return li;
  }

  /**
   *
   */
  void _notifyChange() {
    _saveButton.disabled = false;
  }

  /**
   *
   */
  void _populateUL(model.DistributionList list) {
    _persistentList = list;
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


    _tmpTextInput.text = (_jsonpp.convert(_persistentList));
  }

  /**
   *
   */
  void _populatePicker(
      SelectElement picker,
      Iterable<model.DistributionListEntry> contactDistributionList,
      Iterable<model.Contact> contacts,
      Map<int, String> receptionNameCache) {
    picker.children.clear();
    picker.children.add(new OptionElement(data: 'Vælg'));
    contacts.forEach((model.Contact contact) {
      final String receptionName = receptionNameCache.containsKey(
          contact.receptionID) ? receptionNameCache[contact.receptionID] : '??';

      String displayedText = '${contact.fullName} ($receptionName)';
      picker.children.add(new OptionElement(data: displayedText)
        ..dataset['reception_id'] = contact.receptionID.toString()
        ..dataset['contact_id'] = contact.ID.toString()
        ..dataset['reception_name'] =
            receptionNameCache.containsKey(contact.receptionID)
                ? receptionNameCache[contact.receptionID]
                : '??'
        ..dataset['contact_name'] = contact.fullName.toString());
    });
  }

  /**
   *
   */
  void _registerEventListerns() {
    _registerPicker(_toPicker, _ulTo, model.Role.TO);
    _registerPicker(_ccPicker, _ulCc, model.Role.CC);
    _registerPicker(_bccPicker, _ulBcc, model.Role.BCC);
  }

  /**
   *
   */
  void _registerPicker(SelectElement picker, UListElement ul, String role) {
    picker.onChange.listen((_) {
      if (picker.selectedIndex != 0) {
        OptionElement pickedOption = picker.options[picker.selectedIndex];
        int receptionId = int.parse(pickedOption.dataset['reception_id']);
        int contactId = int.parse(pickedOption.dataset['contact_id']);
        String receptionName = pickedOption.dataset['reception_name'];
        String contactName = pickedOption.dataset['contact_name'];

        model.DistributionListEntry entry = new model.DistributionListEntry()
          ..role = role
          ..contactName = contactName
          ..receptionName = receptionName
          ..receptionID = receptionId
          ..contactID = contactId;

        int index = ul.children.length - 1;
        ul.children.insert(index, _createEntryRow(entry));

        picker.selectedIndex = 0;
        picker.children.remove(pickedOption);

        _changes.add(() => _dlistController.addRecipient(
            _owner.receptionID, _owner.ID, entry));

        _notifyChange();
      }
    });
  }

  /**
   *
   */
  Iterable<DistributionsListChange> get allChanges {
    model.DistributionList foundEntries = new model.DistributionList.empty();

    final List<DistributionsListChange> changes = [];

    _extractEntries(_ulTo).forEach((model.DistributionListEntry dle) {
      dle..role = model.Role.TO;
      foundEntries.add(dle);
    });

    _extractEntries(_ulCc).forEach((model.DistributionListEntry dle) {
      dle..role = model.Role.CC;
      foundEntries.add(dle);
    });

    _extractEntries(_ulBcc).forEach((model.DistributionListEntry dle) {
      dle..role = model.Role.BCC;
      foundEntries.add(dle);
    });

    //Deletes
    for (model.DistributionListEntry entry in _persistentList.to) {
      if (!foundEntries.to
          .any((model.DistributionListEntry e) => e.id == entry.id)) {
        changes.add(new DistributionsListChange.remove(entry));
      }
    }

    for (model.DistributionListEntry entry in _persistentList.cc) {
      if (!foundEntries.cc
          .any((model.DistributionListEntry e) => e.id == entry.id)) {
        changes.add(new DistributionsListChange.remove(entry));
      }
    }

    for (model.DistributionListEntry entry in _persistentList.bcc) {
      if (!foundEntries.bcc
          .any((model.DistributionListEntry e) => e.id == entry.id)) {
        changes.add(new DistributionsListChange.remove(entry));
      }
    }

    //Inserts
    for (model.DistributionListEntry entry in foundEntries.to) {
      if (entry.id == model.DistributionListEntry.noId) {
        changes.add(new DistributionsListChange.add(entry));
      }
    }

    for (model.DistributionListEntry entry in foundEntries.cc) {
      changes.add(new DistributionsListChange.add(entry));
    }

    for (model.DistributionListEntry entry in foundEntries.bcc) {
      changes.add(new DistributionsListChange.add(entry));
    }

    return changes;

//    //Make sure all delete work is done, before Inserts starts.
//    return Future
//        .wait(deleteList.map((model.DistributionListEntry entry) =>
//            _dlistController
//                .removeRecipient(entry.id)
//                .catchError((error, stack) {
//              _log.severe(
//                  'Request to delete an distribution list entry failed. receptionId: "${receptionId}", contactId: "${receptionId}", entry: "${JSON.encode(entry)}" error: ${error} ${stack}');
//              // Rethrow.
//              throw error;
//            })))
//        .then((_) => Future.wait(insertList.map(
//            (model.DistributionListEntry entry) => _dlistController
//                    .addRecipient(receptionId, contactId, entry)
//                    .catchError((error, stack) {
//                  _log.severe(
//                      'Request to insert an distribution list entry failed. receptionId: "${receptionId}", contactId: "${receptionId}", entry: "${JSON.encode(entry)}" error: ${error} ${stack}');
//                  // Rethrow.
//                  throw error;
//                }))));
  }
}
