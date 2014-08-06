part of contact.view;

class DistributionsListComponent {
  final Element _parent;
  final Function _onChange;

  List<ReceptionColleague> _colleagues = new List<ReceptionColleague>();
  DistributionList _persistentList;

  UListElement _ulTo = new UListElement()
    ..classes.add('zebra')
    ..classes.add('distributionlist');

  UListElement _ulCc = new UListElement()
    ..classes.add('zebra')
    ..classes.add('distributionlist');

  UListElement _ulBcc = new UListElement()
    ..classes.add('zebra')
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

  List<ReceptionContact> _extractReceptionContacts(UListElement ul) {
    List<ReceptionContact> list = new List<ReceptionContact>();
    for(LIElement li in ul.children) {
      if(li.dataset.containsKey('reception_id') && li.dataset.containsKey('contact_id')) {
        int receptionId = int.parse(li.dataset['reception_id']);
        int contactId = int.parse(li.dataset['contact_id']);
        list.add(new ReceptionContact()
        ..receptionId = receptionId
        ..contactId = contactId);
      }
    }

    return list;
  }

  Future load(int receptionId, int contactId) {
    return request.getContactsColleagues(contactId).then((List<ReceptionColleague> list) {
      this._colleagues = list;
    }).then((_) {
      return request.getDistributionList(receptionId, contactId).then((DistributionList list) {
        _populateUL(list);
      });
    }).catchError((error) {
      log.error('Tried to load contact ${contactId} in reception: ${receptionId} distributionList but got: ${error}');
    });
  }

  LIElement _makeEndpointRow(ReceptionContact contact) {
    LIElement li = new LIElement()
      ..dataset['reception_id'] = contact.receptionId.toString()
      ..dataset['contact_id'] = contact.contactId.toString();

    SpanElement element = new SpanElement();

    bool found = false;
    ReceptionColleague reception = _colleagues.firstWhere((ReceptionColleague rc) => rc.id == contact.receptionId, orElse: () => null);
    if(reception != null) {
      Colleague colleague = reception.contacts.firstWhere((Colleague c) => c.id == contact.contactId, orElse: () => null);
      if(colleague != null) {
        found = true;
        element.text = '${colleague.full_name} (${reception.full_name})';
      }
    }

    if(found == false) {
      //This Should not happend.
      element.text = 'Fejl. Person ikke fundet.';
    }

    ImageElement deleteButton = new ImageElement(src: 'image/tp/red_plus.svg')
      ..classes.add('small-button')
      ..text = 'Slet'
      ..onClick.listen((_) {
        li.parent.children.remove(li);
        _notifyChange();

        List<ReceptionContact> allReadyInThelist;

        allReadyInThelist = _extractReceptionContacts(_ulTo);
        _populatePicker(_toPicker, allReadyInThelist);

        allReadyInThelist = _extractReceptionContacts(_ulCc);
        _populatePicker(_ccPicker, allReadyInThelist);

        allReadyInThelist = _extractReceptionContacts(_ulBcc);
        _populatePicker(_bccPicker, allReadyInThelist);

      });

    li.children.addAll([deleteButton, element]);
    return li;
  }

  LIElement _makeNewEndpointRow(SelectElement picker, UListElement ul) {
    LIElement li = new LIElement();

    List<ReceptionContact> allReadyInThelist = _extractReceptionContacts(ul);

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
      ..addAll(list.to.map(_makeEndpointRow))
      ..add(_makeNewEndpointRow(_toPicker, _ulTo));

    _ulCc.children
      ..clear()
      ..addAll(list.cc.map(_makeEndpointRow))
      ..add(_makeNewEndpointRow(_ccPicker, _ulCc));

    _ulBcc.children
      ..clear()
      ..addAll(list.bcc.map(_makeEndpointRow))
      ..add(_makeNewEndpointRow(_bccPicker, _ulBcc));
  }

  void _populatePicker(SelectElement picker, List<ReceptionContact> allReadyInThelist) {
    picker.children.clear();
    picker.children.add(new OptionElement(data: 'Vælg'));
    for(var reception in _colleagues) {
      for(var contact in reception.contacts) {
        if(!allReadyInThelist.any((rc) => rc.contactId == contact.id && rc.receptionId == reception.id)) {
          String displayedText = '${contact.full_name} (${reception.full_name})';
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

        ReceptionContact contact = new ReceptionContact()
          ..receptionId = receptionId
          ..contactId = contactId;

        int index = ul.children.length -1;
        ul.children.insert(index, _makeEndpointRow(contact));

        picker.selectedIndex = 0;
        picker.children.remove(pickedOption);
        _notifyChange();
      }
    });
  }

  Future save(int receptionId, int contactId) {
    DistributionList distributionList = new DistributionList()
      ..to  = _extractReceptionContacts(_ulTo)
      ..cc  = _extractReceptionContacts(_ulCc)
      ..bcc = _extractReceptionContacts(_ulBcc);

    return request.updateDistributionList(receptionId, contactId, JSON.encode(distributionList))
        .then((_) => notify.info('Opdateringen af distributionslisten gik godt.'))
        .catchError((error, stack) {
      log.error('distributionlist.save. Tried to save updates to distributionlist, but got: ${error} ${stack}');
      notify.error('Der skete en fejl i forbindelse med opdateringen af distributions listen. ${error}');
    });
  }
}
