part of or_test_fw;

class NoAvailable implements Exception {}
class NotAquired implements Exception {}

abstract class Pool<T> {

  static const String className = '$libraryName.CustomerPool';

  Logger log = new Logger(Pool.className);

  Queue<T> available = new Queue();
  Queue<T> busy      = new Queue();

  dynamic onAquire  = (T element) => null;
  dynamic onRelease = (T element) => null;

  Pool (Iterable<T> element) {
    this.available.addAll(element);
  }

  T aquire() {
    if (this.available.isEmpty) {
      log.shout('No objects available');
      throw new NoAvailable();
    }

    T aquired = this.available.removeFirst();
    this.busy.add(aquired);

    log.finest('Aquired pool object $aquired');

    onAquire (aquired);
    return aquired;
  }

  void release(T element) {
    if (!this.busy.contains(element)) {
      log.shout('Object is not aquired');
      throw new NotAquired();
    }

    log.finest('Released pool object $element');

    this.busy.remove(element);
    this.available.add(element);
    onRelease(element);
  }
}
