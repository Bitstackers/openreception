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
  Logger _log = new Logger('$_libraryName.DistributionList');

  final DivElement element = new DivElement();
  bool _validationError = false;
  bool get validationError => _validationError;

  Function onChange;

  final TextAreaElement _dlistInput = new TextAreaElement()
    ..classes.add('wide');

  model.DistributionList _originalList = new model.DistributionList.empty();
  /**
     *
     */
  DistributionList() {
    element.children = [_dlistInput];
    _observers();
  }

  /**
   *
   */
  void _observers() {
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
