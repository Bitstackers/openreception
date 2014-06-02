library view_utilities;

import 'dart:html';

import 'package:html5_dnd/html5_dnd.dart';

String addNewLiClass = 'addnew';

class Keys {
  static const int ESCAPE = 27;
  static const int ENTER = 13;
}

void fillList(UListElement element, List<String> items, {Function onChange}) {
  List<LIElement> children = new List<LIElement>();
  if (items != null) {
    for (String item in items) {
      LIElement li = simpleListElement(item, onChange: onChange);
      children.add(li);
    }
  }

  SortableGroup sortGroup = new SortableGroup()..installAll(children);


  if (onChange != null) {
    sortGroup.onSortUpdate.listen((SortableEvent event) => onChange());
  }

  // Only accept elements from this section.
  sortGroup.accept.add(sortGroup);

  InputElement inputNewItem = new InputElement();
  inputNewItem
      ..classes.add(addNewLiClass)
      ..placeholder = 'Tilføj ny...'
      ..onKeyPress.listen((KeyboardEvent event) {
        KeyEvent key = new KeyEvent.wrap(event);
        if (key.keyCode == Keys.ENTER) {
          String item = inputNewItem.value;
          inputNewItem.value = '';

          LIElement li = simpleListElement(item);
          int index = element.children.length - 1;
          sortGroup.install(li);
          element.children.insert(index, li);

          if (onChange != null) {
            onChange();
          }
        } else if (key.keyCode == Keys.ESCAPE) {
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

void editableSpan(SpanElement content, InputElement editBox, Function onChange) {
  bool activeEdit = false;
  String oldDisplay = content.style.display;
  editBox
    ..style.display = 'none'
    ..onKeyDown.listen((KeyboardEvent event) {
          KeyEvent key = new KeyEvent.wrap(event);
          if (key.keyCode == Keys.ENTER || key.keyCode == Keys.ESCAPE) {
            if (key.keyCode == Keys.ENTER) {
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
  for (LIElement e in element.children) {
    if (!e.classes.contains(addNewLiClass)) {
      SpanElement content = e.children.firstWhere((elem) => elem is SpanElement,
          orElse: () => null);
      if (content != null) {
        texts.add(content.text);
      }
    }
  }
  return texts;
}
