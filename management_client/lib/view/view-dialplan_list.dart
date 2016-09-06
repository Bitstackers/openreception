part of orm.view;

class DialplanList {
  set menus(Iterable<model.ReceptionDialplan> dialplans) {
    LIElement template(model.ReceptionDialplan rdp) =>
        new DialplanListItem(rdp).element;

    element.children = new List<Element>.from(
        [new AnchorElement(href: '/dialplan/create')..text = 'Create new'])
      ..addAll(dialplans.map(template));
  }

  final UListElement element = new UListElement()
    ..classes = ['ivr-listing-widget'];
}

class DialplanListItem {
  DialplanListItem(model.ReceptionDialplan rdp) {
    element.children = [
      new AnchorElement(href: '/dialplan/${rdp.extension}')
        ..text = rdp.extension.toString()
    ];
  }

  final LIElement element = new LIElement();
}
