part of view;

abstract class Icon {

  static Element get _baseElement => document.createElement('i')..classes.add('fa');

  static Element get Dialpad     => _baseElement..classes.add('fa-th');
  static Element get Info        => _baseElement..classes.add('fa-info');
  static Element get Exclamation => _baseElement..classes.add('fa-exclamation');
  static Element get Alert       => _baseElement..classes.add('fa-exclamation-triangle');
  static Element get Globe       => _baseElement..classes.add('fa-globe');
  static Element get Message     => _baseElement..classes.add('fa-comment');
  static Element get Phone       => _baseElement..classes.add('fa-phone');
  static Element get OrderedList => _baseElement..classes.add('fa-list-ol');
  static Element get Contacts    => _baseElement..classes.add('fa-users');
  static Element get Filter      => _baseElement..classes.add('fa-filter');
  static Element get Edit        => _baseElement..classes.add('fa-pencil');

  static Element get Enqueued    => Icon.Clock;
  static Element get Saved       => Icon.Save;
  static Element get Sent        => Icon.Send;
  static Element get Unknown     => _baseElement..classes.add('fa-question');
  static Element get Plus        => _baseElement..classes.add('fa-plus');
  static Element get Gavel       => _baseElement..classes.add('fa-gavel');
  static Element get Bank        => _baseElement..classes.add('fa-bank');
  static Element get Bookmark    => _baseElement..classes.add('fa-bookmark');
  static Element get Building    => _baseElement..classes.add('fa-building');

  static Element get Calendar    => _baseElement..classes.add('fa-calendar');
  static Element get Product     => _baseElement..classes.add('fa-gears');
  static Element get Music       => _baseElement..classes.add('fa-music');
  static Element get Money       => _baseElement..classes.add('fa-money');

  static Element get Clock       => _baseElement..classes.add('fa-clock-o');
  static Element get MapMarker   => _baseElement..classes.add('fa-map-marker');
  static Element get Location    => _baseElement..classes.add('fa-location-arrow');
  static Element get Archive     => _baseElement..classes.add('fa-archive');
  static Element get Email       => _baseElement..classes.add('fa-envelope');

  static Element get Previous    => _baseElement..classes.add('fa-chevron-left');
  static Element get Next        => _baseElement..classes.add('fa-chevron-right');

  static Element get Print       => _baseElement..classes.add('fa-print');
  static Element get Send        => _baseElement..classes.add('fa-send');
  static Element get Save        => _baseElement..classes.add('fa-save');

  static Element get Pause       => _baseElement..classes.add('fa-pause');
  static Element get Busy        => _baseElement..classes.add('fa-clock-o');
  static Element get Idle        => _baseElement..classes.add('fa-play');
}
