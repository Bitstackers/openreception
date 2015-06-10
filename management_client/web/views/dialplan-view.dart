library dialplan.view;

import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:html5_dnd/html5_dnd.dart';

import '../lib/eventbus.dart';
import 'ivr-view.dart';
import '../lib/logger.dart' as log;
import '../lib/model.dart';
import '../lib/request.dart' as request;
import 'package:libdialplan/libdialplan.dart';
import 'package:libdialplan/ivr.dart';
import '../notification.dart' as notify;
import '../lib/searchcomponent.dart';
import '../lib/utilities.dart';

class _ControlLookUp {
  static const int TIME_CONTROL    = 0;
  static const int DATE_CONTROL    = 1;
  static const int TRANSFER        = 2;
  static const int RECEPTIONIST    = 3;
  static const int VOICEMAIL       = 4;
  static const int PLAY_AUDIO_FILE = 5;
  static const int IVR             = 6;
}

class _ControlImage {
  static const String bendedArrow = 'image/dialplan/bended_arrow.svg';
  static const String calendar    = 'image/dialplan/calendar.svg';
  static const String group       = 'image/dialplan/group.svg';
  static const String IVR         = 'image/dialplan/IVR.svg';
  static const String microphone  = 'image/dialplan/microphone.svg';
  static const String speaker     = 'image/dialplan/speaker.svg';
  static const String tape        = 'image/dialplan/tape.svg';
  static const String watch       = 'image/dialplan/watch.svg';
}

class DialplanView {
  static const String viewName = 'dialplan';
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
  ButtonElement compileButton;
  SpanElement extensionListHeader;

  SearchComponent<Reception> receptionPicker;
  Dialplan dialplan;
  Extension selectedExtension;
  List<Playlist> playlists;
  IvrList ivrMenus;

  List<DialplanTemplate> dialplanTemplates;
  SelectElement templatePicker;
  ButtonElement loadDialplanTemplate;

  ButtonElement showIvrView;
  IvrView ivrView;

  DialplanView(DivElement this.element) {
    controlListCondition = element.querySelector('#dialplan-control-condition-list');
    controlListAction    = element.querySelector('#dialplan-control-action-list');
    itemsList            = element.querySelector('#dialplan-items-body');
    extensionList        = element.querySelector('#dialplan-extension-list');
    extensionGroupAdd    = element.querySelector('#dialplan-extensiongroup-add');
    settingPanel         = element.querySelector('#dialplan-settings');
    commentTextarea      = element.querySelector('#dialplan-comment');
    saveButton           = element.querySelector('#dialplan-savebutton');
    compileButton        = element.querySelector('#dialplan-compile');
    extensionListHeader  = element.querySelector('#dialplan-extensionlist-header');
    templatePicker       = element.querySelector('#dialplan-templates');
    loadDialplanTemplate = element.querySelector('#dialplan-loadtemplate');
    showIvrView          = element.querySelector('#dialplan-showivr');

    receptionOuterSelector = element.querySelector('#dialplan-receptionbar');

    receptionPicker = new SearchComponent<Reception>(receptionOuterSelector, 'dialplan-reception-searchbox')
        ..listElementToString = receptionToSearchboxString
        ..searchFilter = receptionSearchHandler
        ..searchPlaceholder = 'Søg...';

    ivrView = new IvrView(element.querySelector('#ivr-page'));

    fillSearchComponent();
    fillDialplanTempalte();

    registrateEventHandlers();
  }

  void registrateEventHandlers() {
    bus.on(WindowChanged).listen((WindowChanged event) {
      element.classes.toggle('hidden', event.window != viewName);
      if (event.data.containsKey('receptionid')) {
        activateDialplan(event.data['receptionid']);
      }
    });

    receptionPicker.selectedElementChanged = SearchComponentChanged;

    saveButton.onClick.listen((_) {
      saveDialplan();
    });

    compileButton.onClick.listen((_) {
      compileDialplan();
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

        if(dialplan.startExtensionGroup == null || dialplan.startExtensionGroup.isEmpty) {
          dialplan.startExtensionGroup = group.name;
        }
        renderExtensionList(dialplan);
      }
    });

    extensionListHeader.onClick.listen((_) {
      if(dialplan != null) {
        settingsDialplan(dialplan);
      }
    });

