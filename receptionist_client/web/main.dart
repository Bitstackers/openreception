import 'dart:html';

void main() {
  ButtonElement button = querySelector('#context-switcher>button');
  DivElement div = querySelector('#reception-calendar');

  button.onClick.listen((_) => div.classes.toggle('focus'));
//  button.onClick.listen((_) => querySelector('#context-home').classes.toggle('none'));

  SpanElement showRecipients = querySelector('#message-compose .show-recipients');
  showRecipients.onMouseOver.listen((_) => querySelector('#message-compose .recipients').classes.toggle('recipients-hidden', false));
  showRecipients.onMouseOut.listen((_) => querySelector('#message-compose .recipients').classes.toggle('recipients-hidden', true));
}
