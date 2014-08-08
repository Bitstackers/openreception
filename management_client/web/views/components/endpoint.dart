part of contact.view;

class EndpointsComponent {
  static List<String> _addressTypes = new List<String>();

  Element _element;
  Function _onChange;
  List<Endpoint> _persistenceEndpoint = new List<Endpoint>();
  UListElement _ul = new UListElement();
  LabelElement _header = new LabelElement()
    ..text = 'Kontaktpunkter';

  SortableGroup _sortGroup;

  EndpointsComponent(Element this._element, Function this._onChange) {
    _element.children.add(_header);
    _element.children.add(_ul);
  }

  static Future loadAddressTypes() {
    return request.getAddressTypeList().then((List<String> types) {
      EndpointsComponent._addressTypes = types;
    });
  }

  Future load(int receptionId, int contactId) {
    _persistenceEndpoint = new List<Endpoint>();
    return request.getEndpointsList(receptionId, contactId).then((List<Endpoint> list) {
      _populateUL(list);
    });
  }

  void _populateUL(List<Endpoint> list) {
    _persistenceEndpoint = list;
    list.sort();

    List<LIElement> items = list.map(_makeEndpointRow).toList();

    _ul.children
      ..clear()
      ..addAll(items)
      ..add(_makeNewEndpointRow());

    _sortGroup = new SortableGroup()
      ..installAll(items);

    // Only accept elements from the same section.
    _sortGroup.accept.add(_sortGroup);
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
        _sortGroup.install(row);
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
      ..children.addAll(_addressTypes.map((String type) => new OptionElement(data: type, value: type, selected: type == endpoint.addressType)))
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
    List<Endpoint> foundEndpoints = new List<Endpoint>();

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
      if(!_persistenceEndpoint.any((Endpoint e) => e.address == endpoint.address && e.addressType == endpoint.addressType)) {
        //Insert Endpoint
        worklist.add(request.createEndpoint(receptionId, contactId, JSON.encode(endpoint))
            .catchError((error, stack) {
          log.error('Request to create an endpoint failed. receptionId: "${receptionId}", contactId: "${receptionId}", endpoint: "${JSON.encode(endpoint)}" but got: ${error} ${stack}');
          // Rethrow.
          throw error;
        }));
      }
    }

    //Deletes
    for(Endpoint endpoint in _persistenceEndpoint) {
      if(!foundEndpoints.any((Endpoint e) => e.address == endpoint.address && e.addressType == endpoint.addressType)) {
        //Delete Endpoint
        worklist.add(request.deleteEndpoint(receptionId, contactId, endpoint.address, endpoint.addressType)
            .catchError((error, stack) {
          log.error('Request to delete an endpoint failed. receptionId: "${receptionId}", contactId: "${receptionId}", endpoint: "${JSON.encode(endpoint)}" but got: ${error} ${stack}');
          // Rethrow.
          throw error;
        }));
      }
    }

    //Update
    for(Endpoint endpoint in foundEndpoints) {
      if(_persistenceEndpoint.any((Endpoint e) => e.address == endpoint.address && e.addressType == endpoint.addressType)) {
        //Update Endpoint
        worklist.add(request.updateEndpoint(receptionId, contactId, endpoint.address, endpoint.addressType, JSON.encode(endpoint))
            .catchError((error, stack) {
          log.error('Request to update an endpoint failed. receptionId: "${receptionId}", contactId: "${receptionId}", endpoint: "${JSON.encode(endpoint)}" but got: ${error} ${stack}');
          // Rethrow.
          throw error;
        }));
      }
    }
    return Future.wait(worklist);
  }
}
