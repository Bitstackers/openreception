/*                  This file is part of OpenReception
                   Copyright (C) 2015-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of openreception.dialplan_server.controller;

/**
 * PeerAccount controller class.
 */
class PeerAccount {
  final Logger _log = new Logger('$_libraryName.PeerAccount');
  final dialplanTools.DialplanCompiler _compiler;
  final storage.User _userStore;

  /**
   *
   */
  PeerAccount(this._userStore, this._compiler);

  /**
   *
   */
  Future<shelf.Response> deploy(shelf.Request request) async {
    final int uid = int.parse(shelf_route.getPathParameter(request, 'uid'));
    final model.PeerAccount account = await request
        .readAsString()
        .then(JSON.decode)
        .then(model.PeerAccount.decode);

    final model.User user = await _userStore.get(uid);

    final String xmlFilePath = '${config.dialplanserver.freeswitchConfPath}'
        '/directory/receptionists/${account.username}.xml';
    final List<String> generatedFiles = new List<String>.from([xmlFilePath]);

    _log.fine('Deploying new peer account to file $xmlFilePath');
    await new File(xmlFilePath)
        .writeAsString(_compiler.userToXml(user, account));

    return _okJson(generatedFiles);
  }

  /**
   *
   */
  Future<shelf.Response> get(shelf.Request request) async {
    throw new UnimplementedError();
  }

  /**
   *
   */
  Future<shelf.Response> list(shelf.Request request) async {
    final String xmlFilePath = '${config.dialplanserver.freeswitchConfPath}'
        '/directory/receptionists';

    bool isXmlFile(FileSystemEntity fse) =>
        fse is File && fse.path.toLowerCase().endsWith('.xml');

    final List<String> listing = await new Directory(xmlFilePath)
        .list()
        .where(isXmlFile)
        .map((fse) => fse.uri.pathSegments.last.split('.xml').first)
        .toList();

    return _okJson(listing);
  }

  /**
   *
   */
  Future<shelf.Response> remove(shelf.Request request) async {
    final String aid = shelf_route.getPathParameter(request, 'aid');

    final String xmlFilePath = '${config.dialplanserver.freeswitchConfPath}'
        '/directory/receptionists/${aid}.xml';

    final File peerAccount = new File(xmlFilePath);

    if (!await peerAccount.exists()) {
      return _notFound('No peer account for $aid');
    }

    await new File(xmlFilePath).delete();
    return _okJson({});
  }
}
