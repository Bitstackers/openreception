part of components;

class MessageOverview {
  Box box;
  Context context;
  DivElement element;

  MessageOverview(DivElement this.element, Context this.context) {
    String html = '''
      <table>
        <thead>
          <tr>
            <th> <input type="checkbox"> </th>
            <th> Tidspunkt </th>
            <th> Agent </th>
            <th> Opkalder </th>
            <th> Status </th>
            <th> Metode </th>
          </tr>
        </thead>
        <tbody>
        </tbody>
      </table>
    ''';

    box = new Box.noChrome(element, new DocumentFragment.html(html).querySelector('table'));
  }
}
