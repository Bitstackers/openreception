library or_test_fw.on_demand_handlers;

import 'dart:async';
import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_route/shelf_route.dart' as shelf_route;

import 'or_test_fw.dart' as test_fw;

const String libraryName = 'or_test_fw.on_demand_handlers';
final Logger log = new Logger (libraryName);

class Receptionist {

  final test_fw.ReceptionistPool _receptionistPool;

  Receptionist(this._receptionistPool);

  int get _availableCount => _receptionistPool.available.length;
  int get _totalCount => _receptionistPool.elements.length;

  int _ridParameter (shelf.Request request) =>
    int.parse(shelf_route.getPathParameter(request, 'rid'));

  /**
   *
   */
  Future<shelf.Response> aquire(shelf.Request request) {
    test_fw.Receptionist r;

    try {
      r = _receptionistPool.aquire();
    }
    on test_fw.NoAvailable {

      return new Future.value(new shelf.Response.notFound
        ('No available receptionists. '
            '${_availableCount} available of ${_totalCount}'));
    }
    catch (error, stackTrace) {
      log.severe(error, stackTrace);
      return new
        Future.value(new shelf.Response.internalServerError(body : error.toString()));
    }

    log.finest ('Allocated receptionist $r');
    log.finest ('Current usage: ${_availableCount} available of ${_totalCount}');

    return r.initialize().then((_) => new shelf.Response.ok (JSON.encode(r)));
  }

  /**
   *
   */
  Future<shelf.Response> release (shelf.Request request) {
    int receptionistHandle = _ridParameter(request);

    test_fw.Receptionist r;

    try {
      r = _receptionistPool.busy.firstWhere((test_fw.Receptionist rc) =>
        rc.hashCode == receptionistHandle);
      _receptionistPool.release(r);
    }
    on test_fw.NotAquired {
      return new Future.value(new shelf.Response
        (400, body : 'Not previously aquired'));
    }
    catch (error, stackTrace) {
      log.severe(error, stackTrace);
      return new
        Future.value
          (new shelf.Response.internalServerError(body : error.toString()));
    }

    log.finest ('Deallocated receptionist $r');
    log.finest ('Current usage: ${_availableCount} available of ${_totalCount}');

    return r.teardown().then((_) =>
      new shelf.Response.ok (JSON.encode({'status' : 'ok'})));
  }

  /**
   *
   */
  shelf.Response get (shelf.Request request) {
    int receptionistHandle = _ridParameter(request);

    test_fw.Receptionist r;

    try {
      r = _receptionistPool.elements.firstWhere((test_fw.Receptionist rc) =>
        rc.hashCode == receptionistHandle);
    }
    catch (error, stackTrace) {
      log.severe(error, stackTrace);
      return new shelf.Response.internalServerError(body : error.toString());
    }

    Map returnMap = r.toJson()
      ..addAll({'aquired': _receptionistPool.busy.contains(r)});

    return new shelf.Response.ok (JSON.encode(returnMap));
  }
}

class Customer {

  final test_fw.CustomerPool _customerPool;

  Customer(this._customerPool);

  int get _availableCount => _customerPool.available.length;
  int get _totalCount => _customerPool.elements.length;

  int _cidParameter (shelf.Request request) =>
    int.parse(shelf_route.getPathParameter(request, 'cid'));

  String _extensionParameter (shelf.Request request) =>
    shelf_route.getPathParameter(request, 'extension');

  /**
   *
   */
  Future<shelf.Response> aquire(shelf.Request request) {
    test_fw.Customer c;

    try {
      c = _customerPool.aquire();
    }
    on test_fw.NoAvailable {

      return new Future.value(new shelf.Response.notFound
        ('No available customers. '
            '${_availableCount} available of ${_totalCount}'));
    }
    catch (error, stackTrace) {
      log.severe(error, stackTrace);
      return new
        Future.value(new shelf.Response.internalServerError(body : error.toString()));
    }

    log.finest ('Allocated customer $c');
    log.finest (c.toJson());
    log.finest ('Current usage: ${_availableCount} available of ${_totalCount}');

    return c.initialize()
        .then((_) => c.autoAnswer(false))
        .then((_) => new shelf.Response.ok (JSON.encode(c)));
  }

  /**
   *
   */
  Future<shelf.Response> release (shelf.Request request) {
    int customerHandle = _cidParameter(request);

    test_fw.Customer c;

    try {
      c = _customerPool.busy.firstWhere((test_fw.Customer cu) =>
        cu.hashCode == customerHandle);
      _customerPool.release(c);
    }
    on test_fw.NotAquired {
      return new Future.value(new shelf.Response
        (400, body : 'Not previously aquired'));
    }
    catch (error, stackTrace) {
      log.severe(error, stackTrace);
      return new
        Future.value
          (new shelf.Response.internalServerError(body : error.toString()));
    }

    log.finest ('Deallocated customer $c');
    log.finest ('Current usage: ${_availableCount} available of ${_totalCount}');

    return c.teardown().then((_) =>
      new shelf.Response.ok (JSON.encode({'status' : 'ok'})));
  }

  /**
   *
   */
  shelf.Response get (shelf.Request request) {
    int customerHandle = _cidParameter(request);

    test_fw.Customer c;

    try {
      c = _customerPool.busy.firstWhere((test_fw.Customer cu) =>
        cu.hashCode == customerHandle);
    }
    catch (error, stackTrace) {
      log.severe(error, stackTrace);
      return new shelf.Response.internalServerError(body : error.toString());
    }

    return new shelf.Response.ok (JSON.encode(c));
  }

  /**
   *
   */
  Future<shelf.Response> dial (shelf.Request request) {
    int customerHandle = _cidParameter(request);
    String extension = _extensionParameter(request);

    test_fw.Customer c;

    try {
      c = _customerPool.busy.firstWhere((test_fw.Customer cu) =>
        cu.hashCode == customerHandle);
    }
    catch (error, stackTrace) {
      log.severe(error, stackTrace);
      return new Future.value
        (new shelf.Response.internalServerError(body : error.toString()));
    }

    return c.dial(extension).then((_) =>
        new shelf.Response.ok (JSON.encode({'status' : 'ok'})));
  }

  /**
   *
   */
  Future<shelf.Response> pickup (shelf.Request request) {
    int customerHandle = _cidParameter(request);

    test_fw.Customer c;

    try {
      c = _customerPool.busy.firstWhere((test_fw.Customer cu) =>
        cu.hashCode == customerHandle);
    }
    catch (error, stackTrace) {
      log.severe(error, stackTrace);
      return new Future.value
        (new shelf.Response.internalServerError(body : error.toString()));
    }

    return c.pickupCall().then((_) =>
        new shelf.Response.ok (JSON.encode({'status' : 'ok'})));
  }


  /**
   *
   */
  Future<shelf.Response> hangupAll (shelf.Request request) {
    int receptionistHandle = _cidParameter(request);

    test_fw.Customer c;

    try {
      c = _customerPool.busy.firstWhere((test_fw.Customer cu) =>
        cu.hashCode == receptionistHandle);
    }
    catch (error, stackTrace) {
      log.severe(error, stackTrace);
      return new Future.value
        (new shelf.Response.internalServerError(body : error.toString()));
    }

    return c.hangupAll().then((_) =>
      new shelf.Response.ok (JSON.encode({'status' : 'ok'})));
  }
}