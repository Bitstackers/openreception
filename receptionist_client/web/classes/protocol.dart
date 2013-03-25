/*                                Bob
                   Copyright (C) 2012-, AdaHeads K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This library is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License and
  a copy of the GCC Runtime Library Exception along with this program;
  see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see
  <http://www.gnu.org/licenses/>.
*/
/**
 * A library to make the Urls.
 */
library protocol;

import 'dart:async';
import 'dart:html';
import 'dart:uri';

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import 'configuration.dart';
import 'logger.dart';

part 'protocol.agent.dart';
part 'protocol.call.dart';
part 'protocol.log.dart';
part 'protocol.message.dart';
part 'protocol.organization.dart';

/**
 * Class to contains the basics about a Protocol element,
 *  like [_url], and the HttpRequest [_request].
 */
abstract class Protocol {
  const String GET = "GET";
  const String POST = "POST";

  String _url;
  HttpRequest _request;
  bool _notSent = true;

  void send(){
    if (_notSent) {
      _request.send();
      _notSent = false;
    }
  }

  /**
   * Makes a complete url from [base], [path] and the [fragments].
   * Output: base + path + ? + fragment[0] + & + fragment[1] ...
   */
  String _buildUrl(String base, String path, [List<String> fragments]){
    var SB = new StringBuffer();
    var url = '${base}${path}';

    if (?fragments && fragments != null && !fragments.isEmpty){
      SB.write('?${fragments.first}');
      fragments.skip(1).forEach((fragment) => SB.write('&${fragment}'));
    }

    log.debug('buildurl: ${url}${SB.toString()}');
    return '${url}${SB.toString()}';
  }

  String _errorLogMessage([String text]){
    if (text != null){
      return '${text} Status: [${_request.status}] URL: ${_url}';
    }else{
      return 'Protocol ${this.runtimeType.toString()} failed. Status: [${_request.status}] URL: ${_url}';
    }

  }
}
