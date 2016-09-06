part of orm.view;

class ObjectHistory {
  final UListElement element = new UListElement();

  final DateFormat dateFormat = new DateFormat.yMMMMEEEEd()..add_Hms();

  /**
   *
   */
  ObjectHistory();

  void set commits(Iterable<model.Commit> cs) {
    String changeToString(model.ObjectChange oc) {
      switch (oc.changeType) {
        case model.ChangeType.add:
          return 'Tilføjede uid:${oc.objectType}';
        case model.ChangeType.modify:
          return 'Ændrede uid:${oc.objectType}';
        case model.ChangeType.delete:
          return 'Slettede uid:${oc.objectType}';
      }
    }

    LIElement commitToLi(model.Commit c) {
      final String changeStrings = c.changes.map(changeToString).join(', ');

      final SpanElement label = new SpanElement()
        ..text = dateFormat.format(c.changedAt) +
            ' ' +
            c.authorIdentity +
            ' ' +
            changeStrings;

      return new LIElement()..children = [label];
    }

    element.children = []..addAll(cs.map(commitToLi));
  }
}
