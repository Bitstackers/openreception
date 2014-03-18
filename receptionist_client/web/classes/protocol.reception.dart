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

part of protocol;

/**
 * Get the [id] reception JSON data.
 *
 * Completes with
 *  On success   : [Response] object with status OK (data)
 *  On not found : [Response] object with status NOTFOUND (no data)
 *  on error     : [Response] object with status ERROR or CRITICALERROR (data)
 */
Future<Response<model.Reception>> getReception(int id) {
  assert(id != null);

  final String       base      = configuration.receptionBaseUrl.toString(); //configuration.aliceBaseUrl.toString();
  final Completer<Response<model.Reception>> completer =
      new Completer<Response<model.Reception>>();
  final List<String> fragments = new List<String>();
  final String       path      = '/reception/${id}';
  HttpRequest        request;
  String             url;

  fragments.add('token=${configuration.token}');
  url = _buildUrl(base, path, fragments);

  request = new HttpRequest()
      ..open(GET, url)
      ..onLoad.listen((val) {
        switch(request.status) {
          case 200:
            log.debug('protocol.getReception json: ${request.responseText}'); //TODO remove.
            model.Reception data = new model.Reception.fromJson(_parseJson(request.responseText));
            completer.complete(new Response<model.Reception>(Response.OK, data));
            break;

          case 404:
            completer.complete(new Response<model.Reception>(Response.NOTFOUND, model.nullReception));
            break;

          default:
            completer.completeError(new Response.error(Response.CRITICALERROR, '${url} [${request.status}] ${request.statusText}'));
        }
      })
      ..onError.listen((e) {
        _logError(request, url);
        completer.completeError(new Response.error(Response.CRITICALERROR, e.toString()));
      })
      ..send();

  return completer.future;
}

const String MINI = 'mini';
const String MIDI = 'midi';

/**
 * Get the reception calendar JSON data.
 *
 * Completes with
 *  On success : [Response] object with status OK (data)
 *  on error   : [Response] object with status ERROR or CRITICALERROR (data)
 */
