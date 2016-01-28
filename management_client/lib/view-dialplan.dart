part of management_tool.view;

class DialplanView {
  set dialplan(ORModel.ReceptionDialplan rdp) {
    _note.text = rdp.note;
    _openEntries.children = []..addAll(rdp.open.map(hourActionTemplate));
    _active.text = rdp.active.toString();
    _closedEntries.children = []
      ..addAll(rdp.defaultActions.map(actionTemplate));
    _extraExtensions.children = []
      ..addAll(rdp.extraExtensions.map(extensionTemplate));
  }

  DialplanView() {
    element.children = [
      new HeadingElement.h3()..text = 'Active',
      _active,
      new HeadingElement.h3()..text = 'Note',
      _note,
      new HeadingElement.h3()..text = 'Opening hours',
      _openEntries,
      new HeadingElement.h3()..text = 'When closed',
      _closedEntries,
      new HeadingElement.h3()..text = 'Extra extensions',
      _extraExtensions
    ];
  }

  final DivElement element = new DivElement()
    ..classes = ['dialplan-view-widget'];
  final ParagraphElement _note = new ParagraphElement()..text = '..';
  final ParagraphElement _active = new ParagraphElement()..text = '..';
  final UListElement _closedEntries = new UListElement();
  final UListElement _openEntries = new UListElement();
  final UListElement _extraExtensions = new UListElement();
}
