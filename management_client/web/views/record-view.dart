library record.view;

import 'dart:async';
import 'dart:html';

import '../lib/eventbus.dart';
import '../lib/logger.dart' as log;
import '../lib/model.dart';
import '../lib/request.dart' as request;
import '../lib/view_utilities.dart';
import '../notification.dart' as notify;

class RecordView {
  String viewName = 'record';
  DivElement element;

  List<Reception> receptions = [];
  UListElement receptionListUL;
  InputElement receptionSearchBox;
  LIElement highlightedReceptionLI;
  ButtonElement newRecording;
  TextInputElement newFileName;
  int selectedOrganizationId;
  int selectedReceptionId;
  UListElement fileListUL;

  RecordView(DivElement this.element) {
    receptionListUL = element.querySelector('#record-reception-list');
    receptionSearchBox = element.querySelector('#record-reception-search-box');
    newRecording = element.querySelector('#record-new-file-button');
    newFileName = element.querySelector('#record-new-file-name');

    fileListUL = element.querySelector('#record-file-list');

    refreshList();
    registrateEventHandlers();
  }

  void registrateEventHandlers() {
    receptionSearchBox.onInput.listen((_) => performSearch());

    bus.on(windowChanged).listen((Map event) {
      element.classes.toggle('hidden', event['window'] != viewName);
    });

    newRecording.onClick.listen((_) {
      String fileName = newFileName.value;
      if(fileName != null && fileName.trim().isNotEmpty) {
        if(selectedReceptionId != null && selectedReceptionId > 0) {
          request.recordSoundFile(selectedReceptionId, '${fileName}.wav').catchError((error) {
            notify.error('Der er skete en fejl med opringen.');
          });
        } else {
          notify.error('Der skal være valgt en reception før man kan starte optagelsen.');
        }
      } else {
        notify.error('Filnavnet må ikke være tomt.');
      }
    });
  }

  LIElement makeReceptionNode(Reception reception) {
    LIElement li = new LIElement();
    return li
      ..classes.add('clickable')
      ..dataset['receptionid'] = '${reception.id}'
      ..text = '${reception.full_name}'
      ..onClick.listen((_) {
        activateReception(reception.organization_id, reception.id);
      });
  }

  void performSearch() {
    String searchText = receptionSearchBox.value;
    List<Reception> filteredList = receptions.where((Reception recep) =>
        recep.full_name.toLowerCase().contains(searchText.toLowerCase())).toList();
    renderReceptionList(filteredList);
  }

  Future refreshList() {
    return request.getReceptionList().then((List<Reception> receptions) {
      receptions.sort(Reception.sortByName);
      this.receptions = receptions;
      performSearch();
    }).catchError((error) {
      log.error(
          'Failed to refreshing the list of receptions in reception window.');
    });
  }

  void renderReceptionList(List<Reception> receptions) {
    receptionListUL.children
        ..clear()
        ..addAll(receptions.map(makeReceptionNode));
  }

  void highlightContactInList(int id) {
    receptionListUL.children.forEach((LIElement li) => li.classes.toggle('highlightListItem', li.dataset['receptionid'] == '$id'));
  }

  void activateReception(int organization, int receptionId) {
    selectedOrganizationId = organization;
    selectedReceptionId = receptionId;

    highlightContactInList(receptionId);

    request.getAudiofileList(receptionId).then((List<Audiofile> files) {
      fileListUL.children.clear();
      fileListUL.children.addAll(files.map(makeAudioFileNode));
    }).catchError((error) {
      notify.error('activateReception: ${error}');
    });
  }

  LIElement makeAudioFileNode(Audiofile file) {
    LIElement li = new LIElement();

    SpanElement content = new SpanElement()
      ..text = file.shortname;
    InputElement editBox = new InputElement(type: 'text');

    editableSpan(content, editBox, () {
      //TODO save changes.
      notify.info(content.text);
    });

    ButtonElement play = new ButtonElement()
      ..text = 'Afspil'
      ..onClick.listen((_) {
      request.recordSoundFile(selectedReceptionId, file.shortname).catchError((error) {
        notify.error('Det skete en fejl i forbindelse med oprettelsen af opkaldet. ${error}');
      });
    });

    ButtonElement delete = new ButtonElement()
      ..text = 'Slet'
      ..onClick.listen((_) {
      request.deleteSoundFile(selectedReceptionId, file.shortname).then((_) {
        return activateReception(selectedOrganizationId, selectedReceptionId);
      }).catchError((error) {
        notify.error('Det skete en fejl, i forbindelse med sletningen af filen ${error}');
      });
    });

    /**
     * The Delete button is not rendered, because without any kind of check on
     * if the file is used, it will be too easy for the user to make a mistake.
     */
    li.children.addAll([play, content, editBox ]);

    return li;
  }
}
