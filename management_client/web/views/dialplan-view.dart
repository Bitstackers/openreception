library dialplan.view;

import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:html5_dnd/html5_dnd.dart';

import '../lib/eventbus.dart';
import '../lib/logger.dart' as log;
import '../lib/model.dart';
import '../lib/request.dart' as request;
import 'package:libdialplan/libdialplan.dart';
import '../notification.dart' as notify;
import '../lib/searchcomponent.dart';

class _ControlLookUp {
  static const int timeControl = 0;
  static const int dateControl = 1;
  static const int forward = 2;
  static const int receptionist = 3;
  static const int voicemail = 4;
  static const int playAudioFile = 5;
  static const int ivr = 6;
}

class _ControlImage {
  static const String bendedArrow = 'image/dialplan/bended_arrow.svg';
  static const String calendar = 'image/dialplan/calendar.svg';
  static const String group = 'image/dialplan/group.svg';
  static const String IVR = 'image/dialplan/IVR.svg';
  static const String microphone = 'image/dialplan/microphone.svg';
  static const String speaker = 'image/dialplan/speaker.svg';
  static const String tape = 'image/dialplan/tape.svg';
  static const String watch = 'image/dialplan/watch.svg';
}

class DialplanView {
  String viewName = 'dialplan';
  int selectedReceptionId;

  DivElement element;
  OListElement controlListCondition, controlListAction;
  TableSectionElement itemsList;
  UListElement extensionList;
  ImageElement extensionGroupAdd;
  DivElement settingPanel;
  TextAreaElement commentTextarea;
  StreamSubscription<Event> commentTextSubscription;
  DivElement receptionOuterSelector;
  ButtonElement saveButton;
  SpanElement extensionListHeader;

  SearchComponent receptionPicker;
  Dialplan dialplan;
  Extension selectedExtension;
  List<Playlist> playlists;

  DialplanView(DivElement this.element) {
    controlListCondition = element.querySelector('#dialplan-control-condition-list');
    controlListAction = element.querySelector('#dialplan-control-action-list');
    itemsList = element.querySelector('#dialplan-items-body');
    extensionList = element.querySelector('#dialplan-extension-list');
    extensionGroupAdd = element.querySelector('#dialplan-extensiongroup-add');
    settingPanel = element.querySelector('#dialplan-settings');
    commentTextarea = element.querySelector('#dialplan-comment');
    saveButton = element.querySelector('#dialplan-savebutton');
    extensionListHeader = element.querySelector('#dialplan-extensionlist-header');

    receptionOuterSelector = element.querySelector('#dialplan-receptionbar');

    receptionPicker = new SearchComponent<Reception>(receptionOuterSelector,
        'dialplan-reception-searchbox')
        ..listElementToString = receptionToSearchboxString
        ..searchFilter = receptionSearchHandler;

    fillSearchComponent();

    registrateEventHandlers();
  }

  void registrateEventHandlers() {
    bus.on(windowChanged).listen((Map event) {
      element.classes.toggle('hidden', event['window'] != viewName);
      if (event.containsKey('receptionid')) {
        activateDialplan(event['receptionid']);
      }
    });

    receptionPicker.selectedElementChanged = SearchComponentChanged;

    saveButton.onClick.listen((_) {
      saveDialplan();
    });

    controlListCondition.children.forEach((LIElement li) {
      li.onClick.listen((_) => handleControlConditionClick(li.value));
    });

    controlListAction.children.forEach((LIElement li) {
      li.onClick.listen((_) => handleControlActionClick(li.value));
    });

    extensionGroupAdd.onClick.listen((_) {
      if (dialplan != null) {
        enabledSaveButton();
        Extension newExtension = new Extension();

        //Find a new extension name that is not taken.
        int count = 1;
        String genericName = 'gruppe${count}';
        while (dialplan.extensionGroups.any((group) => group.name == genericName)) {
          count += 1;
          genericName = 'gruppe${count}';
        }
        ExtensionGroup group = new ExtensionGroup(name: genericName);
        dialplan.extensionGroups.add(group);
        renderExtensionList(dialplan);
      }
    });

    extensionListHeader.onClick.listen((_) {
      if(dialplan != null) {
        settingsDialplan(dialplan);
      }
    });
  }

