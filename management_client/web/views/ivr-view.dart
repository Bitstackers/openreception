library ivr.view;

import 'dart:html';
import 'dart:convert';

import 'package:libdialplan/libdialplan.dart';
import 'package:libdialplan/ivr.dart' as libIvr;

import '../lib/eventbus.dart';
import '../lib/model.dart';
import '../notification.dart' as notify;
import '../lib/request.dart' as request;
import '../lib/searchcomponent.dart';
import '../lib/view_utilities.dart';

class IvrView {
  String viewName = 'ivr';
  int receptionId;
  Dialplan dialplan;
  libIvr.IvrList ivrList;

  List<Audiofile> receptionSounds = new List<Audiofile>();

  DivElement element;
  DivElement receptionOuterSelector;
  UListElement menuList;
  ButtonElement newButton;
  ButtonElement saveButton;
  TableSectionElement contentBody;
  SelectElement greetLongPicker, greetShortPicker,
                invalidSoundPicker, exitSoundPicker;

  SearchComponent receptionPicker;
  IvrView(DivElement this.element) {
    menuList    = element.querySelector('#ivr-menu-list');
    newButton   = element.querySelector('#ivr-new-menu');
    saveButton  = element.querySelector('#ivr-save');
    contentBody = element.querySelector('#ivr-content-body');

    greetLongPicker    = element.querySelector('#ivr-greetlong');
    greetShortPicker   = element.querySelector('#ivr-greetshort');
    invalidSoundPicker = element.querySelector('#ivr-invalidsound');
    exitSoundPicker    = element.querySelector('#ivr-exitsound');

    receptionOuterSelector = element.querySelector('#ivr-receptionpicker');
    receptionPicker = new SearchComponent<Reception>(receptionOuterSelector, 'ivr-reception-searchbox')
        ..listElementToString = receptionToSearchboxString
        ..searchFilter = receptionSearchHandler;

    fillSearchComponent();

    registrateEventHandlers();
  }

  void registrateEventHandlers() {
    bus.on(windowChanged).listen((Map event) {
      element.classes.toggle('hidden', event['window'] != viewName);
    });

    receptionPicker.selectedElementChanged = (Reception reception) {
      loadReceptionData(reception.id);
    };

    newButton.onClick.listen((_) {
      if(ivrList != null) {
        int number = 1;
        String name = 'menu${number}';
        while(ivrList.list.any((libIvr.Ivr i) => i.name == name)) {
          name = 'menu${++number}';
        }
        ivrList.list.add(new libIvr.Ivr()..name = name);
        renderMenuList(ivrList);
      }
    });

    saveButton.onClick.listen((_) {
      if(receptionId != null && ivrList != null) {
        request.updateIvr(receptionId, JSON.encode(ivrList));
      }
    });
  }

  void loadReceptionData(int receptionId) {
    this.receptionId = receptionId;
    request.getDialplan(receptionId).then((Dialplan dialplan) {
      this.dialplan = dialplan;
      return request.getIvr(receptionId);
    }).then((libIvr.IvrList ivrList) {
      this.ivrList = ivrList;
      return request.getAudiofileList(receptionId);
    }).then((List<Audiofile> sounds) {
      receptionSounds = sounds;
    }).then((_) {
      clearContentTable();
      renderMenuList(ivrList);
    }).catchError((error) {
      notify.error(error.toString());
    });
  }

  String receptionToSearchboxString(Reception reception, String searchterm) {
    return '${reception.full_name}';
  }

  bool receptionSearchHandler(Reception reception, String searchTerm) {
    return reception.full_name.toLowerCase().contains(searchTerm.toLowerCase());
  }

  void fillSearchComponent() {
    request.getReceptionList().then((List<Reception> list) {
      list.sort((a, b) => a.full_name.compareTo(b.full_name));
      receptionPicker.updateSourceList(list);
    });
  }

  void renderMenuList(libIvr.IvrList menus) {
    menuList.children
      ..clear()
      ..addAll(menus.list.map(makeMenuListItem));
  }

  void HighlightItem(LIElement node) {
    menuList.children.forEach((item) => item.classes.toggle('highlightListItem', item == node));
  }

