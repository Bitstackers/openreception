library ivr.view;

import 'dart:async';
import 'dart:html';

import 'package:libdialplan/libdialplan.dart';
import 'package:libdialplan/ivr.dart' as libIvr;

import 'package:management_tool/controller.dart' as Controller;
import '../lib/logger.dart' as log;
import 'package:management_tool/notification.dart' as notify;
import '../lib/view_utilities.dart';
import 'package:openreception_framework/model.dart' as ORModel;

class IvrView {
  Dialplan _dialplan;
  libIvr.IvrList _ivrList;
  List<ORModel.Audiofile> _receptionSounds = new List<ORModel.Audiofile>();
  final Controller.Dialplan _dialplanController;


  DivElement _element;
  UListElement _menuList;
  ButtonElement _newButton;
  ButtonElement _closeButton;
  TableSectionElement _contentBody;
  SelectElement _greetLongPicker, _greetShortPicker,
                _invalidSoundPicker, _exitSoundPicker;

  Completer _returnFuture;
  bool _madeChange = false;

  IvrView(DivElement this._element, this._dialplanController) {
    _menuList    = _element.querySelector('#ivr-menu-list');
    _newButton   = _element.querySelector('#ivr-new-menu');
    _closeButton = _element.querySelector('#ivr-close');
    _contentBody = _element.querySelector('#ivr-content-body');

    _greetLongPicker    = _element.querySelector('#ivr-greetlong');
    _greetShortPicker   = _element.querySelector('#ivr-greetshort');
    _invalidSoundPicker = _element.querySelector('#ivr-invalidsound');
    _exitSoundPicker    = _element.querySelector('#ivr-exitsound');

    _registerEventHandlers();
  }

  void _registerEventHandlers() {
    _newButton.onClick.listen((_) {
      if(_ivrList != null) {
        int number = 1;
        String name = 'menu${number}';
        while(_ivrList.list.any((libIvr.Ivr i) => i.name == name)) {
          name = 'menu${++number}';
        }
        _ivrList.list.add(new libIvr.Ivr()..name = name);
        _renderMenuList(_ivrList);
        _madeChange = true;
      }
    });

    _closeButton.onClick.listen((_) {
      _hideWindow();
    });
  }

  void _hideWindow() {
    _element.classes.add('hidden');
    _returnFuture.complete(_madeChange);
  }

  void _showWindow() {
    _element.classes.remove('hidden');
  }

  /**
   * Loads a reception' IVR.
   *
   * Return whether there are made a change to the IVR menues.
   */
  Future<bool> loadReception(int receptionId, Dialplan dialplan, libIvr.IvrList ivrList) {
    this._dialplan = dialplan;
    this._ivrList = ivrList;
    _dialplanController.getAudiofileList(receptionId).then((List<ORModel.Audiofile> sounds) {
      this._receptionSounds = sounds;
    }).catchError((error, stack) {
      log.error('IVR.loadReception "${error}" "${stack}"');
      notify.error('Der skete en fejl da listen med lydfiler skulle hentes. Fejl: $error');
    });
    _clearContentTable();
    _renderMenuList(ivrList);
    _showWindow();
    _returnFuture = new Completer();
    return _returnFuture.future;
  }

  void _renderMenuList(libIvr.IvrList menus) {
    _menuList.children
      ..clear()
      ..addAll(menus.list.map(_makeMenuListItem));
  }

  void _HighlightItem(LIElement node) {
    _menuList.children.forEach((item) => item.classes.toggle('highlightListItem', item == node));
  }

  /**
   * Creates an item for the list of IVRs.
   */
  LIElement _makeMenuListItem(libIvr.Ivr item) {
    LIElement node = new LIElement();

    SpanElement text = new SpanElement()
      ..classes.add('clickable')
      ..text = item.name
      ..onClick.listen((_) {
        _HighlightItem(node);
        _loadIVR(item);
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
              _madeChange = true;
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
        _ivrList.list.remove(item);
        _renderMenuList(_ivrList);
        _madeChange = true;
      });

    node.children.addAll([text, editBox, editButton, deleteButton]);

    return node;
  }

  void _clearContentTable() {
    _contentBody.children.clear();
  }

  /**
   * Fills in the interface for that IVR menu.   *
   */
  void _loadIVR(libIvr.Ivr ivr) {
    List<String> digitss = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '*', '#'];
    _contentBody.children
      ..clear()
      ..addAll(digitss.map((String digit) => _ivrTableRow(digit, ivr)));

