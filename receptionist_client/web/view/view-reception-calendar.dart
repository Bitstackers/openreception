part of view;

class ReceptionCalendar {
  static final ReceptionCalendar _singleton = new ReceptionCalendar._internal();
  factory ReceptionCalendar() => _singleton;

  final Bus<String>  bus       = new Bus<String>();
  final UListElement eventList = querySelector('#reception-calendar ul');
  final DivElement   root      = querySelector('#reception-calendar');

  ReceptionCalendar._internal() {
    registerEventListeners();
  }

  Stream<String> get onEdit => bus.stream;

  void registerEventListeners() {
    eventList.onClick.listen((_) => bus.fire('Ret event fra ReceptionCalendar'));
  }
}