Future<Response<model.CalendarEventList>> getReceptionCalendar(int id) {
  final String       base      = configuration.receptionBaseUrl.toString();
  final Completer<Response<model.CalendarEventList>> completer =
      new Completer<Response<model.CalendarEventList>>();
  final List<String> fragments = new List<String>();
  final String       path      = '/reception/$id/calendar';
  HttpRequest        request;
  String             url;
  
  fragments.add('token=${configuration.token}');
  url = _buildUrl(base, path, fragments);

  request = new HttpRequest()
      ..open(GET, url)
      ..onLoad.listen((val) {
        switch(request.status) {
          case 200:
            var response = _parseJson(request.responseText);
            model.CalendarEventList data = new model.CalendarEventList.fromJson(response, 'CalendarEvents');
            completer.complete(new Response<model.CalendarEventList>(Response.OK, data));
            break;

          default:
            completer.completeError(new Response.error(Response.CRITICALERROR, '${url} [${request.status}] ${request.statusText}'));
        }
      })
      ..onError.listen((e) {
        _logError(request, url);
        completer.completeError(new Response.error(Response.CRITICALERROR, e.toString()));
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
Future<Response<model.ReceptionList>> getReceptionList() {
  final String       base      = configuration.receptionBaseUrl.toString();
  final Completer<Response<model.ReceptionList>> completer =
      new Completer<Response<model.ReceptionList>>();
  final List<String> fragments = new List<String>();
  final String       path      = '/reception';
  HttpRequest        request;
  String             url;
  
  fragments.add('token=${configuration.token}');
  url = _buildUrl(base, path, fragments);

  request = new HttpRequest()
      ..open(GET, url)
      ..onLoad.listen((val) {
        switch(request.status) {
          case 200:
            var response = _parseJson(request.responseText);
            model.ReceptionList data = new model.ReceptionList.fromJson(response, 'reception_list');
            completer.complete(new Response<model.ReceptionList>(Response.OK, data));
            break;

          default:
            completer.completeError(new Response.error(Response.CRITICALERROR, '${url} [${request.status}] ${request.statusText}'));
        }
      })
      ..onError.listen((e) {
        _logError(request, url);
        completer.completeError(new Response.error(Response.CRITICALERROR, e.toString()));
      })
      ..send();

  return completer.future;
}

var receptionListTestData = [{"reception_id": 20, "full_name": 'A.P. Møller - Mærsk (Fake)', "uri": 'A.P. Møller - Mærsk'},
                                {"reception_id": 21, "full_name": 'Danske Bank (Fake)', "uri": 'Danske Bank'},
                                {"reception_id": 22, "full_name": 'Wrist Group (Fake)', "uri": 'Wrist Group'},
                                {"reception_id": 23, "full_name": 'ISS (Fake)', "uri": 'ISS'},
                                {"reception_id": 24, "full_name": 'Novo Nordisk (Fake)', "uri": 'Novo Nordisk'},
                                {"reception_id": 25, "full_name": 'Carlsberg (Fake)', "uri": 'Carlsberg'},
                                {"reception_id": 26, "full_name": 'DONG Energy (Fake)', "uri": 'DONG Energy'},
                                {"reception_id": 27, "full_name": 'DLG (Fake)', "uri": 'DLG'},
                                {"reception_id": 28, "full_name": 'Coop Danmark (Fake)', "uri": 'Coop Danmark'},
                                {"reception_id": 29, "full_name": 'Nordea Bank (Fake)', "uri": 'Nordea Bank'},
                                {"reception_id": 30, "full_name": 'Skandinavisk Holding (Fake)', "uri": 'Skandinavisk Holding'},
                                {"reception_id": 31, "full_name": 'TDC (Fake)', "uri": 'TDC'},
                                {"reception_id": 32, "full_name": 'Grundfos (Fake)', "uri": 'Grundfos'},
                                {"reception_id": 33, "full_name": 'PFA (Fake)', "uri": 'PFA'},
                                {"reception_id": 34, "full_name": 'Siemens Wind Power (Fake)', "uri": 'Siemens Wind Power'},
                                {"reception_id": 35, "full_name": 'Dansk Shell (Fake)', "uri": 'Dansk Shell'},
                                {"reception_id": 36, "full_name": 'Tryg (Fake)', "uri": 'Tryg'},
                                {"reception_id": 37, "full_name": 'H. Lundbeck (Fake)', "uri": 'H. Lundbeck'},
                                {"reception_id": 38, "full_name": 'Rockwool International (Fake)', "uri": 'Rockwool International'},
                                {"reception_id": 39, "full_name": 'Jysk (Fake)', "uri": 'Jysk'},
                                {"reception_id": 40, "full_name": 'Statoil Fuel & Retail (Fake)', "uri": 'Statoil Fuel & Retail'},
                                {"reception_id": 41, "full_name": 'Egmont', "uri": 'Egmont'},
                                {"reception_id": 42, "full_name": 'Jyske Bank', "uri": 'Jyske Bank'},
                                {"reception_id": 43, "full_name": 'Energi Danmark', "uri": 'Energi Danmark'},
                                {"reception_id": 44, "full_name": 'Sampension KP', "uri": 'Sampension KP'},
                                {"reception_id": 45, "full_name": 'Rambøll Gruppen', "uri": 'Rambøll Gruppen'},
                                {"reception_id": 46, "full_name": 'Torm', "uri": 'Torm'},
                                {"reception_id": 47, "full_name": 'Nomeco', "uri": 'Nomeco'},
                                {"reception_id": 48, "full_name": 'Auriga Industries', "uri": 'Auriga Industries'},
                                {"reception_id": 49, "full_name": 'MSC Scandinavia', "uri": 'MSC Scandinavia'},
                                {"reception_id": 50, "full_name": 'Sydbank', "uri": 'Sydbank'},
                                {"reception_id": 51, "full_name": 'SAS Institute', "uri": 'SAS Institute'},
                                {"reception_id": 52, "full_name": 'Uno-X Energi', "uri": 'Uno-X Energi'},
                                {"reception_id": 53, "full_name": 'LM Wind Power', "uri": 'LM Wind Power'},
                                {"reception_id": 54, "full_name": 'Chr. Hansen', "uri": 'Chr. Hansen'},
                                {"reception_id": 55, "full_name": 'KMD', "uri": 'KMD'},
                                {"reception_id": 56, "full_name": 'Alfa Laval', "uri": 'Alfa Laval'},
                                {"reception_id": 57, "full_name": 'Saint-Gobain Distribution', "uri": 'Saint-Gobain Distribution'},
                                {"reception_id": 58, "full_name": 'HOFOR', "uri": 'HOFOR'},
                                {"reception_id": 59, "full_name": 'J. Lauritzen', "uri": 'J. Lauritzen'},
                                {"reception_id": 60, "full_name": 'IC Companys', "uri": 'IC Companys'},
                                {"reception_id": 61, "full_name": 'Danske Spil', "uri": 'Danske Spil'},
                                {"reception_id": 62, "full_name": 'SEAS-NVE', "uri": 'SEAS-NVE'},
                                {"reception_id": 63, "full_name": 'Siemens', "uri": 'Siemens'},
                                {"reception_id": 64, "full_name": 'Alka', "uri": 'Alka'},
                                {"reception_id": 65, "full_name": 'Linak', "uri": 'Linak'},
                                {"reception_id": 66, "full_name": 'HI3G', "uri": 'HI3G'},
                                {"reception_id": 67, "full_name": 'Scandlines', "uri": 'Scandlines'},
                                {"reception_id": 68, "full_name": 'BAT', "uri": 'BAT'},
                                {"reception_id": 69, "full_name": 'Foss', "uri": 'Foss'},
                                {"reception_id": 70, "full_name": 'Welltec', "uri": 'Welltec'},
                                {"reception_id": 71, "full_name": 'Nobia Denmark', "uri": 'Nobia Denmark'},
                                {"reception_id": 72, "full_name": 'NOV Flexibles', "uri": 'NOV Flexibles'},
                                {"reception_id": 73, "full_name": 'KPMG', "uri": 'KPMG'},
                                {"reception_id": 74, "full_name": 'GEA Process Engineering', "uri": 'GEA Process Engineering'},
                                {"reception_id": 75, "full_name": 'Dansk Retursystem', "uri": 'Dansk Retursystem'},
                                {"reception_id": 76, "full_name": 'G4S Security Services', "uri": 'G4S Security Services'},
                                {"reception_id": 77, "full_name": 'DHL Express', "uri": 'DHL Express'},
                                {"reception_id": 78, "full_name": 'Scania Danmark', "uri": 'Scania Danmark'},
                                {"reception_id": 79, "full_name": 'Accenture', "uri": 'Accenture'},
                                {"reception_id": 80, "full_name": 'Th. Wessel & Vett', "uri": 'Th. Wessel & Vett'},
                                {"reception_id": 81, "full_name": 'Schneider Electric', "uri": 'Schneider Electric'},
                                {"reception_id": 82, "full_name": 'SDC', "uri": 'SDC'},
                                {"reception_id": 83, "full_name": 'Niras Gruppen', "uri": 'Niras Gruppen'},
                                {"reception_id": 84, "full_name": 'Chr. Olesen & Co.', "uri": 'Chr. Olesen & Co.'},
                                {"reception_id": 85, "full_name": 'Terma', "uri": 'Terma'},
                                {"reception_id": 86, "full_name": 'Ericsson Danmark', "uri": 'Ericsson Danmark'},
                                {"reception_id": 87, "full_name": 'Bankdata', "uri": 'Bankdata'},
                                {"reception_id": 88, "full_name": 'CRH Concrete', "uri": 'CRH Concrete'},
                                {"reception_id": 89, "full_name": 'Geodis Wilson', "uri": 'Geodis Wilson'},
                                {"reception_id": 90, "full_name": 'Sandoz', "uri": 'Sandoz'},
                                {"reception_id": 91, "full_name": 'BASF', "uri": 'BASF'},
                                {"reception_id": 92, "full_name": 'Engsø Gruppen', "uri": 'Engsø Gruppen'},
                                {"reception_id": 93, "full_name": 'Microsoft Danmark', "uri": 'Microsoft Danmark'},
                                {"reception_id": 94, "full_name": 'Logica Danmark', "uri": 'Logica Danmark'},
                                {"reception_id": 95, "full_name": 'Broen Armatur', "uri": 'Broen Armatur'},
                                {"reception_id": 96, "full_name": 'Reckitt Benckiser', "uri": 'Reckitt Benckiser'},
                                {"reception_id": 97, "full_name": 'BDO Holding', "uri": 'BDO Holding'},
                                {"reception_id": 98, "full_name": 'Lindab', "uri": 'Lindab'},
                                {"reception_id": 99, "full_name": 'Brenntag Nordic', "uri": 'Brenntag Nordic'},
                                {"reception_id": 100, "full_name": 'Nordisk Wavin', "uri": 'Nordisk Wavin'},
                                {"reception_id": 101, "full_name": 'Nestle Danmark', "uri": 'Nestle Danmark'},
                                {"reception_id": 102, "full_name": 'Lemminkainen', "uri": 'Lemminkainen'},
                                {"reception_id": 103, "full_name": 'Mckinsey & Company', "uri": 'Mckinsey & Company'},
                                {"reception_id": 104, "full_name": 'Krüger', "uri": 'Krüger'},
                                {"reception_id": 105, "full_name": 'B. Nygaard Sørensen', "uri": 'B. Nygaard Sørensen'},
                                {"reception_id": 106, "full_name": 'Lyreco Danmark', "uri": 'Lyreco Danmark'},
                                {"reception_id": 107, "full_name": 'Schmitz Cargobull', "uri": 'Schmitz Cargobull'},
                                {"reception_id": 108, "full_name": 'Noe Net', "uri": 'Noe Net'},
                                {"reception_id": 109, "full_name": 'Frederikshavn Forsyning', "uri": 'Frederikshavn Forsyning'},
                                {"reception_id": 110, "full_name": 'Microsoft Development', "uri": 'Microsoft Development'},
                                {"reception_id": 111, "full_name": 'Mars Danmark', "uri": 'Mars Danmark'},
                                {"reception_id": 112, "full_name": 'Ferrosan', "uri": 'Ferrosan'},
                                {"reception_id": 113, "full_name": 'Beierholm', "uri": 'Beierholm'},
                                {"reception_id": 114, "full_name": 'Fonden DBK', "uri": 'Fonden DBK'},
                                {"reception_id": 115, "full_name": 'Adecco', "uri": 'Adecco'},
                                {"reception_id": 116, "full_name": 'Konica Minolta Bus.', "uri": 'Konica Minolta Bus.'},
                                {"reception_id": 117, "full_name": 'Dagbladet Børsen', "uri": 'Dagbladet Børsen'},
                                {"reception_id": 118, "full_name": 'Pressalit Group', "uri": 'Pressalit Group'},
                                {"reception_id": 119, "full_name": 'Actavis', "uri": 'Actavis'},
                                {"reception_id": 120, "full_name": 'Advokatfirmaet Cubus', "uri": 'Advokatfirmaet Cubus'},
                                {"reception_id": 121, "full_name": 'Advokatfirmaet Klausen', "uri": 'Advokatfirmaet Klausen'},
                                {"reception_id": 122, "full_name": 'Advokatfirmaet Sven og søn', "uri": 'Advokatfirmaet Sven og søn'},
                                {"reception_id": 123, "full_name": 'Advokatfirmaet Rend og hop', "uri": 'Advokatfirmaet Rend og hop'},
                                {"reception_id": 124, "full_name": 'Advokatfirmaet Fusk & Snyd', "uri": 'Advokatfirmaet Fusk & Snyd'},
                                {"reception_id": 125, "full_name": 'Advokatfirmaet MBF', "uri": 'Advokatfirmaet MBF'}];
