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

    return Future.forEach(requiredComponents, waitForCompletion)
      .then((_) => this.changeState(AppState.READY))
      .catchError((error, stackTrace) {
        log.severe('Failed to load required component.');
        this.addError(error, stackTrace);

        return new Future.error(error, stackTrace);
      });
  }

  void changeState(AppState newState) {
    this._stateChange.fire(newState);
  }

  Future waitForCompletion(Future f) {
    print (f);

    return f;
  }

}