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
abstract class ContactResource {
  static final String _reception = '/reception';
  static final String _calendar = '/calendar';
  static final String _contact = '/contact';

  static String single(int contactID, int receptionID) {
    return '${_reception}/${receptionID}';
  }

  static String list(int receptionID) {
    return '${_reception}/${receptionID}';
  }

  static String calendar(int contactID, int receptionID) {
    return '${_contact}/${contactID}${_reception}/${receptionID}${_calendar}';
  }
}

/**
 * 
 */
abstract class Contact {

  static const String className = '${libraryName}.Contact';

  /**
   * 
   */
  static Future<model.ContactList> list(int receptionID) {
    
    const String context = '${className}.list';

    assert(receptionID != null);

    final String base = configuration.contactBaseUrl.toString();
    final Completer<model.ContactList> completer = new Completer<model.ContactList>();
    final List<String> fragments = new List<String>();
    final String path = '/contact/list/reception/${receptionID}';
    HttpRequest request;
    String url;

    fragments.add('token=${configuration.token}');
    url = _buildUrl(base, path, fragments);

    request = new HttpRequest()
        ..open(GET, url)
        ..onLoad.listen((val) {
          switch (request.status) {
            case 200:
              completer.complete(new model.ContactList.fromJson(JSON.decode(request.responseText), 'contacts', receptionID));
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
   * 
   */
  static Future<model.Contact> get(int contactID, int receptionID) {
    const String context = '${className}.get';

    assert(receptionID != null);
    assert(receptionID >= 0);
    assert(contactID != null);
    assert(contactID >= 0);

    final Completer<model.Contact>completer = new Completer<model.Contact>();

    final String base = configuration.contactBaseUrl.toString();
    final List<String> fragments = new List<String>();
    final String path = '/contact/${contactID}/reception/${receptionID}';

    HttpRequest request;
    String url;

    fragments.add('token=${configuration.token}');
    url = _buildUrl(base, path, fragments);

    request = new HttpRequest()
        ..open(GET, url)
        ..onLoad.listen((val) {
          switch (request.status) {
            case 200:
              completer.complete(new model.Contact.fromJson(JSON.decode(request.responseText), receptionID));
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
   * 
   */
  static Future<model.CalendarEventList> calendar(int contactID, int receptionID) {
    const String context = '${className}.calendar';

    assert(receptionID != null);
    assert(receptionID >= 0);
    assert(contactID != null);
    assert(contactID >= 0);

    final String base = configuration.contactBaseUrl.toString(); //configuration.aliceBaseUrl.toString();
    final Completer<model.CalendarEventList> completer = new Completer<model.CalendarEventList>();
    final List<String> fragments = new List<String>();
    final String path = '/contact/${contactID}/reception/${receptionID}/calendar';
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
}
