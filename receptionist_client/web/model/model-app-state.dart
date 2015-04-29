/*                  This file is part of OpenReception
                   Copyright (C) 2015-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

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
