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

  List<ContactAttribute> _extractContacts(UListElement ul) {
    List<ContactAttribute> list = new List<ContactAttribute>();
    for(LIElement li in ul.children) {
      if(li.dataset.containsKey('reception_id') && li.dataset.containsKey('contact_id')) {
        int receptionId = int.parse(li.dataset['reception_id']);
        int contactId = int.parse(li.dataset['contact_id']);
        list.add(new ContactAttribute()
        ..receptionId = receptionId
        ..contactId = contactId);
      }
    }

    return list;
  }

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

  LIElement _createEndpointRow(ContactAttribute contact) {
    LIElement li = new LIElement()
      ..dataset['reception_id'] = contact.receptionId.toString()
      ..dataset['contact_id'] = contact.contactId.toString();

    SpanElement element = new SpanElement();

    bool found = false;
    Reception reception = _colleagues.firstWhere((Reception r) => r.id == contact.receptionId, orElse: () => null);
    if(reception != null) {
      Contact colleague = reception.contacts.firstWhere((Contact c) => c.id == contact.contactId, orElse: () => null);
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

        List<ContactAttribute> allReadyInThelist;

        allReadyInThelist = _extractContacts(_ulTo);
        _populatePicker(_toPicker, allReadyInThelist);

        allReadyInThelist = _extractContacts(_ulCc);
        _populatePicker(_ccPicker, allReadyInThelist);

        allReadyInThelist = _extractContacts(_ulBcc);
        _populatePicker(_bccPicker, allReadyInThelist);

      });

    li.children.addAll([deleteButton, element]);
    return li;
  }

  LIElement _createNewEndpointRow(SelectElement picker, UListElement ul) {
    LIElement li = new LIElement();

    List<ContactAttribute> allReadyInThelist = _extractContacts(ul);

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
      ..addAll(list.to.map(_createEndpointRow))
      ..add(_createNewEndpointRow(_toPicker, _ulTo));

    _ulCc.children
      ..clear()
      ..addAll(list.cc.map(_createEndpointRow))
      ..add(_createNewEndpointRow(_ccPicker, _ulCc));

    _ulBcc.children
      ..clear()
      ..addAll(list.bcc.map(_createEndpointRow))
      ..add(_createNewEndpointRow(_bccPicker, _ulBcc));
  }

  void _populatePicker(SelectElement picker, List<ContactAttribute> allReadyInTheList) {
    picker.children.clear();
    picker.children.add(new OptionElement(data: 'Vælg'));
    for(Reception reception in _colleagues) {
      for(Contact contact in reception.contacts) {
        if(!allReadyInTheList.any((ContactAttribute ca) => ca.contactId == contact.id && ca.receptionId == reception.id)) {
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

        ContactAttribute contact = new ContactAttribute()
          ..receptionId = receptionId
          ..contactId = contactId;

        int index = ul.children.length -1;
        ul.children.insert(index, _createEndpointRow(contact));

        picker.selectedIndex = 0;
        picker.children.remove(pickedOption);
        _notifyChange();
      }
    });
  }

  Future save(int receptionId, int contactId) {
    DistributionList distributionList = new DistributionList()
      ..to  = _extractContacts(_ulTo)
      ..cc  = _extractContacts(_ulCc)
      ..bcc = _extractContacts(_ulBcc);

    return request.updateDistributionList(receptionId, contactId, JSON.encode(distributionList))
        .then((_) => notify.info('Opdateringen af distributionslisten gik godt.'))
        .catchError((error, stack) {
      log.error('distributionlist.save. Tried to save updates to distributionlist, but got: ${error} ${stack}');
      notify.error('Der skete en fejl i forbindelse med opdateringen af distributions listen. ${error}');
    });
  }
}
