part of view;

class AgentInfo {
  static final AgentInfo _singleton = new AgentInfo._internal();
  factory AgentInfo() => _singleton;

  final DivElement root = querySelector('#agent-info');

  AgentInfo._internal() {
    registerEventListeners();
  }

  void registerEventListeners() {
    // TODO (TL): Stuff...
  }
}
