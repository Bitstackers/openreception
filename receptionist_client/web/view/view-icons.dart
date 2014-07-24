part of view;

abstract class Icon {
  
  
  static Element get Globe => new DocumentFragment.html ('''<i class=\"fa fa-globe"></i>''').children.first;
  static Element get Phone => new DocumentFragment.html ('''<i class=\"fa fa-phone"></i>''').children.first;
  static Element get OrderedList => new DocumentFragment.html ('''<i class=\"fa fa-list-ol"></i>''').children.first;
  static Element get Contacts => new DocumentFragment.html ('''<i class=\"fa fa-users"></i>''').children.first;
  
  static Element get Calendar => new DocumentFragment.html ('''<i class=\"fa fa-calendar"></i>''').children.first;
  static Element get Product => new DocumentFragment.html ('''<i class=\"fa fa-gears"></i>''').children.first;
  static Element get Music => new DocumentFragment.html ('''<i class=\"fa fa-music"></i>''').children.first;
  static Element get Money => new DocumentFragment.html ('''<i class=\"fa fa-money"></i>''').children.first;
  
  static Element get Clock => new DocumentFragment.html ('''<i class=\"fa fa-clock-o"></i>''').children.first;
  static Element get MapMarker => new DocumentFragment.html ('''<i class=\"fa fa-map-marker"></i>''').children.first;
  static Element get Location => new DocumentFragment.html ('''<i class=\"fa fa-location-arrow"></i>''').children.first;
  static Element get Archive => new DocumentFragment.html ('''<i class=\"fa fa-archive"></i>''').children.first;
  
  static Element get Previous => new DocumentFragment.html ('''<i class=\"fa fa-chevron-left"></i>''').children.first;
  static Element get Next => new DocumentFragment.html ('''<i class=\"fa fa-chevron-right"></i>''').children.first;

  static Element get Print => new DocumentFragment.html ('''<i class=\"fa fa-print"></i>''').children.first;
  static Element get Send => new DocumentFragment.html ('''<i class=\"fa fa-send"></i>''').children.first;
  static Element get Save => new DocumentFragment.html ('''<i class=\"fa fa-save"></i>''').children.first;
}