    loadDialplanTemplate.onClick.listen((_) {
      if(selectedReceptionId != null && dialplan != null) {
        OptionElement selectTempalte = templatePicker.selectedOptions.first;
        DialplanTemplate template = dialplanTemplates.firstWhere((t) => t.id == int.parse(selectTempalte.value), orElse: () => null);
        if(template != null) {
          String groupName = '${template.template.name}${new DateTime.now().millisecondsSinceEpoch}';
          dialplan.extensionGroups.add(template.template
              ..name = groupName);
          if(dialplan.startExtensionGroup == null || dialplan.startExtensionGroup.trim().isEmpty) {
            dialplan.startExtensionGroup = groupName;
          }
          renderExtensionList(dialplan);
          enabledSaveButton();
        }
      }
    });

    showIvrView.onClick.listen((_) {
      ivrView.loadReception(selectedReceptionId, dialplan, ivrMenus)
      .then((bool changesMade) {
        if (changesMade) {
          enabledSaveButton();
        }
      });
    });
  }

  void SearchComponentChanged(Reception reception) {
    activateDialplan(reception.id);
  }

  String receptionToSearchboxString(Reception reception, String searchterm) {
    return '${reception.fullName}';
  }

  bool receptionSearchHandler(Reception reception, String searchTerm) {
    return reception.fullName.toLowerCase().contains(searchTerm.toLowerCase());
  }

  void fillSearchComponent() {
    request.getReceptionList().then((List<Reception> list) {
      list.sort();
      receptionPicker.updateSourceList(list);
    });
  }

  Future fillDialplanTempalte() {
    return request.getDialplanTemplates().then((List<DialplanTemplate> templates) {
      dialplanTemplates = templates;
      templatePicker.children.addAll(templates.map(templatePickerOption));
    });
  }

  OptionElement templatePickerOption(DialplanTemplate template) {
    return new OptionElement(data: template.template.name, value: template.id.toString());
  }

  void enableTemplateLoadButton() {
    loadDialplanTemplate.disabled = false;
  }

  void markAsCompiled(bool toggle) {
    compileButton.classes.toggle('dialplan-iscompiled', toggle);
    compileButton.classes.toggle('dialplan-isnotcompiled', !toggle);
  }

  void enabledCompile() {
    compileButton.disabled = false;
  }

  void disableCompile() {
    compileButton.disabled = true;
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
      enableTemplateLoadButton();
      disableSaveButton();
      enabledCompile();
      dialplan = value;
      selectedReceptionId = receptionId;
      renderExtensionList(value);
      activateExtension(null);
      markAsCompiled(dialplan.isCompiled);

      showIvrView.disabled = false;

      request.getPlaylistList().then((List<Playlist> list) {
            list.sort();
            playlists = list;
      }).catchError((error, stack) {
        log.error('activateDialplan() failed at fetching playlists. "${error}" \n"${stack}"');
        notify.error('Der skete en fejl i forbindelse med hentningen af ventemusik-afspilningslisterne. "${error}"');
      });

      request.getIvr(receptionId).then((IvrList list) {
        ivrMenus = list;
      }).catchError((error, stack) {
        log.error('activateDialplan() failed at fetching ivr menus. "${error}" \n"${stack}"');
        notify.error('Der skete en fejl i forbindelse med hentningen af IVR menuer. "${error}"');
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
        List<LIElement> liExtensions = group.extensions.map((Extension ext) => extensionListItem(ext, group)).toList();
        SortableGroup sortGroup = new SortableGroup()..installAll(liExtensions);
        sortGroup.accept.add(sortGroup);

        sortGroup.onSortUpdate.listen((SortableEvent event) {
          moveTo(group.extensions, event.originalPosition.index-1, event.newPosition.index-1);
          enabledSaveButton();
        });

        extensionList.children.addAll(liExtensions);
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
    extensions.add(new Extension()..name = genericName);
  }

  Future compileDialplan() {
    if (selectedReceptionId != null && selectedReceptionId > 0) {
      return request.markDialplanAsCompiled(selectedReceptionId).then((_) {
        dialplan.isCompiled = true;
        markAsCompiled(dialplan.isCompiled);
      });
    } else {
      return new Future.value();
    }
  }

  Future saveDialplan() {
    if (selectedReceptionId != null && selectedReceptionId > 0) {
      return request.updateDialplan(selectedReceptionId, JSON.encode(dialplan))
        .then((_) {
        notify.info('Dialplan er blevet opdateret.');
        bus.fire(new DialplanChangedEvent(selectedReceptionId));
        disableSaveButton();
        dialplan.isCompiled = false;
        markAsCompiled(dialplan.isCompiled);
      }).then((_) {
        return request.updateIvr(selectedReceptionId, JSON.encode(ivrMenus));
      }).catchError((error) {
        notify.error('Der skete en fejl i forbindelse med opdateringen af dialplanen.');
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
        case _ControlLookUp.TIME_CONTROL:
          Time condition = new Time();
          selectedExtension.conditions.add(condition);
          settingsConditionTime(condition);
          break;

        case _ControlLookUp.DATE_CONTROL:
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
        case _ControlLookUp.TRANSFER:
          Transfer action = new Transfer();
          selectedExtension.actions.add(action);
          settingsActionTransfer(action);
          break;

        case _ControlLookUp.RECEPTIONIST:
          Receptionists action = new Receptionists();
          selectedExtension.actions.add(action);
          settingsActionReceptionists(action);
          break;

        case _ControlLookUp.VOICEMAIL:
          Voicemail action = new Voicemail();
          selectedExtension.actions.add(action);
          settingsActionVoicemail(action);
          break;

        case _ControlLookUp.PLAY_AUDIO_FILE:
          PlayAudio action = new PlayAudio();
          selectedExtension.actions.add(action);
          settingsActionPlayAudio(action);
          break;

        case _ControlLookUp.IVR:
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

        if (action is Transfer) {
          image.src = _ControlImage.bendedArrow;
          nameTag.text = 'Viderstil';
          row.onClick.listen((_) {
            settingsActionTransfer(action);
          });
          if(action.type == TransferType.PHONE) {
            shortDescription.value = 'Nummer: ${nullBecomesEmpty(action.phoneNumber)}';
          } else if (action.type == TransferType.GROUP) {
            shortDescription.value = 'Gruppe: ${nullBecomesEmpty(action.extensionGroup)}';
          } else {
            shortDescription.value = '';
          }

        } else if (action is ExecuteIvr) {
          image.src = _ControlImage.IVR;
          nameTag.text = 'Ivrmenu';
          row.onClick.listen((_) {
            settingsActionExecuteIvr(action);
          });
          shortDescription.value = 'IVR: ${nullBecomesEmpty(action.ivrname)}';

        } else if (action is PlayAudio) {
          image.src = _ControlImage.speaker;
          nameTag.text = 'Afspil lyd';
          row.onClick.listen((_) {
            settingsActionPlayAudio(action);
          });
          shortDescription.value = 'Fil: ${nullBecomesEmpty(action.filename)}';

        } else if (action is Receptionists) {
          image.src = _ControlImage.group;
          nameTag.text = 'Receptionisterne';
          row.onClick.listen((_) {
            settingsActionReceptionists(action);
          });
          shortDescription.value =
              'VenteTid: ${action.sleepTime == null ? '' : action.sleepTime} sekund${action.sleepTime != null && action.sleepTime != 1 ? 'er' : ''}\nMusik: ${nullBecomesEmpty(action.music)}\nVelkomst: ${nullBecomesEmpty(action.welcomeFile)}';

        } else if (action is Voicemail) {
          image.src = _ControlImage.microphone;
          nameTag.text = 'Telefonsvare';
          row.onClick.listen((_) {
            settingsActionVoicemail(action);
          });
          shortDescription.value = 'Email: ${nullBecomesEmpty(action.email)}';

        } else {
          image.src = 'image/tp/red_plus.svg';
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
        renderContentList();
      });

    InputElement wdayInput = settingPanel.querySelector('#dialplan-setting-wday');
    wdayInput
      ..onInput.listen((_) {
        condition.wday = wdayInput.value;
        enabledSaveButton();
        renderContentList();
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
          renderContentList();
        });

      InputElement monthInput = settingPanel.querySelector('#dialplan-setting-month');
      monthInput
        ..onInput.listen((_) {
          condition.mon = monthInput.value.isEmpty ? null : monthInput.value;
          enabledSaveButton();
          renderContentList();
        });

      InputElement dayInput = settingPanel.querySelector('#dialplan-setting-day');
      dayInput
        ..onInput.listen((_) {
          condition.mday = dayInput.value.isEmpty ? null : dayInput.value;
          enabledSaveButton();
          renderContentList();
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
      renderContentList();
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
      renderContentList();
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

  void settingsActionTransfer(Transfer action) {
    clearSettingsPanel();
    String html = '''
    <ul class="dialplan-settingsList">
      <li>
        <fieldset id="dialplan-transfertype-phone-fieldset">
          <legend>
            <label for="dialplan-transfertype-phone">Telefon</label>
            <input id="dialplan-transfertype-phone" type="radio" name="dialplan-transfertype" value="true">
          </legend>
          <label for="dialplan-transfer-phone-input">Nummer</label>
          <input id="dialplan-transfer-phone-input" placeholder="70 12 14 16" type="text">
        </fieldset>
      </li>

      <li>
        <fieldset id="dialplan-transfertype-extensiongroup-fieldset">
          <legend>
            <label for="dialplan-transfertype-extensiongroup">Gruppe</label>
            <input id="dialplan-transfertype-extensiongroup" type="radio" name="dialplan-transfertype">
          </legend>
          <label for="dialplan-transfer-group-picker">Gruppe</label>
          <select id="dialplan-transfer-group-picker"></select>
        </fieldset>
      </li>
    </ul>
    ''';
    DocumentFragment fragment = new DocumentFragment.html(html);
    settingPanel.children.addAll(fragment.children);

    FieldSetElement transferTypePhoneFieldset = settingPanel.querySelector('#dialplan-transfertype-phone-fieldset');
    FieldSetElement transferTypeExtensionGroupFieldset = settingPanel.querySelector('#dialplan-transfertype-extensiongroup-fieldset');

    RadioButtonInputElement transferTypePhone = settingPanel.querySelector('#dialplan-transfertype-phone');
    RadioButtonInputElement transferTypeExtensionGroup = settingPanel.querySelector('#dialplan-transfertype-extensiongroup');

    Function updateDisables = () {
      //This can seems a little backwards, but it's because we set if it is disabled not enabled.
      transferTypePhoneFieldset.disabled = !transferTypePhone.checked;
      transferTypeExtensionGroupFieldset.disabled = !transferTypeExtensionGroup.checked;

      if(transferTypePhone.checked) {
        action.type = TransferType.PHONE;
      } else if(transferTypeExtensionGroup.checked) {
        action.type = TransferType.GROUP;
      }
    };

    transferTypePhone.onChange.listen((_) {
      updateDisables();
      enabledSaveButton();
      renderContentList();
    });

    transferTypeExtensionGroup.onChange.listen((_) {
      updateDisables();
      enabledSaveButton();
      renderContentList();
    });

    TextInputElement phoneNumberInput = settingPanel.querySelector('#dialplan-transfer-phone-input');
    phoneNumberInput.value = action.phoneNumber;
    phoneNumberInput.onInput.listen((_) {
      action.phoneNumber = phoneNumberInput.value;
      enabledSaveButton();
      renderContentList();
    });

    SelectElement groupPicker = settingPanel.querySelector('#dialplan-transfer-group-picker');
    groupPicker.children
      ..clear()
      ..addAll(dialplan.extensionGroups.map((ExtensionGroup g) => new OptionElement(data: g.name, value: g.name, selected: g.name == action.extensionGroup)));
    groupPicker.onChange.listen((_) {
      action.extensionGroup = groupPicker.selectedOptions.first.value;
      enabledSaveButton();
      renderContentList();
    });

    if(action.type == TransferType.GROUP) {
      transferTypeExtensionGroup.checked = true;
    } else {
      transferTypePhone.checked = true;
    }
    updateDisables();

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
          <select id="dialplan-setting-ivrname"></select>
      </li>
    </ul>
    ''';
    DocumentFragment fragment = new DocumentFragment.html(html);
    settingPanel.children.addAll(fragment.children);

    SelectElement ivrPicker = settingPanel.querySelector('#dialplan-setting-ivrname');
    ivrPicker
        ..onChange.listen((_) {
      action.ivrname = ivrPicker.value == '' ? null : ivrPicker.value;
      enabledSaveButton();
      renderContentList();
    });

    if(ivrMenus != null) {
      if(action.ivrname == null || action.ivrname.isEmpty) {
        action.ivrname = ivrMenus.list.first.name;
        renderContentList();
      }

      ivrPicker.children
        ..clear()
        ..addAll(ivrMenus.list.map((Ivr i) => new OptionElement(data: i.name, value: i.name.toString(), selected: action.ivrname == i.name)));
    }

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
        renderContentList();
      } catch(_) {}
    });

    SelectElement playlistPicker = settingPanel.querySelector('#dialplan-setting-music');
    playlistPicker
        ..onChange.listen((_) {
      action.music = playlistPicker.value == '' ? null : playlistPicker.value;
      enabledSaveButton();
      renderContentList();
    });

    if(playlists != null) {
      playlistPicker.children
        ..clear()
        ..addAll(playlists.map((Playlist p) => new OptionElement(data: p.name, value: p.name.toString(), selected: action.music == p.name)));
    }

    SelectElement welcomeFilePicker = settingPanel.querySelector('#dialplan-setting-welcome');
    welcomeFilePicker
        ..onChange.listen((_) {
      action.welcomeFile = welcomeFilePicker.value == '' ? null : welcomeFilePicker.value;
      enabledSaveButton();
      renderContentList();
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
        renderContentList();
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

  String nullBecomesEmpty(String item) => item == null ? '' : item;
}
