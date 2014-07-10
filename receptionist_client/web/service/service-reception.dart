/*                     This file is part of Bob
                   Copyright (C) 2012-, AdaHeads K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of service;

/**
 * Protocol definitions.
 */
abstract class ReceptionResource {
  static final String _reception = '/reception';
  static final String _calendar  = '/calendar';
  static final String _event     = '/event';

  static String single(int receptionID) {
    return '${_reception}/${receptionID}';
  }

  static String calendar(int receptionID) {
    return '${_reception}/${receptionID}${_calendar}';
  }
  
  static String calendarEvent(int receptionID, int eventID) {
    return '${_reception}/${receptionID}${_calendar}${_event}/${eventID}';
  }

}

abstract class Reception {

  static const String className = '${libraryName}.Reception';

  /**
   * Retrieves the extraData of a reception from the supplied resource.
   */
  static Future<String> extraData (Uri resource) {
    const String context = '${className}.calendarEventCreate';

    final Completer<String> completer = new Completer<String>();

    HttpRequest request;
    
    request = new HttpRequest()
        ..open(GET, resource.toString())
        ..onLoad.listen((val) {
          switch (request.status) {
            case 200:
              completer.complete(request.responseText);
              break;

            case 400:
              completer.completeError(_badRequest('Resource $resource'));
              break;

            case 404:
              completer.completeError(_notFound('Resource $resource'));
              break;

            case 500:
              completer.completeError(_serverError('Resource $resource'));
              break;
            default:
              completer.completeError(new UndefinedError('Status (${request.status}): Resource $resource'));
          }
        })
        ..onError.listen((e) {
          log.errorContext('Status (${request.status}): Resource $resource', context);
          completer.completeError(e);
        })
        ..send();

    return completer.future;
  }

  /**
   * Retrieves a single calendar event associated with a reception.
   */
  static Future<model.CalendarEvent> calendarEvent(int receptionID, int eventID) {

    const String context = '${className}.calendar';

    final String base = configuration.receptionBaseUrl.toString();
    final Completer<model.CalendarEventList> completer = new Completer<model.CalendarEventList>();
    final List<String> fragments = new List<String>();
    final String path = ReceptionResource.calendarEvent(receptionID, eventID);

    HttpRequest request;
    String url;

    fragments.add('token=${configuration.token}');
    url = _buildUrl(base, path, fragments);

    request = new HttpRequest()
        ..open(GET, url)
        ..onLoad.listen((val) {
          switch (request.status) {
            case 200:
              completer.complete(new model.CalendarEvent.fromJson(JSON.decode(request.responseText)['event']));
              break;

            case 400:
              completer.completeError(_badRequest('Resource ${base}${path}'));
              break;

            case 404:
              completer.completeError(_notFound('Resource ${base}${path}'));
              break;

            case 500:
              completer.completeError(_serverError('Resource ${base}${path}'));
              break;
            default:
              completer.completeError(new UndefinedError('Status (${request.status}): Resource ${base}${path}'));
          }
        })
        ..onError.listen((e) {
          log.errorContext('Status (${request.status}): Resource ${base}${path}', context);
          completer.completeError(e);
        })
        ..send();

    return completer.future;
  }
  
  /**
   * Stores a new [CalendarEvent] on the server.
   */
  static Future calendarEventCreate(model.CalendarEvent event) {

    const String context = '${className}.calendarEventCreate';

    final String base = configuration.receptionBaseUrl.toString();
    final Completer completer = new Completer();
    final List<String> fragments = new List<String>();
    final String path = '/reception/${event.receptionID}/calendar/event';

    HttpRequest request;
    String url;

    fragments.add('token=${configuration.token}');
    url = _buildUrl(base, path, fragments);

    /* Assemble the initial content for the message. */
    Map payload = {'event' : event.toJson()};

    /*
     * Now we are ready to send the request to the server.
     */

    log.debugContext('url: ${url} - payload: ${payload}', context);

    request = new HttpRequest()
        ..open(POST, url)
        ..setRequestHeader('Content-Type', 'application/x-www-form-urlencoded')
        ..onLoad.listen((_) {
          switch (request.status) {
            case 200:
              completer.complete ();
              break;
            case 400:
              completer.completeError(_badRequest('Resource ${base}${path}'));
              break;

            case 404:
              completer.completeError(_notFound('Resource ${base}${path}'));
              break;

            case 500:
              completer.completeError(_serverError('Resource ${base}${path}'));
              break;
            default:
              completer.completeError(new UndefinedError('Status (${request.status}): Resource ${base}${path}'));
          }
        })
        ..onError.listen((e) {
          log.errorContext('Status (${request.status}): Resource ${base}${path}', context);
          completer.completeError(e);
        })
        ..send(JSON.encode(payload));

    return completer.future;
  }

