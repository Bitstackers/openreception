part of management_tool.view;

class DistributionListChange {
  final Change type;
  final model.DistributionListEntry entry;

  DistributionListChange.add(this.entry) : type = Change.created;
  DistributionListChange.remove(this.entry) : type = Change.deleted;
}

/**
 *
 */
class DistributionList {
  final Logger _log = new Logger('$_libraryName.DistributionList');

  final DivElement element = new DivElement();
  bool _validationError = false;
  bool get validationError => _validationError;

  model.Contact owner = new model.Contact.empty();
  String receptionName = '';

  final ButtonElement _addNew = new ButtonElement()
    ..text = 'Indsæt ny tom'
    ..classes.add('create');

  Function onChange;

  final TextAreaElement _dlistInput = new TextAreaElement()
    ..style.height = '15em'
    ..classes.add('wide');

  model.DistributionList _originalList = new model.DistributionList.empty();
  /**
     *
     */
  DistributionList() {
    element.children = [_addNew, _dlistInput];
    _observers();
  }

  /**
   *
   */
  void _observers() {
    _addNew.onClick.listen((_) {
      final model.DistributionListEntry dle =
          new model.DistributionListEntry.empty()
            ..contactID = owner.ID
            ..contactName = owner.fullName
            ..receptionID = owner.receptionID
            ..receptionName = receptionName
            ..role = model.Role.TO;

      distributionList = distributionList..add(dle);

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
  }

  /**
   *
   */
  void set distributionList(model.DistributionList dlist) {
    _originalList = dlist;
    _dlistInput.value = _jsonpp.convert(_originalList);
  }

  /**
   *
   */
  Iterable<DistributionListChange> get distributionListChanges {
    Set<DistributionListChange> epcs = new Set();

    Map<int, model.DistributionListEntry> mepIdMap = {};
    _originalList.forEach((model.DistributionListEntry dle) {
      mepIdMap[dle.id] = dle;

      if (!distributionList
          .any((model.DistributionListEntry chDle) => chDle.id == dle.id)) {
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

  /**
   *
   */
  model.DistributionList get distributionList =>
      model.DistributionList.decode(JSON.decode(_dlistInput.value));
}