    _greetLongPicker.children
      ..clear()
      ..add(new OptionElement(data:'ingen', value: '', selected: ivr.greetingLong == null || ivr.greetingLong.trim().isEmpty))
      ..addAll(_receptionSounds.map((ORModel.Audiofile file) =>
        new OptionElement(data: file.shortname, value: file.filepath, selected: file.filepath == ivr.greetingLong)));

    _greetShortPicker.children
      ..clear()
      ..add(new OptionElement(data:'ingen', value: '', selected: ivr.greetingShort == null || ivr.greetingShort.trim().isEmpty))
      ..addAll(_receptionSounds.map((ORModel.Audiofile file) =>
        new OptionElement(data: file.shortname, value: file.filepath, selected: file.filepath == ivr.greetingShort)));

    _invalidSoundPicker.children
      ..clear()
      ..add(new OptionElement(data:'ingen', value: '', selected: ivr.invalidSound == null || ivr.invalidSound.trim().isEmpty))
      ..addAll(_receptionSounds.map((ORModel.Audiofile file) =>
        new OptionElement(data: file.shortname, value: file.filepath, selected: file.filepath == ivr.invalidSound)));

    _exitSoundPicker.children
      ..clear()
      ..add(new OptionElement(data:'ingen', value: '', selected: ivr.exitSound == null || ivr.exitSound.trim().isEmpty))
      ..addAll(_receptionSounds.map((ORModel.Audiofile file) =>
        new OptionElement(data: file.shortname, value: file.filepath, selected: file.filepath == ivr.exitSound)));

    _greetLongPicker.onChange.listen((_) => _madeChange = true);
    _greetShortPicker.onChange.listen((_) => _madeChange = true);
    _invalidSoundPicker.onChange.listen((_) => _madeChange = true);
    _exitSoundPicker.onChange.listen((_) => _madeChange = true);
  }

  /**
   * TODO find a better name, for the function that generates a row for the table in the middle of the screen.
   *       Or just find a better way of doing it.
   */
  TableRowElement _ivrTableRow(String digit, libIvr.Ivr ivr) {
    libIvr.Entry entry = ivr.entries.firstWhere((libIvr.Entry e) => e.digits == digit, orElse: () => null);

    TableRowElement row = new TableRowElement();
    TableCellElement digitCell = new TableCellElement()
      ..classes.add('ivr-dial-field')
      ..text = digit;

    TableCellElement parameterCell = new TableCellElement()
      ..children.add(_parametersForEntry(entry));

    List<OptionElement> actionList =
        [new OptionElement(data: 'Intet', value: 'none', selected: entry == null),
         new OptionElement(data: 'Send Til gruppe', value: 'extensiongroup', selected: entry != null)];
    SelectElement actionPicker = new SelectElement();
    actionPicker
      ..children.addAll(actionList)
      ..onChange.listen((_) {
      _madeChange = true;
      switch (actionPicker.selectedOptions.first.value) {
        case 'none':
          ivr.entries.remove(entry);
          entry = null;
          break;
        case 'extensiongroup':
          entry = new libIvr.Entry()
            ..digits = digit;
          ivr.entries.add(entry);
          break;
      }
      parameterCell.children
        ..clear()
        ..add(_parametersForEntry(entry));
    });

    TableCellElement actionCell = new TableCellElement()
      ..classes.add('ivr-action-field')
      ..children.add(actionPicker);

    return row
      ..children.addAll([digitCell, actionCell, parameterCell]);
  }

  DivElement _parametersForEntry(libIvr.Entry entry) {
    DivElement container = new DivElement();

    if(entry != null) {
      SelectElement gruops = new SelectElement();
      gruops
        ..children.addAll(_dialplan.extensionGroups.map((ExtensionGroup eg) =>
            new OptionElement(data: eg.name, value: eg.name, selected: entry.extensionGroup == eg.name)))
        ..onChange.listen((_) {
        _madeChange = true;
        entry.extensionGroup = gruops.selectedOptions.first.value;
      });

      LabelElement label = new LabelElement()
        ..htmlFor = 'ivr-${entry.digits}-group'
        ..text = 'Gruppe';

      if(entry.extensionGroup == null || entry.extensionGroup.isEmpty) {
        if(_dialplan.extensionGroups.isNotEmpty) {
          entry.extensionGroup = _dialplan.extensionGroups.first.name;
        }
      }

      container.children.addAll([label, gruops]);
    }

    return container;
  }
}