  /**
   * Stores a updated [CalendarEvent] on the server.
   */
  static Future calendarEventUpdate(model.CalendarEvent event) {

    const String context = '${className}.calendarEventUpdate';

    final String base = configuration.receptionBaseUrl.toString();
    final Completer completer = new Completer();
    final List<String> fragments = new List<String>();
    final String path = '/reception/${event.receptionID}/calendar/event/${event.ID}';

    HttpRequest request;
    String url;

    fragments.add('token=${configuration.token}');
    url = _buildUrl(base, path, fragments);

    /* Assemble the initial content for the message. */
    Map payload = {'event' : event.toJson()};

    /*
     * Now we are ready to send the request to the server.
     */

    log.debugContext('$PUT : ${url} - payload: ${payload}', context);

    request = new HttpRequest()
        ..open('PUT', url)
        //..setRequestHeader('Content-Type', 'application/json')
        ..onLoad.listen((_) {
          switch (request.status) {
            case 200:
              completer.complete ();
              break;
            case 400:
              completer.completeError(_badRequest('Resource ${base}${path}'));
              break;

            case 404:
              completer.completeError(_notFound('Resource ${base}${path}'));
              break;

            case 500:
              completer.completeError(_serverError('Resource ${base}${path}'));
              break;
            default:
              completer.completeError(new UndefinedError('Status (${request.status}): Resource ${base}${path}'));
          }
        })
        ..onError.listen((e) {
          log.errorContext('Status (${request.status}): Resource ${base}${path}', context);
          completer.completeError(e);
        })
        ..send(JSON.encode(payload));

    return completer.future;
  }

  /**
   * Deletes a [CalendarEvent] from the server.
   */
  static Future calendarEventDelete(model.CalendarEvent event) {

    const String context = '${className}.calendarEventDelete';

    final String base = configuration.receptionBaseUrl.toString();
    final Completer completer = new Completer();
    final List<String> fragments = new List<String>();
    final String path = '/reception/${event.receptionID}/calendar/event/${event.ID}';

    HttpRequest request;
    String url;

    fragments.add('token=${configuration.token}');
    url = _buildUrl(base, path, fragments);

    /* Assemble the initial content for the message. */
    Map payload = {'event' : event.toJson()};

    /*
     * Now we are ready to send the request to the server.
     */

    log.debugContext('$PUT : ${url} - payload: ${payload}', context);

    request = new HttpRequest()
        ..open('DELETE', url)
        //..setRequestHeader('Content-Type', 'application/json')
        ..onLoad.listen((_) {
          switch (request.status) {
            case 200:
              completer.complete ();
              break;
            case 400:
              completer.completeError(_badRequest('Resource ${base}${path}'));
              break;

            case 404:
              completer.completeError(_notFound('Resource ${base}${path}'));
              break;

            case 500:
              completer.completeError(_serverError('Resource ${base}${path}'));
              break;
            default:
              completer.completeError(new UndefinedError('Status (${request.status}): Resource ${base}${path}'));
          }
        })
        ..onError.listen((e) {
          log.errorContext('Status (${request.status}): Resource ${base}${path}', context);
          completer.completeError(e);
        })
        ..send(JSON.encode(payload));

    return completer.future;
  }
  
