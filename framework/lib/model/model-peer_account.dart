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

part of openreception.framework.model;

/// Model class representing a peer account.
///
/// Used for generating new xml peer accounts in the FreeSWITCH config.
class PeerAccount {
  final String username;
  final String password;
  final String context;

  /// Default constructor.
  const PeerAccount(this.username, this.password, this.context);

  /// Deserializing factory.
  static PeerAccount decode(Map<String, dynamic> map) =>
      new PeerAccount(map[key.username], map[key.password], map[key.context]);

  /// Serialization function.
  Map<String, dynamic> toJson() => <String, dynamic>{
        key.username: username,
        key.password: password,
        key.context: context
      };

  /// Returns a string representation of the [PeerAccount].
  @override
  String toString() => '$username ($context)';
}
