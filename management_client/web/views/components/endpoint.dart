part of contact.view;

class EndpointsComponent {
  static List<String> addressTypes = [];

  Element _element;
  Function _onChange;
  List<Endpoint> persistenceEndpoint = [];
  UListElement _ul = new UListElement();
  LabelElement header = new LabelElement()
    ..text = 'Kontaktpunkter';

  SortableGroup sortGroup;

  EndpointsComponent(Element this._element, Function this._onChange) {
    _element.children.add(header);
    _element.children.add(_ul);
  }

  void clear() {
    _ul.children.clear();
    persistenceEndpoint = [];
  }

  static Future loadAddressTypes() {
    return request.getAddressTypeList().then((List<String> types) {
      EndpointsComponent.addressTypes = types;
    });
  }

  Future load(int receptionId, int contactId) {
    persistenceEndpoint = [];
    return request.getEndpointsList(receptionId, contactId).then((List<Endpoint> list) {
      populateUL(list);
    });
  }

  void populateUL(List<Endpoint> list) {
    persistenceEndpoint = list;
    list.sort(Endpoint.sortByPriority);

    List<LIElement> items = list.map(_makeEndpointRow).toList();

    _ul.children
      ..clear()
      ..addAll(items)
      ..add(_makeNewEndpointRow());

    sortGroup = new SortableGroup()
      ..installAll(items);

    // Only accept elements from the same section.
    sortGroup.accept.add(sortGroup);
  }

  LIElement _makeNewEndpointRow() {
    LIElement li = new LIElement();

    ButtonElement createButton = new ButtonElement()
      ..text = 'Ny'
      ..onClick.listen((_) {
        Endpoint endpoint = new Endpoint()
          ..address = 'mig@eksempel.dk'
          ..enabled = true;
        LIElement row = _makeEndpointRow(endpoint);
        sortGroup.install(row);
        int index = _ul.children.length - 1;
        _ul.children.insert(index, row);
        _notifyChange();
    });

    li.children.addAll([createButton]);
    return li;
  }

  LIElement _makeEndpointRow(Endpoint endpoint) {
    LIElement li = new LIElement();

    SpanElement address = new SpanElement()
      ..classes.add('contact-endpoint-address')
      ..text = endpoint.address;
    InputElement addressEditBox = new InputElement(type: 'text');
    editableSpan(address, addressEditBox, _onChange);

    SelectElement typePicker = new SelectElement()
      ..classes.add('contact-endpoint-addresstype')
      ..children.addAll(addressTypes.map((String type) => new OptionElement(data: type, value: type, selected: type == endpoint.addressType)))
      ..onChange.listen((_) {
      _notifyChange();
    });

    LabelElement confidentialLabel = new LabelElement()
      ..text = 'Fortrolig';
    CheckboxInputElement confidentialCheckbox = new CheckboxInputElement()
      ..classes.add('contact-endpoint-confidential')
      ..checked = endpoint.confidential
      ..onChange.listen((_) {
      _notifyChange();
    });

    LabelElement enabledLabel = new LabelElement()
      ..text = 'Aktiv';
    CheckboxInputElement enabledCheckbox = new CheckboxInputElement()
      ..classes.add('contact-endpoint-enabled')
      ..checked = endpoint.enabled
      ..onChange.listen((_) {
        _notifyChange();
      });

    LabelElement descriptionLabel = new LabelElement()
      ..text = 'note:';
    TextInputElement descriptionInput = new TextInputElement()
      ..classes.add('contact-endpoint-description')
      ..value = endpoint.description
      ..onInput.listen((_) {
        _notifyChange();
    });

    ButtonElement deleteButton = new ButtonElement()
      ..text = 'Slet'
      ..onClick.listen((_) {
      _ul.children.remove(li);
      _notifyChange();
    });

    return li
        ..children.addAll([address, addressEditBox, typePicker,
                           confidentialLabel, confidentialCheckbox,
                           enabledLabel, enabledCheckbox,
                           descriptionLabel, descriptionInput,
                           deleteButton]);
  }

  void _notifyChange() {
    if(_onChange != null) {
      _onChange();
    }
  }

  Future save(int receptionId, int contactId) {
    List<Endpoint> foundEndpoints = [];

    int index = 1;
    for(LIElement item in _ul.children) {
      SpanElement addressSpan = item.querySelector('.contact-endpoint-address');
      SelectElement addressTypePicker = item.querySelector('.contact-endpoint-addresstype');
      CheckboxInputElement confidentialBox = item.querySelector('.contact-endpoint-confidential');
      CheckboxInputElement enabledBox = item.querySelector('.contact-endpoint-enabled');
      TextInputElement descriptionBox = item.querySelector('.contact-endpoint-description');

      if(addressSpan != null && addressTypePicker != null && confidentialBox != null && enabledBox != null) {
        Endpoint endpoint = new Endpoint()
          ..receptionId = receptionId
          ..contactId = contactId
          ..address = addressSpan.text
          ..addressType = addressTypePicker.selectedOptions.first.value
          ..confidential = confidentialBox.checked
          ..enabled = enabledBox.checked
          ..priority = index++
          ..description = descriptionBox.value;
        foundEndpoints.add(endpoint);
      }
    }

    List<Future> worklist = new List<Future>();

    //Inserts
    for(Endpoint endpoint in foundEndpoints) {
      if(!persistenceEndpoint.any((Endpoint e) => e.address == endpoint.address && e.addressType == endpoint.addressType)) {
        //Insert Endpoint
        worklist.add(request.createEndpoint(receptionId, contactId, JSON.encode(endpoint)));
      }
    }

    //Deletes
    for(Endpoint endpoint in persistenceEndpoint) {
      if(!foundEndpoints.any((Endpoint e) => e.address == endpoint.address && e.addressType == endpoint.addressType)) {
        //Delete Endpoint
        worklist.add(request.deleteEndpoint(receptionId, contactId, endpoint.address, endpoint.addressType));
      }
    }

    //Update
    for(Endpoint endpoint in foundEndpoints) {
      if(persistenceEndpoint.any((Endpoint e) => e.address == endpoint.address && e.addressType == endpoint.addressType)) {
        //Update Endpoint
        worklist.add(request.updateEndpoint(receptionId, contactId, endpoint.address, endpoint.addressType, JSON.encode(endpoint)));
      }
    }
    return Future.wait(worklist);
  }
}
