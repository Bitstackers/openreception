library management_tool.router;

import 'package:route_hierarchical/client.dart' as route;

import 'package:management_tool/page.dart';

class PageRouter {
  final router = new route.Router();
  Page activePage;

  PageRouter(Iterable<Page> pages) {
    pages.forEach((page) {
      page.setupRouter(router);

      print(router);
    });

    router.listen();
  }
}
