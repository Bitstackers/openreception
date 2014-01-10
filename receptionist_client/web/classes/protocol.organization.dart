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
 * Get the [id] organization JSON data.
 *
 * Completes with
 *  On success   : [Response] object with status OK (data)
 *  On not found : [Response] object with status NOTFOUND (no data)
 *  on error     : [Response] object with status ERROR or CRITICALERROR (data)
 */
Future<Response<model.Organization>> getOrganization(int id) {
  assert(id != null);

  final String       base      = configuration.organizationServer.toString(); //configuration.aliceBaseUrl.toString();
  final Completer<Response<model.Organization>> completer =
      new Completer<Response<model.Organization>>();
  final List<String> fragments = new List<String>();
  final String       path      = '/organization/${id}';
  HttpRequest        request;
  String             url;

  fragments.add('token=${configuration.token}');
  url = _buildUrl(base, path, fragments);

  request = new HttpRequest()
      ..open(GET, url)
      ..onLoad.listen((val) {
        switch(request.status) {
          case 200:
            log.debug('protocol.getOrganization json: ${request.responseText}'); //TODO remove.
            model.Organization data = new model.Organization.fromJson(_parseJson(request.responseText));
            completer.complete(new Response<model.Organization>(Response.OK, data));
            break;

          case 404:
            completer.complete(new Response<model.Organization>(Response.NOTFOUND, model.nullOrganization));
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
 * Get the organization list JSON data.
 *
 * Completes with
 *  On success : [Response] object with status OK (data)
 *  on error   : [Response] object with status ERROR or CRITICALERROR (data)
 */
Future<Response<model.OrganizationList>> getOrganizationList() {
  final String       base      = configuration.organizationServer.toString();
  final Completer<Response<model.OrganizationList>> completer =
      new Completer<Response<model.OrganizationList>>();
  final List<String> fragments = new List<String>();
  final String       path      = '/organization';
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
            model.OrganizationList data = new model.OrganizationList.fromJson(response, 'organization_list');
            completer.complete(new Response<model.OrganizationList>(Response.OK, data));
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

var organizationListTestData = [{"organization_id": 20, "full_name": 'A.P. Møller - Mærsk (Fake)', "uri": 'A.P. Møller - Mærsk'},
                                {"organization_id": 21, "full_name": 'Danske Bank (Fake)', "uri": 'Danske Bank'},
                                {"organization_id": 22, "full_name": 'Wrist Group (Fake)', "uri": 'Wrist Group'},
                                {"organization_id": 23, "full_name": 'ISS (Fake)', "uri": 'ISS'},
                                {"organization_id": 24, "full_name": 'Novo Nordisk (Fake)', "uri": 'Novo Nordisk'},
                                {"organization_id": 25, "full_name": 'Carlsberg (Fake)', "uri": 'Carlsberg'},
                                {"organization_id": 26, "full_name": 'DONG Energy (Fake)', "uri": 'DONG Energy'},
                                {"organization_id": 27, "full_name": 'DLG (Fake)', "uri": 'DLG'},
                                {"organization_id": 28, "full_name": 'Coop Danmark (Fake)', "uri": 'Coop Danmark'},
                                {"organization_id": 29, "full_name": 'Nordea Bank (Fake)', "uri": 'Nordea Bank'},
                                {"organization_id": 30, "full_name": 'Skandinavisk Holding (Fake)', "uri": 'Skandinavisk Holding'},
                                {"organization_id": 31, "full_name": 'TDC (Fake)', "uri": 'TDC'},
                                {"organization_id": 32, "full_name": 'Grundfos (Fake)', "uri": 'Grundfos'},
                                {"organization_id": 33, "full_name": 'PFA (Fake)', "uri": 'PFA'},
                                {"organization_id": 34, "full_name": 'Siemens Wind Power (Fake)', "uri": 'Siemens Wind Power'},
                                {"organization_id": 35, "full_name": 'Dansk Shell (Fake)', "uri": 'Dansk Shell'},
                                {"organization_id": 36, "full_name": 'Tryg (Fake)', "uri": 'Tryg'},
                                {"organization_id": 37, "full_name": 'H. Lundbeck (Fake)', "uri": 'H. Lundbeck'},
                                {"organization_id": 38, "full_name": 'Rockwool International (Fake)', "uri": 'Rockwool International'},
                                {"organization_id": 39, "full_name": 'Jysk (Fake)', "uri": 'Jysk'},
                                {"organization_id": 40, "full_name": 'Statoil Fuel & Retail (Fake)', "uri": 'Statoil Fuel & Retail'},
                                {"organization_id": 41, "full_name": 'Egmont', "uri": 'Egmont'},
                                {"organization_id": 42, "full_name": 'Jyske Bank', "uri": 'Jyske Bank'},
                                {"organization_id": 43, "full_name": 'Energi Danmark', "uri": 'Energi Danmark'},
                                {"organization_id": 44, "full_name": 'Sampension KP', "uri": 'Sampension KP'},
                                {"organization_id": 45, "full_name": 'Rambøll Gruppen', "uri": 'Rambøll Gruppen'},
                                {"organization_id": 46, "full_name": 'Torm', "uri": 'Torm'},
                                {"organization_id": 47, "full_name": 'Nomeco', "uri": 'Nomeco'},
                                {"organization_id": 48, "full_name": 'Auriga Industries', "uri": 'Auriga Industries'},
                                {"organization_id": 49, "full_name": 'MSC Scandinavia', "uri": 'MSC Scandinavia'},
                                {"organization_id": 50, "full_name": 'Sydbank', "uri": 'Sydbank'},
                                {"organization_id": 51, "full_name": 'SAS Institute', "uri": 'SAS Institute'},
                                {"organization_id": 52, "full_name": 'Uno-X Energi', "uri": 'Uno-X Energi'},
                                {"organization_id": 53, "full_name": 'LM Wind Power', "uri": 'LM Wind Power'},
                                {"organization_id": 54, "full_name": 'Chr. Hansen', "uri": 'Chr. Hansen'},
                                {"organization_id": 55, "full_name": 'KMD', "uri": 'KMD'},
                                {"organization_id": 56, "full_name": 'Alfa Laval', "uri": 'Alfa Laval'},
                                {"organization_id": 57, "full_name": 'Saint-Gobain Distribution', "uri": 'Saint-Gobain Distribution'},
                                {"organization_id": 58, "full_name": 'HOFOR', "uri": 'HOFOR'},
                                {"organization_id": 59, "full_name": 'J. Lauritzen', "uri": 'J. Lauritzen'},
                                {"organization_id": 60, "full_name": 'IC Companys', "uri": 'IC Companys'},
                                {"organization_id": 61, "full_name": 'Danske Spil', "uri": 'Danske Spil'},
                                {"organization_id": 62, "full_name": 'SEAS-NVE', "uri": 'SEAS-NVE'},
                                {"organization_id": 63, "full_name": 'Siemens', "uri": 'Siemens'},
                                {"organization_id": 64, "full_name": 'Alka', "uri": 'Alka'},
                                {"organization_id": 65, "full_name": 'Linak', "uri": 'Linak'},
                                {"organization_id": 66, "full_name": 'HI3G', "uri": 'HI3G'},
                                {"organization_id": 67, "full_name": 'Scandlines', "uri": 'Scandlines'},
                                {"organization_id": 68, "full_name": 'BAT', "uri": 'BAT'},
                                {"organization_id": 69, "full_name": 'Foss', "uri": 'Foss'},
                                {"organization_id": 70, "full_name": 'Welltec', "uri": 'Welltec'},
                                {"organization_id": 71, "full_name": 'Nobia Denmark', "uri": 'Nobia Denmark'},
                                {"organization_id": 72, "full_name": 'NOV Flexibles', "uri": 'NOV Flexibles'},
                                {"organization_id": 73, "full_name": 'KPMG', "uri": 'KPMG'},
                                {"organization_id": 74, "full_name": 'GEA Process Engineering', "uri": 'GEA Process Engineering'},
                                {"organization_id": 75, "full_name": 'Dansk Retursystem', "uri": 'Dansk Retursystem'},
                                {"organization_id": 76, "full_name": 'G4S Security Services', "uri": 'G4S Security Services'},
                                {"organization_id": 77, "full_name": 'DHL Express', "uri": 'DHL Express'},
                                {"organization_id": 78, "full_name": 'Scania Danmark', "uri": 'Scania Danmark'},
                                {"organization_id": 79, "full_name": 'Accenture', "uri": 'Accenture'},
                                {"organization_id": 80, "full_name": 'Th. Wessel & Vett', "uri": 'Th. Wessel & Vett'},
                                {"organization_id": 81, "full_name": 'Schneider Electric', "uri": 'Schneider Electric'},
                                {"organization_id": 82, "full_name": 'SDC', "uri": 'SDC'},
                                {"organization_id": 83, "full_name": 'Niras Gruppen', "uri": 'Niras Gruppen'},
                                {"organization_id": 84, "full_name": 'Chr. Olesen & Co.', "uri": 'Chr. Olesen & Co.'},
                                {"organization_id": 85, "full_name": 'Terma', "uri": 'Terma'},
                                {"organization_id": 86, "full_name": 'Ericsson Danmark', "uri": 'Ericsson Danmark'},
                                {"organization_id": 87, "full_name": 'Bankdata', "uri": 'Bankdata'},
                                {"organization_id": 88, "full_name": 'CRH Concrete', "uri": 'CRH Concrete'},
                                {"organization_id": 89, "full_name": 'Geodis Wilson', "uri": 'Geodis Wilson'},
                                {"organization_id": 90, "full_name": 'Sandoz', "uri": 'Sandoz'},
                                {"organization_id": 91, "full_name": 'BASF', "uri": 'BASF'},
                                {"organization_id": 92, "full_name": 'Engsø Gruppen', "uri": 'Engsø Gruppen'},
                                {"organization_id": 93, "full_name": 'Microsoft Danmark', "uri": 'Microsoft Danmark'},
                                {"organization_id": 94, "full_name": 'Logica Danmark', "uri": 'Logica Danmark'},
                                {"organization_id": 95, "full_name": 'Broen Armatur', "uri": 'Broen Armatur'},
                                {"organization_id": 96, "full_name": 'Reckitt Benckiser', "uri": 'Reckitt Benckiser'},
                                {"organization_id": 97, "full_name": 'BDO Holding', "uri": 'BDO Holding'},
                                {"organization_id": 98, "full_name": 'Lindab', "uri": 'Lindab'},
                                {"organization_id": 99, "full_name": 'Brenntag Nordic', "uri": 'Brenntag Nordic'},
                                {"organization_id": 100, "full_name": 'Nordisk Wavin', "uri": 'Nordisk Wavin'},
                                {"organization_id": 101, "full_name": 'Nestle Danmark', "uri": 'Nestle Danmark'},
                                {"organization_id": 102, "full_name": 'Lemminkainen', "uri": 'Lemminkainen'},
                                {"organization_id": 103, "full_name": 'Mckinsey & Company', "uri": 'Mckinsey & Company'},
                                {"organization_id": 104, "full_name": 'Krüger', "uri": 'Krüger'},
                                {"organization_id": 105, "full_name": 'B. Nygaard Sørensen', "uri": 'B. Nygaard Sørensen'},
                                {"organization_id": 106, "full_name": 'Lyreco Danmark', "uri": 'Lyreco Danmark'},
                                {"organization_id": 107, "full_name": 'Schmitz Cargobull', "uri": 'Schmitz Cargobull'},
                                {"organization_id": 108, "full_name": 'Noe Net', "uri": 'Noe Net'},
                                {"organization_id": 109, "full_name": 'Frederikshavn Forsyning', "uri": 'Frederikshavn Forsyning'},
                                {"organization_id": 110, "full_name": 'Microsoft Development', "uri": 'Microsoft Development'},
                                {"organization_id": 111, "full_name": 'Mars Danmark', "uri": 'Mars Danmark'},
                                {"organization_id": 112, "full_name": 'Ferrosan', "uri": 'Ferrosan'},
                                {"organization_id": 113, "full_name": 'Beierholm', "uri": 'Beierholm'},
                                {"organization_id": 114, "full_name": 'Fonden DBK', "uri": 'Fonden DBK'},
                                {"organization_id": 115, "full_name": 'Adecco', "uri": 'Adecco'},
                                {"organization_id": 116, "full_name": 'Konica Minolta Bus.', "uri": 'Konica Minolta Bus.'},
                                {"organization_id": 117, "full_name": 'Dagbladet Børsen', "uri": 'Dagbladet Børsen'},
                                {"organization_id": 118, "full_name": 'Pressalit Group', "uri": 'Pressalit Group'},
                                {"organization_id": 119, "full_name": 'Actavis', "uri": 'Actavis'},
                                {"organization_id": 120, "full_name": 'Advokatfirmaet Cubus', "uri": 'Advokatfirmaet Cubus'},
                                {"organization_id": 121, "full_name": 'Advokatfirmaet Klausen', "uri": 'Advokatfirmaet Klausen'},
                                {"organization_id": 122, "full_name": 'Advokatfirmaet Sven og søn', "uri": 'Advokatfirmaet Sven og søn'},
                                {"organization_id": 123, "full_name": 'Advokatfirmaet Rend og hop', "uri": 'Advokatfirmaet Rend og hop'},
                                {"organization_id": 124, "full_name": 'Advokatfirmaet Fusk & Snyd', "uri": 'Advokatfirmaet Fusk & Snyd'},
                                {"organization_id": 125, "full_name": 'Advokatfirmaet MBF', "uri": 'Advokatfirmaet MBF'}];
