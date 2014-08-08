library music.view;

import 'dart:async';
import 'dart:convert';
import 'dart:html';

import '../lib/logger.dart' as log;
import '../lib/eventbus.dart';
import '../lib/model.dart';
import '../notification.dart' as notify;
import '../lib/request.dart';

class MusicView {
  static const String viewName = 'music';
  DivElement element;
  ButtonElement buttonNew, buttonSave, ButtonDelete;
  UListElement UlPlaylist;

  TextInputElement name, path;
  CheckboxInputElement shuffle, channels;
  NumberInputElement interval;

  bool isCreatingNewPlaylist = false;
  int selectedPlaylistId;

  MusicView(DivElement this.element) {
    buttonNew = element.querySelector('#music-new');
    buttonSave = element.querySelector('#music-save');
    ButtonDelete = element.querySelector('#music-delete');
    UlPlaylist = element.querySelector('#music-playlists');

    name = element.querySelector('#music-name');
    path = element.querySelector('#music-path');
    shuffle = element.querySelector('#music-shuffle');
    channels = element.querySelector('#music-channels');
    interval = element.querySelector('#music-interval');

    registrateEventHandlers();
    refresh();
  }

  Future activatePlaylist(int id) {
    return getPlaylist(id).then((Playlist playlist) {
      isCreatingNewPlaylist = false;
      selectedPlaylistId = id;

      name.value = playlist.name;
      path.value = playlist.path;
      shuffle.checked = playlist.shuffle;
      channels.checked = playlist.channels != 1;
      interval.value = playlist.interval.toString();

      highlightPlaylistItem(id);
    });
  }

  void registrateEventHandlers() {
    bus.on(windowChanged).listen((Map event) {
      element.classes.toggle('hidden', event['window'] != viewName);
    });

    bus.on(Invalidate.playlistAdded).listen((Map event) {
      refresh().then((_) {
        if(!isCreatingNewPlaylist && selectedPlaylistId != null) {
          highlightPlaylistItem(selectedPlaylistId);
        }
      });
    });

    bus.on(Invalidate.playlistChanged).listen((Map event) {
      refresh().then((_) {
        if(!isCreatingNewPlaylist && selectedPlaylistId != null) {
          highlightPlaylistItem(selectedPlaylistId);
        }
      });
    });

    bus.on(Invalidate.playlistRemoved).listen((Map event) {
      refresh().then((_) {
        if(!isCreatingNewPlaylist && selectedPlaylistId != null) {
          highlightPlaylistItem(selectedPlaylistId);
        }
      });
    });

    buttonNew.onClick.listen((_) {
      newPlaylist();
    });

    buttonSave.onClick.listen((_) {
      saveHandler();
    });

    ButtonDelete.onClick.listen((_) {
      deleteHandler();
    });
  }

  Future refresh() {
    return getPlaylistList().then((List<Playlist> list) {
      list.sort();
      renderList(list);
    });
  }

  void renderList(List<Playlist> list) {
    UlPlaylist.children
      ..clear()
      ..addAll(list.map(makePlaylistItem));
  }

  LIElement makePlaylistItem(Playlist item) {
    LIElement node = new LIElement();
    node
      ..text = item.name
      ..dataset['id'] = item.id.toString()
      ..classes.add('clickable')
      ..onClick.listen((_) => activatePlaylist(item.id));

    return node;
  }

  void newPlaylist() {
    isCreatingNewPlaylist = true;
    clearInputs();
  }

  void clearInputs() {
    name.value = '';
    path.value = '';
    shuffle.checked = false;
    channels.checked = false;
    interval.value = '20';
  }

  void saveHandler() {
    Playlist playlist = new Playlist()
      ..name = name.value
      ..path = path.value
      ..shuffle = shuffle.checked
      ..channels = channels.checked ? 2 : 1
      ..interval = interval.valueAsNumber.toInt();

    String data = JSON.encode(playlist);

    if(isCreatingNewPlaylist) {
      createPlaylist(data).then((Map response) {
        int id = response['id'];
        Map event = {'id': id};
        bus.fire(Invalidate.playlistAdded, event);
        notify.info('Afspilningslisten blev oprettet');
        return activatePlaylist(id);
      }).catchError((error, stack) {
        log.error('Tried to create a new playlist, but got: ${error} ${stack}');
        notify.error('Der skete en fejl i forbindelse med oprettelsen af afspilningslisten. ${error}');
      });
    } else {
      updatePlaylist(selectedPlaylistId, data).then((_) {
        Map event = {'id': selectedPlaylistId};
        bus.fire(Invalidate.playlistChanged, event);
        notify.info('Afspilningslisten blev opdateret');
      })
        .catchError((error, stack) {
        log.error('Tried to update a playlist, but got: ${error} ${stack}');
        notify.error('Der skete en fejl i forbindelse med opdateringen af afspilningslisten. ${error}');
      });
    }
  }

  void deleteHandler() {
    if(!isCreatingNewPlaylist && selectedPlaylistId != null) {
      deletePlaylist(selectedPlaylistId).then((_) {
        Map event = {'id': selectedPlaylistId};
        bus.fire(Invalidate.playlistRemoved, event);
        notify.info('Afspilningslisten blev slettet');
      }).catchError((error, stack) {
        log.error('Tried to delete a playlist, but got: ${error} ${stack}');
        notify.error('Der skete en fejl i forbindelse med sletningen af afspilningslisten. ${error}');
      });
    }
  }

  void highlightPlaylistItem(int id) {
    UlPlaylist.children.forEach((LIElement li) => li.classes.toggle('highlightListItem', li.dataset['id'] == id.toString()));
  }
}
