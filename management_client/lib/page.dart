library management_tool.page;

import 'package:route_hierarchical/client.dart';

export 'package:management_tool/page/page-cdr.dart';
export 'package:management_tool/page/page-contact.dart';
export 'package:management_tool/page/page-organization.dart';

abstract class Page {
  String get name;
  Pattern get path;

  setupRouter(Router router);
}
