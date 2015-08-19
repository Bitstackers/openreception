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

part of openreception.model;

/**
 *
 */

class DistributionList extends IterableBase<DistributionListEntry> {
  static const String className = '${libraryName}.RecipientList';
  static final Logger log = new Logger(className);

  Iterator get iterator => _recipients.iterator;

  Set<DistributionListEntry> _recipients = new Set();

  Set<DistributionListEntry> get to =>
      _recipients.where((DistributionListEntry mr) => mr.role == Role.TO).toSet();
  Set<DistributionListEntry> get cc =>
      _recipients.where((DistributionListEntry mr) => mr.role == Role.CC).toSet();
  Set<DistributionListEntry> get bcc =>
      _recipients.where((DistributionListEntry mr) => mr.role == Role.BCC).toSet();

  List toJson() =>
      _recipients.map((DistributionListEntry recipient) => recipient.asMap).toList();

  bool get hasRecipients => to.isNotEmpty || cc.isNotEmpty || bcc.isNotEmpty;

  DistributionList.empty();

  /**
   *
   */
  DistributionList(Iterable<DistributionListEntry> recipients) {
    _recipients.addAll(recipients);
  }

  static DistributionList decode(Iterable maps) =>
      new DistributionList(maps.map(DistributionListEntry.decode));

  /**
   * Adds a new recipient to the distribution list.
   */
  void add(DistributionListEntry contact) {
    _recipients.add(contact);
  }
}
