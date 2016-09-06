library orm.view_utilities;

import 'dart:html';

const String addNewLiClass = 'addnew';

typedef void OnChange();

class Keys {
  static const int escape = 27;
  static const int enter = 13;
}

void fillList(UListElement element, List<String> items, {OnChange onChange}) {
  List<LIElement> children = new List<LIElement>();
  if (items != null) {
    for (String item in items) {
      LIElement li = simpleListElement(item, onChange: onChange);
      children.add(li);
    }
  }

  InputElement inputNewItem = new InputElement();
  inputNewItem
    ..classes.add(addNewLiClass)
    ..placeholder = 'Tilføj ny...'
    ..onKeyPress.listen((KeyboardEvent event) {
      KeyEvent key = new KeyEvent.wrap(event);
      if (key.keyCode == Keys.enter) {
        String item = inputNewItem.value;
        inputNewItem.value = '';

        LIElement li = simpleListElement(item);
        int index = element.children.length - 1;
        element.children.insert(index, li);

        if (onChange != null) {
          onChange();
        }
      } else if (key.keyCode == Keys.escape) {
        inputNewItem.value = '';
      }
    });

  children.add(new LIElement()..children.add(inputNewItem));

  element.children
    ..clear()
    ..addAll(children);
}

LIElement simpleListElement(String item, {Function onChange}) {
  LIElement li = new LIElement();
  ButtonElement deleteButton = new ButtonElement()
    ..text = 'Slet'
    ..onClick.listen((_) {
      li.parent.children.remove(li);

      if (onChange != null) {
        onChange();
      }
    });

  SpanElement content = new SpanElement()
    ..text = item
    ..classes.add('contactgenericcontent');
  InputElement editBox = new InputElement(type: 'text');

  editableSpan(content, editBox, onChange);

  li.children.addAll([deleteButton, content, editBox]);
  return li;
}

void editableSpan(SpanElement content, InputElement editBox,
    [Function onChange]) {
  bool activeEdit = false;
  String oldDisplay = content.style.display;
  editBox
    ..style.display = 'none'
    ..onKeyDown.listen((KeyboardEvent event) {
      KeyEvent key = new KeyEvent.wrap(event);
      if (key.keyCode == Keys.enter || key.keyCode == Keys.escape) {
        if (key.keyCode == Keys.enter) {
          content.text = editBox.value;

          if (onChange != null) {
            onChange();
          }
        }
        content.style.display = oldDisplay;
        editBox.style.display = 'none';
        activeEdit = false;
      }
    });
  content.onClick.listen((MouseEvent event) {
    if (!activeEdit) {
      activeEdit = true;
      content.style.display = 'none';
      editBox.style.display = 'inline';

      editBox
        ..focus()
        ..value = content.text;
    }
  });
}

List<String> getListValues(UListElement element) {
  List<String> texts = new List<String>();
  element.children.where((e) => e is LIElement).forEach((li) {
    if (!li.classes.contains(addNewLiClass)) {
      SpanElement content = li.children
          .firstWhere((elem) => elem is SpanElement, orElse: () => null);
      if (content != null) {
        texts.add(content.text);
      }
    }
  });
  return texts;
}