  void SearchComponentChanged(Reception reception) {
    activateDialplan(reception.id);
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

  void enabledSaveButton() {
    saveButton.disabled = false;
  }

  void disableSaveButton() {
    saveButton.disabled = true;
  }

  void activateDialplan(int receptionId) {
    receptionPicker.selectElement(null, (Reception a, _) => a.id == receptionId);

    request.getDialplan(receptionId).then((Dialplan value) {
      disableSaveButton();
      dialplan = value;
      selectedReceptionId = receptionId;
      renderExtensionList(value);
      activateExtension(null);

      return request.getPlaylistList().then((List<Playlist> list) {
            list.sort(Playlist.sortByName);
            playlists = list;
      }).catchError((error, stack) {
        log.error('activateDialplan() failed at fetching playlists. "${error}" \n"${stack}"');
        notify.error('Der skete en fejl i forbindelse med hentningen af ventemusik-afspilningslisterne. "${error}"');
      });
    }).catchError((error, stack) {
      log.error('activateDialplan() failed at fetching the dialplan. "${error}" \n"${stack}"');
      notify.error('Der skete en fejl i forbindelse med heningen af kaldplaner. "${error}"');
    });
  }

  void renderExtensionList(Dialplan dialplan) {
    extensionList.children.clear();
    if (dialplan != null && dialplan.extensionGroups != null) {
      for(ExtensionGroup group in dialplan.extensionGroups) {
        extensionList.children.add(_makeGroupListItem(group));

        extensionList.children.addAll(group.extensions.map((ext) => extensionListItem(ext, group)));
      }
    }
  }

  LIElement _makeGroupListItem(ExtensionGroup group) {
    ImageElement addButton = new ImageElement(src: 'image/tp/plus.svg')
      ..classes.add('dialplan-extension-add-icon')
      ..onClick.listen((_) {
        addNewExtension(group);
        renderExtensionList(dialplan);
      });

    ImageElement removeButton = new ImageElement(src: 'image/tp/red_plus.svg')
      ..classes.add('dialplan-extension-add-icon')
      ..onClick.listen((_) {
        dialplan.extensionGroups.remove(group);
        renderExtensionList(dialplan);
      });

    SpanElement text = new SpanElement()
      ..text = group.name
      ..onClick.listen((_) {
        settingsExtensionGroup(group);
      });

    LIElement li = new LIElement()
      ..classes.add('dialplan-extension-list-group')
      ..children.addAll([addButton, removeButton, text]);
    return li;
  }

  void addNewExtension(ExtensionGroup group) {
    List<Extension> extensions = group.extensions;
      //Find a new extension name that is not taken.
    int count = 1;
    String genericName = 'extension${count}';
    while (extensions.any((extension) => extension.name == genericName)) {
      count += 1;
      genericName = 'extension${count}';
    }
    extensions.add(new Extension()
                     ..name = genericName);
  }

  Future saveDialplan() {
    if (selectedReceptionId != null && selectedReceptionId > 0) {
      return request.updateDialplan(selectedReceptionId, JSON.encode(dialplan))
        .then((_) {
        notify.info('Dialplan er blevet updateret.');
        Map event = {'id': selectedReceptionId};
        bus.fire(Invalidate.dialplanChanged, event);
        disableSaveButton();
      }).catchError((error) {
        notify.error('Der skete en fejl i forbindelse med updateringen af dialplanen.');
        log.error('Update Dialplan gave ${error}');
      });
    } else {
      return new Future.value();
    }
  }

  LIElement extensionListItem(Extension extension, ExtensionGroup group) {
    LIElement li = new LIElement()
      ..classes.add('dialplan-extension-list-item');

    ImageElement deleteButton = new ImageElement(src: 'image/tp/red_plus.svg')
      ..classes.add('dialplan-extension-add-icon')
      ..onClick.listen((_) {
        group.extensions.remove(extension);
        renderExtensionList(dialplan);
        clearSettingsPanel();
        enabledSaveButton();
      });
    SpanElement text = new SpanElement()
      ..text = '${extension.name}'
      ..onClick.listen((_) {
        activateExtension(extension);
      });
    li.children.addAll([deleteButton, text]);
    return li;
  }

  /**
   * Inserts a new condition to the selected Extension based on the number.
   **/
  void handleControlConditionClick(int value) {
    if (selectedExtension != null) {
      switch (value) {
        case _ControlLookUp.timeControl:
          Time condition = new Time();
          selectedExtension.conditions.add(condition);
          settingsConditionTime(condition);
          break;

        case _ControlLookUp.dateControl:
          Date condition = new Date();
          selectedExtension.conditions.add(condition);
          settingsConditionDate(condition);
          break;
      }

      enabledSaveButton();
      renderContentList();
    }
  }

  void handleControlActionClick(int value) {
    if (selectedExtension != null) {
      switch (value) {
        case _ControlLookUp.forward:
          Forward action = new Forward();
          selectedExtension.actions.add(action);
          settingsActionForward(action);
          break;

        case _ControlLookUp.receptionist:
          Receptionists action = new Receptionists();
          selectedExtension.actions.add(action);
          settingsActionReceptionists(action);
          break;

        case _ControlLookUp.voicemail:
          Voicemail action = new Voicemail();
          selectedExtension.actions.add(action);
          settingsActionVoicemail(action);
          break;

        case _ControlLookUp.playAudioFile:
          PlayAudio action = new PlayAudio();
          selectedExtension.actions.add(action);
          settingsActionPlayAudio(action);
          break;

        case _ControlLookUp.ivr:
          ExecuteIvr action = new ExecuteIvr();
          selectedExtension.actions.add(action);
          settingsActionExecuteIvr(action);
          break;
      }

      enabledSaveButton();
      renderContentList();
    }
  }

  void renderSelectedExtensionActions() {
    if(selectedExtension != null) {
      for (Action action in selectedExtension.actions) {

        ImageElement image = new ImageElement()
          ..classes.add('dialplan-controlitem-img');
        ImageElement remove = new ImageElement(src: 'image/cross.png')
          ..classes.add('dialplan-controlremove')
          ..title = 'Fjern'
          ..onClick.listen((MouseEvent event) {
          event.stopPropagation();
          selectedExtension.actions.remove(action);
          clearSettingsPanel();
          activateExtension(selectedExtension);
          enabledSaveButton();
        });
        SpanElement nameTag = new SpanElement();

        TextAreaElement shortDescription = new TextAreaElement()
          ..readOnly = true
          ..classes.add('dialplan-controlitem-description');

        TableRowElement row = new TableRowElement()
            ..classes.add('clickable');
        row.children.addAll(
          [new TableCellElement()..children.addAll([image, nameTag])..classes.add('dialplan-item-image'),
           new TableCellElement()..children.add(shortDescription)..classes.add('dialplan-item-description'),
           new TableCellElement()..children.add(remove)..classes.add('dialplan-item-remove')
          ]);

        itemsList.children.add(row);

        if (action is Forward) {
          image.src = _ControlImage.bendedArrow;
          nameTag.text = 'Viderstil';
          row.onClick.listen((_) {
            settingsActionForward(action);
          });
          shortDescription.value = 'Nummer: ${action.number}';

        } else if (action is ExecuteIvr) {
          image.src = _ControlImage.IVR;
          nameTag.text = 'Ivrmenu';
          row.onClick.listen((_) {
            settingsActionExecuteIvr(action);
          });
          shortDescription.value = 'IVR: ${action.ivrname}';

        } else if (action is PlayAudio) {
          image.src = _ControlImage.speaker;
          nameTag.text = 'Afspil lyd';
          row.onClick.listen((_) {
            settingsActionPlayAudio(action);
          });
          shortDescription.value = 'Fil: ${action.filename}';

        } else if (action is Receptionists) {
          image.src = _ControlImage.group;
          nameTag.text = 'Receptionisterne';
          row.onClick.listen((_) {
            settingsActionReceptionists(action);
          });
          shortDescription.value =
              'VenteTid: ${action.sleepTime}\nMusik: ${action.music}\nVelkomst: ${action.welcomeFile}';

        } else if (action is Voicemail) {
          image.src = _ControlImage.microphone;
          nameTag.text = 'Telefonsvare';
          row.onClick.listen((_) {
            settingsActionVoicemail(action);
          });
          shortDescription.value = 'Email: ${action.email}';

        } else {
          image.src = 'image/organization_icon_disable.svg';
          nameTag.text = 'Ukendt';
        }
      }
    }
  }

  void renderSelectedExtensionCondition() {
    if(selectedExtension != null) {
      for (Condition condition in selectedExtension.conditions) {
        ImageElement image = new ImageElement()
          ..classes.add('dialplan-controlitem-img');

        SpanElement nameTag = new SpanElement();

        ImageElement remove = new ImageElement(src: 'image/cross.png')
          ..classes.add('dialplan-controlremove')
          ..title = 'Fjern'
          ..onClick.listen((MouseEvent event) {
            event.stopPropagation();
            selectedExtension.conditions.remove(condition);
            clearSettingsPanel();
            activateExtension(selectedExtension);
            enabledSaveButton();
        });

        TextAreaElement shortDescription = new TextAreaElement()
          ..readOnly = true
          ..classes.add('dialplan-controlitem-description')
          ..value = 'This is the first line where some of the description will be. \n And this is the second';

        TableRowElement row = new TableRowElement()
          ..classes.add('clickable');
        row.children.addAll(
            [new TableCellElement()..children.addAll([image, nameTag])..classes.add('dialplan-item-image'),
             new TableCellElement()..children.add(shortDescription)..classes.add('dialplan-item-description'),
             new TableCellElement()..children.add(remove)..classes.add('dialplan-item-remove')
            ]);

        itemsList.children.add(row);

        if (condition is Time) {
          image.src = _ControlImage.watch;
          nameTag.text = 'Tidsstyring';

          row.onClick.listen((_) {
            settingsConditionTime(condition);
          });
          shortDescription.value =
              'Ugedage: ${condition.wday}\nTid: ${condition.timeOfDay}';

        } else if(condition is Date) {
          image.src = _ControlImage.calendar;
          nameTag.text = 'Datostyring';

          row.onClick.listen((_) {
              settingsConditionDate(condition);
          });
          shortDescription.value =
               'Dato: ${condition.year}-${condition.mon}-${condition.mday}';
        }
      }
    }
  }

  void activateExtension(Extension extension) {
    selectedExtension = extension;
    updateSelectedExtensionName(extension);
    clearSettingsPanel();
    if (extension != null) {
      settingsExtension(extension);
    }
    renderContentList();
  }

  void updateSelectedExtensionName(Extension extension) {
    element.querySelector('#dialplan-selected-extensionname')
      ..text = extension != null ? extension.name : '';
  }

  void renderContentList() {
    itemsList.children.clear();
    renderSelectedExtensionCondition();
    renderSelectedExtensionActions();
  }

  void clearSettingsPanel() {
    settingPanel.children.clear();
  }

  void settingsDialplan(Dialplan dialplan) {
    clearSettingsPanel();
    String html = '''
      <ul class="dialplan-settingsList">
        <li>
            <label for="dialplan-setting-dialplan-startextension">Start gruppe</label>
            <select id="dialplan-setting-dialplan-startextension"></select>
        </li>
      </ul>
    ''';

    DocumentFragment fragment = new DocumentFragment.html(html);
    settingPanel.children.addAll(fragment.children);

    SelectElement startGroupInput = settingPanel.querySelector('#dialplan-setting-dialplan-startextension');
    startGroupInput
      ..onChange.listen((_) {
        dialplan.startExtensionGroup = startGroupInput.value;
        enabledSaveButton();
    });

    bool foundSelected = false;
    for(ExtensionGroup group in dialplan.extensionGroups) {
      bool Selected = dialplan.startExtensionGroup == group.name;
      if(Selected) {
        foundSelected = true;
      }
      startGroupInput.children.add(new OptionElement(data: group.name, value: group.name, selected: Selected));
    }

    if(!foundSelected) {
      OptionElement firstOption = startGroupInput.options.first;
      firstOption.selected = true;
      dialplan.startExtensionGroup = firstOption.value;
      enabledSaveButton();
    }

    commentTextarea.value = dialplan.comment;
    if(commentTextSubscription != null) {
      commentTextSubscription.cancel();
    }
    commentTextSubscription = commentTextarea.onInput.listen((_) {
      dialplan.comment = commentTextarea.value;
      enabledSaveButton();
    });
  }

  void settingsExtensionGroup(ExtensionGroup group) {
    final bool isStartGroup = dialplan.startExtensionGroup == group.name;
    clearSettingsPanel();
    String html = '''
      <ul class="dialplan-settingsList">
        <li>
            <label for="dialplan-setting-extensiongroupname">Navn</label>
            <input id="dialplan-setting-extensiongroupname" type="text" value="${group.name != null ? group.name : ''}">
        </li>
      </ul>
    ''';

    DocumentFragment fragment = new DocumentFragment.html(html);
    settingPanel.children.addAll(fragment.children);

    InputElement nameInput = settingPanel.querySelector('#dialplan-setting-extensiongroupname');
    nameInput
      ..onInput.listen((_) {
        group.name = nameInput.value;
        if(isStartGroup) {
          dialplan.startExtensionGroup = group.name;
        }
        renderExtensionList(dialplan);
        enabledSaveButton();
    })
    ..onInvalid.listen((_) {
      nameInput.title = nameInput.validationMessage;
    });

    commentTextarea.value = group.comment;
    if(commentTextSubscription != null) {
      commentTextSubscription.cancel();
    }
    commentTextSubscription = commentTextarea.onInput.listen((_) {
      group.comment = commentTextarea.value;
      enabledSaveButton();
    });
  }

  void settingsExtension(Extension extension) {
    clearSettingsPanel();
      String html = '''
      <ul class="dialplan-settingsList">
        <li>
            <label for="dialplan-setting-extensionname">Navn</label>
            <input id="dialplan-setting-extensionname" type="text" value="${extension.name != null ? extension.name : ''}">
        </li>
      </ul>
      ''';

      DocumentFragment fragment = new DocumentFragment.html(html);
      settingPanel.children.addAll(fragment.children);

      InputElement nameInput = settingPanel.querySelector('#dialplan-setting-extensionname');
      nameInput
        ..onInput.listen((_) {
        extension.name = nameInput.value;
        renderExtensionList(dialplan);
        updateSelectedExtensionName(extension);
        enabledSaveButton();
      })
      ..onInvalid.listen((_) {
        nameInput.title = nameInput.validationMessage;
      });

      commentTextarea.value = extension.comment;
      if(commentTextSubscription != null) {
        commentTextSubscription.cancel();
      }
      commentTextSubscription = commentTextarea.onInput.listen((_) {
        extension.comment = commentTextarea.value;
        enabledSaveButton();
      });
    }

  void settingsConditionTime(Time condition) {
    clearSettingsPanel();

    String html = '''
    <ul class="dialplan-settingsList">
      <li>
          <label for="dialplan-setting-timeofday">Time Of day</label>
          <input id="dialplan-setting-timeofday" type="text" value="${condition.timeOfDay != null ? condition.timeOfDay : ''}" placeholder="08:00-17:00">
      </li>
      <li>
          <label for="dialplan-setting-wday">Ugedage</label>
          <input id="dialplan-setting-wday" type="text" 
                 value="${condition.wday != null ? condition.wday : ''}" 
                 placeholder="mon-tue, wed, thu, fri-sat, sun" 
                 title="mon, tue, wed, thu, fri, sat, sun">
      </li>
    </ul>
    ''';
    DocumentFragment fragment = new DocumentFragment.html(html);
    settingPanel.children.addAll(fragment.children);

    InputElement timeOfDayInput = settingPanel.querySelector('#dialplan-setting-timeofday');
    timeOfDayInput
      ..onInput.listen((_) {
        condition.timeOfDay = timeOfDayInput.value.isEmpty ? null : timeOfDayInput.value;
        enabledSaveButton();
        renderContentList(); //TODO TESTING
      });

    InputElement wdayInput = settingPanel.querySelector('#dialplan-setting-wday');
    wdayInput
      ..onInput.listen((_) {
        condition.wday = wdayInput.value;
        enabledSaveButton();
        renderContentList(); //TODO TESTING
    });

    commentTextarea.value = condition.comment;
    if(commentTextSubscription != null) {
      commentTextSubscription.cancel();
    }
    commentTextSubscription = commentTextarea.onInput.listen((_) {
      condition.comment = commentTextarea.value;
      enabledSaveButton();
    });
  }

  void settingsConditionDate(Date condition) {
      clearSettingsPanel();

      String html = '''
      <ul class="dialplan-settingsList">
        <li>
            <label for="dialplan-setting-year">År</label>
            <input id="dialplan-setting-year" type="text" value="${condition.year != null ? condition.year : ''}" placeholder="${new DateTime.now().year}">
        </li>
        <li>
            <label for="dialplan-setting-month">Måned</label>
            <input id="dialplan-setting-month" type="text" value="${condition.mon != null ? condition.mon : ''}" placeholder="${new DateTime.now().month}">
        </li>
        <li>
            <label for="dialplan-setting-day">Dag</label>
            <input id="dialplan-setting-day" type="text" value="${condition.mday != null ? condition.mday : ''}" placeholder="${new DateTime.now().day}">
        </li>
      </ul>
      ''';

      DocumentFragment fragment = new DocumentFragment.html(html);
      settingPanel.children.addAll(fragment.children);

      InputElement yearInput = settingPanel.querySelector('#dialplan-setting-year');
      yearInput
        ..onInput.listen((_) {
          condition.year = yearInput.value.isEmpty ? null : yearInput.value;
          enabledSaveButton();
        });

      InputElement monthInput = settingPanel.querySelector('#dialplan-setting-month');
      monthInput
        ..onInput.listen((_) {
          condition.mon = monthInput.value.isEmpty ? null : monthInput.value;
          enabledSaveButton();
        });

      InputElement dayInput = settingPanel.querySelector('#dialplan-setting-day');
      dayInput
        ..onInput.listen((_) {
          condition.mday = dayInput.value.isEmpty ? null : dayInput.value;
          enabledSaveButton();
        });

      commentTextarea.value = condition.comment;
      if(commentTextSubscription != null) {
        commentTextSubscription.cancel();
      }
      commentTextSubscription = commentTextarea.onInput.listen((_) {
        condition.comment = commentTextarea.value;
        enabledSaveButton();
      });
    }

  void settingsActionPlayAudio(PlayAudio action) {
    clearSettingsPanel();
    String html = '''
    <ul class="dialplan-settingsList">
      <li>
          <label>Lydfil</label>
          <select id="dialplan-setting-audiofilelist"></select>
      </li>
    </ul>
    ''';
    DocumentFragment fragment = new DocumentFragment.html(html);
    settingPanel.children.addAll(fragment.children);

    SelectElement audiofiledropdown = settingPanel.querySelector('#dialplan-setting-audiofilelist');
    audiofiledropdown
        ..onChange.listen((_) {
      action.filename = audiofiledropdown.value;
      enabledSaveButton();
    });
    request.getAudiofileList(selectedReceptionId).then((List<Audiofile> files) {
      //Give it the first as default.
      if((action.filename == null || action.filename.isEmpty) && files.isNotEmpty) {
        action.filename = files.first.filepath;
      }
      for(Audiofile file in files) {
        OptionElement option = new OptionElement()
          ..value = file.filepath
          ..text = file.shortname;
        if(action.filename == file.filepath) {
          option.selected = true;
        }
        audiofiledropdown.children.add(option);
      }
    });

    commentTextarea.value = action.comment;
    if(commentTextSubscription != null) {
      commentTextSubscription.cancel();
    }
    commentTextSubscription = commentTextarea.onInput.listen((_) {
      action.comment = commentTextarea.value;
      enabledSaveButton();
    });
  }

  void settingsActionForward(Forward action) {
    clearSettingsPanel();
    String html = '''
    <ul class="dialplan-settingsList">
      <li>
          <label for="dialplan-setting-number">Nummer</label>
          <input id="dialplan-setting-number" type="text" value="${action.number != null ? action.number : ''}"/>
      </li>
    </ul>
    ''';
    DocumentFragment fragment = new DocumentFragment.html(html);
    settingPanel.children.addAll(fragment.children);

    InputElement numberInput = settingPanel.querySelector('#dialplan-setting-number');
    numberInput
        ..onInput.listen((_) {
      action.number = numberInput.value;
      enabledSaveButton();
    });

    commentTextarea.value = action.comment;
    if(commentTextSubscription != null) {
      commentTextSubscription.cancel();
    }
    commentTextSubscription = commentTextarea.onInput.listen((_) {
      action.comment = commentTextarea.value;
      enabledSaveButton();
    });
  }

  void settingsActionExecuteIvr(ExecuteIvr action) {
    clearSettingsPanel();
    String html = '''
    <ul class="dialplan-settingsList">
      <li>
          <label for="dialplan-setting-ivrname">Ivr menu</label>
          <input id="dialplan-setting-ivrname" type="text" value="${action.ivrname != null ? action.ivrname : ''}"/>
      </li>
    </ul>
    ''';
    DocumentFragment fragment = new DocumentFragment.html(html);
    settingPanel.children.addAll(fragment.children);

    InputElement ivrnameInput = settingPanel.querySelector('#dialplan-setting-ivrname');
    ivrnameInput
        ..onInput.listen((_) {
      action.ivrname = ivrnameInput.value;
      enabledSaveButton();
    });

    commentTextarea.value = action.comment;
    if(commentTextSubscription != null) {
      commentTextSubscription.cancel();
    }
    commentTextSubscription = commentTextarea.onInput.listen((_) {
      action.comment = commentTextarea.value;
      enabledSaveButton();
    });
  }

  void settingsActionReceptionists(Receptionists action) {
    clearSettingsPanel();
    String html = '''
    <ul class="dialplan-settingsList">
      <li>
          <label for="dialplan-setting-sleeptime">Ventetid</label>
          <input id="dialplan-setting-sleeptime" type="number" min="0" value="${action.sleepTime != null ? action.sleepTime : ''}"/>
      </li>
      <li>
          <label for="dialplan-setting-music">Music</label>
          <select id="dialplan-setting-music"></select>
      </li>
      <li>
          <label for="dialplan-setting-welcome">Velkomstbesked</label>
          <select id="dialplan-setting-welcome">
            <option value="">Ingen</option>
          </select>
      </li>
    </ul>
    ''';
    DocumentFragment fragment = new DocumentFragment.html(html);
    settingPanel.children.addAll(fragment.children);

    NumberInputElement sleepTimeInput = settingPanel.querySelector('#dialplan-setting-sleeptime');
    sleepTimeInput
        ..onInput.listen((_) {
      try {
        int sleepTime = int.parse(sleepTimeInput.value);
        action.sleepTime = sleepTime;
        enabledSaveButton();
      } catch(_) {}
    });

    SelectElement playlistPicker = settingPanel.querySelector('#dialplan-setting-music');
    playlistPicker
        ..onChange.listen((_) {
      action.music = playlistPicker.value == '' ? null : playlistPicker.value;
      enabledSaveButton();
    });

    if(playlists != null) {
      playlistPicker.children
        ..clear()
        ..addAll(playlists.map((p) => new OptionElement(data: p.name, value: p.name.toString(), selected: action.music == p.name)));
    }

    SelectElement welcomeFilePicker = settingPanel.querySelector('#dialplan-setting-welcome');
    welcomeFilePicker
        ..onChange.listen((_) {
      action.welcomeFile = welcomeFilePicker.value == '' ? null : welcomeFilePicker.value;
      enabledSaveButton();
    });

    request.getAudiofileList(selectedReceptionId).then((List<Audiofile> files) {
      bool found = false;
      for(Audiofile file in files) {
        OptionElement option = new OptionElement()
          ..value = file.filepath
          ..text = file.shortname;
        if(action.welcomeFile == file.filepath) {
          option.selected = true;
          found = true;
        }
        welcomeFilePicker.children.add(option);
      }
      if(found == false) {
        action.welcomeFile = null;
      }
    });

    commentTextarea.value = action.comment;
    if(commentTextSubscription != null) {
      commentTextSubscription.cancel();
    }
    commentTextSubscription = commentTextarea.onInput.listen((_) {
      action.comment = commentTextarea.value;
      enabledSaveButton();
    });
  }

  void settingsActionVoicemail(Voicemail action) {
    clearSettingsPanel();
    String html = '''
    <ul class="dialplan-settingsList">
      <li>
          <label for="dialplan-setting-email">Email</label>
          <input id="dialplan-setting-email" type="text" value="${action.email != null ? action.email : ''}"/>
      </li>
    </ul>
    ''';
    DocumentFragment fragment = new DocumentFragment.html(html);
    settingPanel.children.addAll(fragment.children);

    InputElement emailInput = settingPanel.querySelector('#dialplan-setting-email');
    emailInput
        ..onInput.listen((_) {
        action.email = emailInput.value;
        enabledSaveButton();
    });

    commentTextarea.value = action.comment;
    if(commentTextSubscription != null) {
      commentTextSubscription.cancel();
    }
    commentTextSubscription = commentTextarea.onInput.listen((_) {
      action.comment = commentTextarea.value;
      enabledSaveButton();
    });
  }
}
