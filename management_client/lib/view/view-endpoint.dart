part of management_tool.view;

/**
 * Visual representation of an endpoint collection belonging to a contact.
 *
 * TODO: Add reference to endpoint owner.
 */
class EndpointsComponent {
  List<String> get _addressTypes => model.MessageEndpointType.types;

  Logger log = new Logger('$_libraryName.EndpointsComponent');

  final controller.Contact _contactController;
  final controller.Endpoint _endpointController;

  final DivElement element = new DivElement();
  Function _onChange;

  List<model.MessageEndpoint> _persistenceEndpoint = [];
  UListElement _ul = new UListElement();
  ParagraphElement _header = new ParagraphElement()..text = 'Kontaktpunkter';

  ///TODO: Turn this into a textarea
  SortableGroup _sortGroup;


  final PreElement _tmpTextInput = new PreElement();

  EndpointsComponent(Function this._onChange,
      controller.Contact this._contactController, this._endpointController) {
//    element.children.add(_header);
//    element.children.add(_ul);

    element.children = [_tmpTextInput];
  }

  Future load(int receptionId, int contactId) {
    log.finest('̈́Loading endpoints for $contactId@$receptionId');
    _persistenceEndpoint = new List<model.MessageEndpoint>();
    return _endpointController
        .list(receptionId, contactId)
        .then((Iterable<model.MessageEndpoint> endpoints) {
      endpoints.forEach((ep) => print(ep.asMap));
      _populateUL(endpoints);
    });
  }

  void _populateUL(Iterable<model.MessageEndpoint> endpoints) {
    _persistenceEndpoint = endpoints.toList();

    int compareTo(model.MessageEndpoint m1, model.MessageEndpoint m2) =>
        m1.address.compareTo(m2.address);

    _persistenceEndpoint.sort(compareTo);

    List<LIElement> items = _persistenceEndpoint.map(_makeEndpointRow).toList();

    _ul.children
      ..clear()
      ..addAll(items)
      ..add(_makeNewEndpointRow());

    _sortGroup = new SortableGroup()..installAll(items);

    // Only accept elements from the same section.
    _sortGroup.accept.add(_sortGroup);

    _tmpTextInput.text = _jsonpp.convert(_persistenceEndpoint);
  }

  LIElement _makeNewEndpointRow() {
    LIElement li = new LIElement();

    ButtonElement createButton = new ButtonElement()
      ..text = 'Ny'
      ..onClick.listen((_) {
        model.MessageEndpoint endpoint = new model.MessageEndpoint.empty()
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

  LIElement _makeEndpointRow(model.MessageEndpoint endpoint) {
    LIElement li = new LIElement();

    SpanElement address = new SpanElement()
      ..classes.add('contact-endpoint-address')
      ..text = endpoint.address;
    InputElement addressEditBox = new InputElement(type: 'text');
    editableSpan(address, addressEditBox, _onChange);

    SelectElement typePicker = new SelectElement()
      ..classes.add('contact-endpoint-addresstype')
      ..children.addAll(_addressTypes.map((String type) => new OptionElement(
          data: type, value: type, selected: type == endpoint.type)))
      ..onChange.listen((_) {
        _notifyChange();
      });

    ParagraphElement confidentialLabel = new ParagraphElement()
      ..text = 'Fortrolig';
    CheckboxInputElement confidentialCheckbox = new CheckboxInputElement()
      ..classes.add('contact-endpoint-confidential')
      ..checked = endpoint.confidential
      ..onChange.listen((_) {
        _notifyChange();
      });

    ParagraphElement enabledLabel = new ParagraphElement()..text = 'Aktiv';
    CheckboxInputElement enabledCheckbox = new CheckboxInputElement()
      ..classes.add('contact-endpoint-enabled')
      ..checked = endpoint.enabled
      ..onChange.listen((_) {
        _notifyChange();
      });

    ParagraphElement descriptionLabel = new ParagraphElement()..text = 'note:';
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
      ..children.addAll([
        address,
        addressEditBox,
        typePicker,
        confidentialLabel,
        confidentialCheckbox,
        enabledLabel,
        enabledCheckbox,
        descriptionLabel,
        descriptionInput,
        deleteButton
      ]);
  }

  void _notifyChange() {
    if (_onChange != null) {
      _onChange();
    }
  }

  Future save(int receptionId, int contactId) {
    List<model.MessageEndpoint> foundEndpoints =
        new List<model.MessageEndpoint>();

    int index = 1;
    _ul.children.where((e) => e is LIElement).forEach((item) {
      SpanElement addressSpan = item.querySelector('.contact-endpoint-address');
      SelectElement addressTypePicker =
          item.querySelector('.contact-endpoint-addresstype');
      CheckboxInputElement confidentialBox =
          item.querySelector('.contact-endpoint-confidential');
      CheckboxInputElement enabledBox =
          item.querySelector('.contact-endpoint-enabled');
      TextInputElement descriptionBox =
          item.querySelector('.contact-endpoint-description');

      if (addressSpan != null &&
          addressTypePicker != null &&
          confidentialBox != null &&
          enabledBox != null) {
        model.MessageEndpoint endpoint = new model.MessageEndpoint.empty()
          ..address = addressSpan.text
          ..type = addressTypePicker.selectedOptions.first.value
          ..confidential = confidentialBox.checked
          ..enabled = enabledBox.checked
          ..description = descriptionBox.value;
        foundEndpoints.add(endpoint);
      }
    });

    List<Future> worklist = new List<Future>();

    //Inserts
    for (model.MessageEndpoint endpoint in foundEndpoints) {
      if (!_persistenceEndpoint.any((model.MessageEndpoint e) =>
          e.address == endpoint.address && e.type == endpoint.type)) {
        //Insert Endpoint
        worklist.add(_endpointController
            .create(receptionId, contactId, endpoint)
            .catchError((error, stack) {
          log.severe(
              'Request to create an endpoint failed. receptionId: "${receptionId}", contactId: "${receptionId}", endpoint: "${JSON.encode(endpoint)}" but got: ${error} ${stack}');
          // Rethrow.
          throw error;
        }));
      }
    }

    //Deletes
    for (model.MessageEndpoint endpoint in _persistenceEndpoint) {
      if (!foundEndpoints.any((model.MessageEndpoint e) =>
          e.address == endpoint.address && e.type == endpoint.type)) {
        //Delete Endpoint
        worklist.add(
            _endpointController.remove(endpoint.id).catchError((error, stack) {
          log.severe(
              'Request to delete an endpoint failed. receptionId: "${receptionId}", contactId: "${receptionId}", endpoint: "${JSON.encode(endpoint)}" but got: ${error} ${stack}');
          // Rethrow.
          throw error;
        }));
      }
    }

    //Update
    for (model.MessageEndpoint endpoint in foundEndpoints) {
      if (_persistenceEndpoint.any((model.MessageEndpoint e) =>
          e.address == endpoint.address && e.type == endpoint.type)) {
        //Update Endpoint
        worklist.add(
            _endpointController.update(endpoint).catchError((error, stack) {
          log.severe(
              'Request to update an endpoint failed. receptionId: "${receptionId}", contactId: "${receptionId}", endpoint: "${JSON.encode(endpoint)}" but got: ${error} ${stack}');
          // Rethrow.
          throw error;
        }));
      }
    }
    return Future.wait(worklist);
  }
}
