library openreception.bus;

import 'dart:async';

/**
 * Type "safe" event bus, using the Dart Stream API.
 *
 * This is basically just a thin wrapper around [StreamController].
 */
class Bus<Type> {
  StreamController _streamController;

  /**
   * Get the [Stream] stream.
   */
  Stream<Type> get stream => _streamController.stream;

  Bus() {
    _streamController = new StreamController.broadcast();
  }

  /**
   * Push a [Type] event to the [Stream].
   */
  void fire(Type event) {
    _streamController.add(event);
  }

  /**
   * Close the [Stream].
   */
  Future close() => _streamController.close();
}