  /**
   * Get the [id] reception JSON data.
   *
   * Completes with
   *  On success   : [Response] object with status OK (data)
   *  On not found : [Response] object with status NOTFOUND (no data)
   *  on error     : [Response] object with status ERROR or CRITICALERROR (data)
   */
  static Future<model.Reception> get(int id) {

    const String context = '${className}.get';
    assert(id != null);

    final String base = configuration.receptionBaseUrl.toString(); //configuration.aliceBaseUrl.toString();
    final Completer<model.Reception> completer = new Completer<model.Reception>();
    final List<String> fragments = new List<String>();
    final String path = '${ReceptionResource.single(id)}';
    HttpRequest request;
    String url;

    fragments.add('token=${configuration.token}');
    url = _buildUrl(base, path, fragments);

    request = new HttpRequest()
        ..open(GET, url)
        ..onLoad.listen((val) {
          switch (request.status) {
            case 200:
              completer.complete(new model.Reception.fromJson(JSON.decode(request.responseText)));
              break;

            case 400:
              completer.completeError(_badRequest('Resource ${base}${path}'));
              break;

            case 404:
              completer.completeError(_notFound('Resource ${base}${path}'));
              break;

            case 500:
              completer.completeError(_serverError('Resource ${base}${path}'));
              break;
            default:
              completer.completeError(new UndefinedError('Status (${request.status}): Resource ${base}${path}'));
          }
        })
        ..onError.listen((e) {
          log.errorContext('Status (${request.status}): Resource ${base}${path}', context);
          completer.completeError(e);
        })
        ..send();

    return completer.future;
  }

  /**
 * Get the reception calendar JSON data.
 *
 * Completes with
 *  On success : [Response] object with status OK (data)
 *  on error   : [Response] object with status ERROR or CRITICALERROR (data)
 */
  static Future<model.CalendarEventList> calendar(int receptionID) {

    const String context = '${className}.calendar';

    final String base = configuration.receptionBaseUrl.toString();
    final Completer<model.CalendarEventList> completer = new Completer<model.CalendarEventList>();
    final List<String> fragments = new List<String>();
    final String path = ReceptionResource.calendar(receptionID);

    HttpRequest request;
    String url;

    fragments.add('token=${configuration.token}');
    url = _buildUrl(base, path, fragments);

    request = new HttpRequest()
        ..open(GET, url)
        ..onLoad.listen((val) {
          switch (request.status) {
            case 200:
              completer.complete(new model.CalendarEventList.fromMap(JSON.decode(request.responseText)['CalendarEvents']));
              break;

            case 400:
              completer.completeError(_badRequest('Resource ${base}${path}'));
              break;

            case 404:
              completer.completeError(_notFound('Resource ${base}${path}'));
              break;

            case 500:
              completer.completeError(_serverError('Resource ${base}${path}'));
              break;
            default:
              completer.completeError(new UndefinedError('Status (${request.status}): Resource ${base}${path}'));
          }
        })
        ..onError.listen((e) {
          log.errorContext('Status (${request.status}): Resource ${base}${path}', context);
          completer.completeError(e);
        })
        ..send();

    return completer.future;
  }

  /**
 * Get the reception list JSON data.
 *
 * Completes with
 *  On success : [Response] object with status OK (data)
 *  on error   : [Response] object with status ERROR or CRITICALERROR (data)
 */
  static Future<model.ReceptionList> list() {

    const String context = '${className}.list';

    final String base = configuration.receptionBaseUrl.toString();
    final Completer<model.ReceptionList> completer = new Completer<model.ReceptionList>();
    final List<String> fragments = new List<String>();
    final String path = '/reception';
    HttpRequest request;
    String url;

    fragments.add('token=${configuration.token}');
    url = _buildUrl(base, path, fragments);

    request = new HttpRequest()
        ..open(GET, url)
        ..onLoad.listen((val) {
          switch (request.status) {
            case 200:
              completer.complete(new model.ReceptionList.fromList(JSON.decode(request.responseText)['reception_list']));
              break;

            case 400:
              completer.completeError(_badRequest('Resource ${base}${path}'));
              break;

            case 404:
              completer.completeError(_notFound('Resource ${base}${path}'));
              break;

            case 500:
              completer.completeError(_serverError('Resource ${base}${path}'));
              break;
            default:
              completer.completeError(new UndefinedError('Status (${request.status}): Resource ${base}${path}'));
          }
        })
        ..onError.listen((e) {
          log.errorContext('Status (${request.status}): Resource ${base}${path}', context);
          completer.completeError(e);
        })
        ..send();

    return completer.future;
  }
}
