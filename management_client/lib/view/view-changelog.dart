part of management_tool.view;

class Changelog {
  final Logger _log = new Logger('$_libraryName.Changelog');

  final DivElement element = new DivElement()..classes.add('full-width');

  Changelog();

  void set content(String content) {
    element.children = [new PreElement()..text = content];
  }
}
