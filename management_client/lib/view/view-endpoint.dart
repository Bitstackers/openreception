part of management_tool.view;

class EndpointChange {
  final Change type;
  final model.MessageEndpoint endpoint;

  EndpointChange.create(this.endpoint) : type = Change.created;
  EndpointChange.delete(this.endpoint) : type = Change.deleted;
  EndpointChange.update(this.endpoint) : type = Change.updated;

  String toString() => '$type $endpoint';

  int get hashCode => endpoint.toString().hashCode;
}

/**
 * Visual representation of an endpoint collection belonging to a contact.
 */
class Endpoints {
  Logger _log = new Logger('$_libraryName.Endpoints');

  Function onChange;

  final controller.Contact _contactController;

  final DivElement element = new DivElement();
  final DivElement _header = new DivElement()
    ..style.display = 'flex'
    ..style.justifyContent = 'space-between'
    ..style.alignItems = 'flex-end'
    ..style.width = '97%'
    ..style.paddingLeft = '10px';
  final DivElement _buttons = new DivElement();
  bool _validationError = false;
  bool get validationError => _validationError;

  final ButtonElement _addNew = new ButtonElement()
    ..text = 'Indsæt ny tom'
    ..classes.add('create');

  final ButtonElement _foldJson = new ButtonElement()
    ..text = 'Fold sammen'
    ..classes.add('create')
    ..hidden = true;

  final HeadingElement _label = new HeadingElement.h3()
    ..text = 'Beskedadresser'
    ..style.margin = '0px'
    ..style.padding = '0px 0px 4px 0px';

  final TextAreaElement _endpointsInput = new TextAreaElement()
    ..classes.add('wide');

  final ButtonElement _unfoldJson = new ButtonElement()
    ..text = 'Fold ud'
    ..classes.add('create');

  List<model.MessageEndpoint> _originalList = [];

  Endpoints(controller.Contact this._contactController) {
    _buttons.children = [_addNew, _foldJson, _unfoldJson];
    _header.children = [_label, _buttons];
    element.children = [_header, _endpointsInput];
    _observers();
  }

  void _observers() {
    _addNew.onClick.listen((_) {
      final model.MessageEndpoint template = new model.MessageEndpoint.empty()
        ..address = 'eksempel@domæne.dk'
        ..confidential = false
        ..description = 'Kort beskrivelse'
        ..enabled = true
        ..type = model.MessageEndpointType.email;

      if (_unfoldJson.hidden) {
        _endpointsInput.value =
            _jsonpp.convert(endpoints.toList()..add(template));
      } else {
        endpoints = endpoints.toList()..add(template);
      }

      _resizeInput();

      if (onChange != null) {
        onChange();
      }
    });

    _unfoldJson.onClick.listen((_) {
      _unfoldJson.hidden = true;
      _foldJson.hidden = false;
      _endpointsInput.value = _jsonpp.convert(endpoints.toList());
      _resizeInput();
    });

    _foldJson.onClick.listen((_) {
      _foldJson.hidden = true;
      _unfoldJson.hidden = false;
      _endpointsInput.style.height = '';
      _endpointsInput.value = JSON.encode(endpoints.toList());
    });
  }

  void set endpoints(Iterable<model.MessageEndpoint> eps) {
    _originalList = eps.toList(growable: false);
    if (_unfoldJson.hidden) {
      _endpointsInput.value = _jsonpp.convert(_originalList);
    } else {
      _endpointsInput.value = JSON.encode(_originalList);
    }
  }

  Iterable<EndpointChange> get endpointChanges {
    Set<EndpointChange> epcs = new Set();

    Map<int, model.MessageEndpoint> mepIdMap = {};
    _originalList.forEach((model.MessageEndpoint ep) {
      mepIdMap[ep.id] = ep;

      if (!endpoints.any((model.MessageEndpoint chEp) => chEp.id == ep.id)) {
        epcs.add(new EndpointChange.delete(ep));
      }
    });

    endpoints.forEach((ep) {
      if (ep.id == model.MessageEndpoint.noId) {
        epcs.add(new EndpointChange.create(ep));
      } else if (mepIdMap.containsKey(ep.id) && mepIdMap[ep.id] != ep) {
        epcs.add(new EndpointChange.update(ep));
      } else if (!mepIdMap.containsKey(ep.id)) {
        epcs.add(new EndpointChange.delete(ep));
      }
    });

    return epcs;
  }

  Iterable<model.MessageEndpoint> get endpoints =>
      JSON.decode(_endpointsInput.value).map(model.MessageEndpoint.decode);

  void _resizeInput() {
    while (_endpointsInput.client.height < _endpointsInput.scrollHeight) {
      _endpointsInput.style.height = '${_endpointsInput.client.height + 10}px';
    }
  }
}
