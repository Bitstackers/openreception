/*                 Copyright (C) 2015-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of drvupld;

/**
 * Is thrown when a [NameParts.uuid] channel is still actively recording.
 */
class ActiveRecordingException implements Exception {
  final String message;
  const ActiveRecordingException(String this.message);
}

/**
 * Is thrown when a [NameParts] object cannot be harvested from a file name.
 */
class HarvestException implements Exception {
  final String message;
  const HarvestException(String this.message);
}

/**
 * Is thrown when a Google Drive folder cannot be found.
 */
class NoFolderFoundException implements Exception {
  final String message;
  const NoFolderFoundException(String this.message);
}

/**
 * Is thrown whenever errors happen in the OpenReceptionFramework.
 */
class ORFException implements Exception {
  final String message;
  const ORFException(String this.message);
}
