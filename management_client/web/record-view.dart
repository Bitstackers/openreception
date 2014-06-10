library record_view;

import 'dart:async';
import 'dart:html';
import 'dart:convert';

import 'lib/eventbus.dart';
import 'lib/logger.dart' as log;
import 'lib/model.dart';
import 'lib/request.dart' as request;
import 'lib/view_utilities.dart';
import 'notification.dart' as notify;

class RecordView {
  String viewName = 'record';
  DivElement element;

  List<Reception> receptions = [];
  UListElement receptionListUL;
  InputElement receptionSearchBox;
  LIElement highlightedReceptionLI;

  UListElement fileListUL;

  RecordView(DivElement this.element) {
    receptionListUL = element.querySelector('#record-reception-list');
    receptionSearchBox = element.querySelector('#record-reception-search-box');

    fileListUL = element.querySelector('#record-file-list');

    refreshList();
    registrateEventHandlers();
  }

  void registrateEventHandlers() {
    receptionSearchBox.onInput.listen((_) => performSearch());
  }

  LIElement makeReceptionNode(Reception reception) {
    LIElement li = new LIElement();
    return li
      ..classes.add('clickable')
      ..value = reception.id //TODO Er den brugt?
      ..text = '${reception.full_name}'
      ..onClick.listen((_) {
        if(highlightedReceptionLI != null) {
          highlightedReceptionLI.classes.remove('highlightedLI');
        }
        highlightedReceptionLI = li;
        li.classes.add('highlightedLI');
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
      receptions.sort((a, b) => a.full_name.compareTo(b.full_name));
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

  void activateReception(int organization, int reception) {
    //TODO DO SOMETHING
    notify.info('Activated: ${organization} / ${reception}');

    request.getAudiofileList(reception).then((List<Audiofile> files) {
      fileListUL.children.clear();
      fileListUL.children.addAll(files.map(makeAudioFileNode));
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
      notify.info('Listen carefully. \n ${file.filepath}');
    });

    li.children.addAll([content, editBox, play]);

    return li;
  }
}
