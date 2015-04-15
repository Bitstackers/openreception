part of model;

enum AppState {
  LOADING,
  ERROR,
  READY
}

class AppClientState {

  static final Logger log = new Logger ('$libraryName.AppClientState');

  Bus<AppState> _stateChange = new Bus<AppState>();
  Stream<AppState> get onStateChange => this._stateChange.stream;

  AppClientState();

  void addError (Error error, [StackTrace stackTrace]) {
    log.severe(error, stackTrace);

    this.changeState(AppState.ERROR);
  }

  Future load(Iterable<Future> requiredComponents) {
    log.info('Loading ${requiredComponents.length} required components.');

    this.changeState(AppState.LOADING);

    return Future.wait(requiredComponents)
      .then((_) => this.changeState(AppState.READY))
      .catchError((_) => this.changeState(AppState.ERROR));
  }

  void changeState(AppState newState) {
    this._stateChange.fire(newState);
  }

}