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
  //List<String> get _addressTypes => model.MessageEndpointType.types;

  Logger _log = new Logger('$_libraryName.Endpoints');

  final controller.Contact _contactController;
  final controller.Endpoint _endpointController;

  final DivElement element = new DivElement();
  bool _validationError = false;
  bool get validationError => _validationError;
  Function onChange;

  final TextAreaElement _endpointsInput = new TextAreaElement()
    ..classes.add('wide');

  List<model.MessageEndpoint> _originalList = [];
  /**
   *
   */
  Endpoints(
      controller.Contact this._contactController, this._endpointController) {
    element.children = [_endpointsInput];
    _observers();
  }

  /**
   *
   */
  void _observers() {
    _endpointsInput.onInput.listen((_) {
      _validationError = false;
      _endpointsInput.classes.toggle('error', false);
      try {
        final eps = endpoints;

        ///TODO: Validate endpoints
      } on FormatException {
        _validationError = true;
        _endpointsInput.classes.toggle('error', true);
      }

      if (onChange != null) {
        onChange();
      }
    });
  }

  /**
   *
   */
  void set endpoints(Iterable<model.MessageEndpoint> eps) {
    _originalList = eps.toList(growable: false);
    _endpointsInput.value = _jsonpp.convert(_originalList);
  }

  /**
   *
   */
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

  /**
   *
   */
  Iterable<model.MessageEndpoint> get endpoints =>
      JSON.decode(_endpointsInput.value).map(model.MessageEndpoint.decode);
}
