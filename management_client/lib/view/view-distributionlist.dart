part of management_tool.view;

class DistributionListChange {
  final Change type;
  final model.DistributionListEntry entry;

  DistributionListChange.add(this.entry) : type = Change.created;
  DistributionListChange.remove(this.entry) : type = Change.deleted;
}

class DistributionList {
  final Logger _log = new Logger('$_libraryName.DistributionList');

  Function onChange;

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

  model.Contact owner = new model.Contact.empty();
  String receptionName = '';

  final ButtonElement _addNew = new ButtonElement()
    ..text = 'Indsæt ny tom'
    ..classes.add('create');

  final ButtonElement _foldJson = new ButtonElement()
    ..text = 'Fold sammen'
    ..classes.add('create')
    ..hidden = true;

  final HeadingElement _label = new HeadingElement.h3()
    ..text = 'Distributionsliste'
    ..style.margin = '0px'
    ..style.padding = '0px 0px 4px 0px';

  final TextAreaElement _dlistInput = new TextAreaElement()..classes.add('wide');

  final ButtonElement _unfoldJson = new ButtonElement()
    ..text = 'Fold ud'
    ..classes.add('create');

  model.DistributionList _originalList = new model.DistributionList.empty();

  DistributionList() {
    _buttons.children = [_addNew, _foldJson, _unfoldJson];
    _header.children = [_label, _buttons];
    element.children = [_header, _dlistInput];
    _observers();
  }

  void _observers() {
    _addNew.onClick.listen((_) {
      final model.DistributionListEntry dle = new model.DistributionListEntry.empty()
        ..contactID = owner.ID
        ..contactName = owner.fullName
        ..receptionID = owner.receptionID
        ..receptionName = receptionName
        ..role = model.Role.TO;

      if (_unfoldJson.hidden) {
        _dlistInput.value = _jsonpp.convert(distributionList.toList()..add(dle));
      } else {
        distributionList = distributionList..add(dle);
      }

      _resizeInput();

      if (onChange != null) {
        onChange();
      }
    });

    _dlistInput.onInput.listen((_) {
      _validationError = false;
      _dlistInput.classes.toggle('error', false);
      try {
        final dlist = distributionList;

        ///TODO: Validate endpoints
      } on FormatException {
        _validationError = true;
        _dlistInput.classes.toggle('error', true);
      }

      if (onChange != null) {
        onChange();
      }
    });

    _unfoldJson.onClick.listen((_) {
      _unfoldJson.hidden = true;
      _foldJson.hidden = false;
      _dlistInput.value = _jsonpp.convert(distributionList.toList());
      _resizeInput();
    });

    _foldJson.onClick.listen((_) {
      _foldJson.hidden = true;
      _unfoldJson.hidden = false;
      _dlistInput.style.height = '';
      _dlistInput.value = JSON.encode(distributionList.toList());
    });
  }

  void set distributionList(model.DistributionList dlist) {
    _originalList = dlist;
    if (_unfoldJson.hidden) {
      _dlistInput.value = _jsonpp.convert(dlist);
    } else {
      _dlistInput.value = JSON.encode(dlist.toList());
    }
  }

  Iterable<DistributionListChange> get distributionListChanges {
    Set<DistributionListChange> epcs = new Set();

    Map<int, model.DistributionListEntry> mepIdMap = {};
    _originalList.forEach((model.DistributionListEntry dle) {
      mepIdMap[dle.id] = dle;

      if (!distributionList.any((model.DistributionListEntry chDle) => chDle.id == dle.id)) {
        epcs.add(new DistributionListChange.remove(dle));
      }
    });

    distributionList.forEach((dle) {
      if (dle.id == model.DistributionListEntry.noId) {
        epcs.add(new DistributionListChange.add(dle));
      } else if (!mepIdMap.containsKey(dle.id)) {
        epcs.add(new DistributionListChange.remove(dle));
      }
    });

    return epcs;
  }

  model.DistributionList get distributionList =>
      model.DistributionList.decode(JSON.decode(_dlistInput.value));

  void _resizeInput() {
    while (_dlistInput.client.height < _dlistInput.scrollHeight) {
      _dlistInput.style.height = '${_dlistInput.client.height + 10}px';
    }
  }
}
