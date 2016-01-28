part of management_tool.view;

class DialplanList {
  set menus(Iterable<ORModel.ReceptionDialplan> dialplans) {
    LIElement template(ORModel.ReceptionDialplan rdp) =>
        new DialplanListItem(rdp).element;

    element.children = [
      new AnchorElement(href: '/dialplan/create')..text = 'Create new'
    ]..addAll(dialplans.map(template));
  }

  final UListElement element = new UListElement()
    ..classes = ['ivr-listing-widget'];
}

class DialplanListItem {
  DialplanListItem(ORModel.ReceptionDialplan rdp) {
    element.children = [
      new AnchorElement(href: '/dialplan/${rdp.extension}')
        ..text = rdp.extension.toString()
    ];
  }

  final LIElement element = new LIElement();
}
