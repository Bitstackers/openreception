part of view;

class ReceptionCalendar {
  static final ReceptionCalendar _singleton = new ReceptionCalendar._internal();
  factory ReceptionCalendar() => _singleton;

  UListElement ul = querySelector('#reception-calendar ul');

  Bus<String> bus = new Bus<String>();

  ReceptionCalendar._internal() {
    registerEventListeners();
  }

  Stream<String> get onEdit => bus.stream;

  void registerEventListeners() {
    ul.onClick.listen((_) => bus.fire('Ret event fra ReceptionCalendar'));
  }
}
