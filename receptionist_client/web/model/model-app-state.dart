part of model;

enum AppState {
  LOADING,
  ERROR,
  READY
}

class AppClientState {

  Bus<AppState> _stateChange = new Bus<AppState>();
  Stream<AppState> get onStateChange => this._stateChange.stream;

  Iterable<Future> _components = [];

  AppClientState(Iterable<Future> requiredComponents) {
    this._components = requiredComponents;
  }

  Future load() =>
    Future.wait(this._components)
      .then((_) => this.changeState(AppState.READY))
      .catchError((_) => this.changeState(AppState.ERROR));

  void changeState(AppState newState) {
    this._stateChange.fire(newState);
  }

}