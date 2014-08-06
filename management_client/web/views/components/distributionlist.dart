part of contact.view;

class DistributionsListComponent {
  final Element parent;
  final Function onChange;
  DistributionList persistentList;
  UListElement ulTo = new UListElement()
    ..classes.add('zebra')
    ..classes.add('distributionlist');

  UListElement ulCc = new UListElement()
    ..classes.add('zebra')
    ..classes.add('distributionlist');

  UListElement ulBcc = new UListElement()
    ..classes.add('zebra')
    ..classes.add('distributionlist');

  SelectElement toPicker = new SelectElement();
  SelectElement ccPicker = new SelectElement();
  SelectElement bccPicker = new SelectElement();

  List<ReceptionColleague> colleagues = new List<ReceptionColleague>();

  DistributionsListComponent(Element this.parent, Function this.onChange) {
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

    parent.children.addAll([header,
                            toLabel,  ulTo,
                            ccLabel,  ulCc,
                            bccLabel, ulBcc]);

    _registerEventListerns();
  }

  void _registerEventListerns() {
    _registerPicker(toPicker, ulTo);
    _registerPicker(ccPicker, ulCc);
    _registerPicker(bccPicker, ulBcc);
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

  Future load(int receptionId, int contactId) {
    return request.getContactsColleagues(contactId).then((List<ReceptionColleague> list) {
      this.colleagues = list;
    }).then((_) {
      return request.getDistributionList(receptionId, contactId).then((DistributionList list) {
        populateUL(list);
      });
    }).catchError((error) {
      log.error('Tried to load contact ${contactId} in reception: ${receptionId} distributionList but got: ${error}');
    });
  }

  void populateUL(DistributionList list) {
    this.persistentList = list;
    ulTo.children
      ..clear()
      ..addAll(list.to.map(_makeEndpointRow))
      ..add(_makeNewEndpointRow(toPicker, ulTo));

    ulCc.children
      ..clear()
      ..addAll(list.cc.map(_makeEndpointRow))
      ..add(_makeNewEndpointRow(ccPicker, ulCc));

    ulBcc.children
      ..clear()
      ..addAll(list.bcc.map(_makeEndpointRow))
      ..add(_makeNewEndpointRow(bccPicker, ulBcc));
  }

  LIElement _makeNewEndpointRow(SelectElement picker, UListElement ul) {
    LIElement li = new LIElement();

    List<ReceptionContact> allReadyInThelist = _extractReceptionContacts(ul);

    _populatePicker(picker, allReadyInThelist);

    li.children.add(picker);
    return li;
  }

  void _populatePicker(SelectElement picker, List<ReceptionContact> allReadyInThelist) {
    picker.children.clear();
    picker.children.add(new OptionElement(data: 'Vælg'));
    for(var reception in colleagues) {
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

  LIElement _makeEndpointRow(ReceptionContact contact) {
    LIElement li = new LIElement()
      ..dataset['reception_id'] = contact.receptionId.toString()
      ..dataset['contact_id'] = contact.contactId.toString();

    SpanElement element = new SpanElement();

    bool found = false;
    ReceptionColleague reception = colleagues.firstWhere((ReceptionColleague rc) => rc.id == contact.receptionId, orElse: () => null);
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

        allReadyInThelist = _extractReceptionContacts(ulTo);
        _populatePicker(toPicker, allReadyInThelist);

        allReadyInThelist = _extractReceptionContacts(ulCc);
        _populatePicker(ccPicker, allReadyInThelist);

        allReadyInThelist = _extractReceptionContacts(ulBcc);
        _populatePicker(bccPicker, allReadyInThelist);

      });

    li.children.addAll([deleteButton, element]);
    return li;
  }

  Future save(int receptionId, int contactId) {
    DistributionList distributionList = new DistributionList()
      ..to  = _extractReceptionContacts(ulTo)
      ..cc  = _extractReceptionContacts(ulCc)
      ..bcc = _extractReceptionContacts(ulBcc);

    return request.updateDistributionList(receptionId, contactId, JSON.encode(distributionList));
    //TODO Do something about the response
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

  void _notifyChange() {
    if(onChange != null) {
      onChange();
    }
  }
}
