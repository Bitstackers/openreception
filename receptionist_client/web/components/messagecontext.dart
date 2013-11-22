part of components;

class MessageSearch{
  Box box;
  DivElement element;
  SpanElement header;

  String headerText = 'Søgning';
  MessageSearch(DivElement this.element) {
    header = new SpanElement()
      ..text = headerText;

    String html = '''
      <div>
        <div id="message-search-agent">
          <input placeholder="agent"></input>
        </div>

        <div id="message-search-type">
          <input placeholder="Type"></input>
        </div>

        <div id="message-search-company">
          <input placeholder="Virksomhed"></input>
        </div>

        <div id="message-search-contact">
          <input placeholder="Medarbejder"></input>
        </div>
        
        <button>Print</button>
        <button>Gensend valgte</button>
      </div>
    ''';

    DocumentFragment frag = new DocumentFragment.html(html);
    box = new Box.withHeader(element, header, frag.querySelector('div'));
  }
}