  /**
   * Creates an item for the list of IVRs.
   */
  LIElement makeMenuListItem(libIvr.Ivr item) {
    LIElement node = new LIElement();

    SpanElement text = new SpanElement()
      ..text = item.name
      ..onClick.listen((_) {
        HighlightItem(node);
        loadIVR(item);
      });

    bool activeEdit = false;
    String oldDisplay = text.style.display;

    InputElement editBox = new InputElement(type: 'text');
    editBox
      ..style.display = 'none'
      ..onKeyDown.listen((KeyboardEvent event) {
                KeyEvent key = new KeyEvent.wrap(event);
                if (key.keyCode == Keys.ENTER || key.keyCode == Keys.ESCAPE) {
                  if (key.keyCode == Keys.ENTER) {
                    item.name = editBox.value;
                    text.text = item.name;
                  }
                  text.style.display = oldDisplay;
                  editBox.style.display = 'none';
                  activeEdit = false;
                }
              });
    ImageElement editButton = new ImageElement(src: 'image/tp/line.svg')
        ..classes.add('ivr-small-button')
        ..onClick.listen((_) {
            if(activeEdit == false) {
              activeEdit = true;
              text.style.display = 'none';
              editBox.style.display = 'inline';

              editBox
                ..focus()
                ..value = text.text;
            }
          });

    ImageElement deleteButton = new ImageElement(src: 'image/tp/red_plus.svg')
      ..classes.add('ivr-small-button')
      ..onClick.listen((_) {
        ivrList.list.remove(item);
        renderMenuList(ivrList);
      });

    node.children.addAll([text, editBox, editButton, deleteButton]);

    return node;
  }

  void clearContentTable() {
    contentBody.children.clear();
  }

  /**
   * Fills in the interface for that IVR menu.   *
   */
  void loadIVR(libIvr.Ivr ivr) {
    List<String> digitss = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '*', '#'];
    contentBody.children
      ..clear()
      ..addAll(digitss.map((String digit) => ivrTableRow(digit, ivr)));

    greetLongPicker.children
      ..clear()
      ..add(new OptionElement(data:'ingen', value: '', selected: ivr.greetingLong == null || ivr.greetingLong.trim().isEmpty))
      ..addAll(receptionSounds.map((Audiofile file) =>
        new OptionElement(data: file.shortname, value: file.filepath, selected: file.filepath == ivr.greetingLong)));

    greetShortPicker.children
      ..clear()
      ..add(new OptionElement(data:'ingen', value: '', selected: ivr.greetingShort == null || ivr.greetingShort.trim().isEmpty))
      ..addAll(receptionSounds.map((Audiofile file) =>
        new OptionElement(data: file.shortname, value: file.filepath, selected: file.filepath == ivr.greetingShort)));

    invalidSoundPicker.children
      ..clear()
      ..add(new OptionElement(data:'ingen', value: '', selected: ivr.invalidSound == null || ivr.invalidSound.trim().isEmpty))
      ..addAll(receptionSounds.map((Audiofile file) =>
        new OptionElement(data: file.shortname, value: file.filepath, selected: file.filepath == ivr.invalidSound)));

    exitSoundPicker.children
      ..clear()
      ..add(new OptionElement(data:'ingen', value: '', selected: ivr.exitSound == null || ivr.exitSound.trim().isEmpty))
      ..addAll(receptionSounds.map((Audiofile file) =>
        new OptionElement(data: file.shortname, value: file.filepath, selected: file.filepath == ivr.exitSound)));

  }

  /**
   * TODO find a better name, for the function that generates a row for the table in the middle of the screen.
   */
  TableRowElement ivrTableRow(String digit, libIvr.Ivr ivr) {
    libIvr.Entry entry = ivr.entries.firstWhere((e) => e.digits == digit, orElse: () => null);

    TableRowElement row = new TableRowElement();
    TableCellElement digitCell = new TableCellElement()
      ..classes.add('ivr-dial-field')
      ..text = digit;

    TableCellElement parameterCell = new TableCellElement()
      ..children.add(parametersForEntry(entry));

    List<OptionElement> actionList =
        [new OptionElement(data: 'Intet', value: 'none', selected: entry == null),
         new OptionElement(data: 'Send Til gruppe', value: 'extensiongroup', selected: entry != null)];
    SelectElement actionPicker = new SelectElement();
    actionPicker
      ..children.addAll(actionList)
      ..onChange.listen((_) {
      switch (actionPicker.selectedOptions.first.value) {
        case 'none':
          ivr.entries.remove(entry);
          break;
        case 'extensiongroup':
          entry = new libIvr.Entry()
            ..digits = digit;
          ivr.entries.add(entry);
          break;
      }
      parameterCell.children
        ..clear()
        ..add(parametersForEntry(entry));
    });

    TableCellElement actionCell = new TableCellElement()
      ..classes.add('ivr-action-field')
      ..children.add(actionPicker);

    return row
      ..children.addAll([digitCell, actionCell, parameterCell]);
  }

  DivElement parametersForEntry(libIvr.Entry entry) {
    DivElement container = new DivElement();

    if(entry != null) {
      SelectElement gruops = new SelectElement()
        ..children.addAll(dialplan.extensionGroups.map((eg) => new OptionElement(data: eg.name, value: eg.name, selected: entry.extensionGroup == eg.name)))
        ..onChange.listen((_) {
        //TODO
      });

      LabelElement label = new LabelElement()
        ..htmlFor = 'ivr-${entry.digits}-group'
        ..text = 'Gruppe';

      container.children.addAll([label, gruops]);
    }

    return container;
  }
}