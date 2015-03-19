part of view;

class ReceptionCommands {
  static final ReceptionCommands _singleton = new ReceptionCommands._internal();
  factory ReceptionCommands() => _singleton;

  final UListElement commandList = querySelector('#reception-commands ul');
  final DivElement   root        = querySelector('#reception-commands');

  ReceptionCommands._internal() {
    registerEventListeners();
  }

  void registerEventListeners() {
    // TODO (TL): Stuff....
  }
}
