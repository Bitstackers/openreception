/*                  This file is part of OpenReception
                   Copyright (C) 2014-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of openreception.framework.resource;

/// Protocol wrapper class for building homogenic REST resources across
/// servers and clients.
abstract class User {
  static const String _ns = 'user';
  static const String _group = 'group';
  static const String _identity = 'identity';

  static Uri single(Uri host, int userID) => Uri.parse('${root(host)}/$userID');

  static Uri singleByIdentity(Uri host, String identity) =>
      Uri.parse('${root(host)}/identity/$identity');

  static Uri root(Uri host) =>
      Uri.parse('${util.removeTailingSlashes(host)}/$_ns');

  static Uri list(Uri host) => Uri.parse('${root(host)}');

  static Uri userGroup(Uri host, int userID) =>
      Uri.parse('${single(host, userID)}/$_group');

  static Uri group(Uri host) =>
      Uri.parse('${util.removeTailingSlashes(host)}/$_group');

  static Uri userGroupByID(Uri host, int userID, int groupID) => Uri.parse(
      '${util.removeTailingSlashes(host)}/user/$userID/$_group/$groupID');

  static Uri userIndentities(Uri host, int userID) =>
      Uri.parse('$host/$_ns/$userID/$_identity');

  static Uri userIndentity(Uri host, int userID, String identity) =>
      Uri.parse('$host/$_ns/$userID/$_identity/$identity');

  static Uri userState(Uri host, int uid) => Uri.parse('$host/$_ns/$uid/state');

  static Uri userStateAll(Uri host) => Uri.parse('$host/$_ns/all/state');

  static Uri setUserState(Uri host, int uid, String newState) =>
      Uri.parse('$host/$_ns/$uid/state/$newState');

  static Uri change(Uri host, [int uid]) {
    if (uid == null) {
      return Uri.parse('$host/$_ns/history');
    } else {
      return Uri.parse('$host/$_ns/$uid/history');
    }
  }

  static Uri changelog(Uri host, int uid) =>
      Uri.parse('$host/$_ns/$uid/changelog');
}
