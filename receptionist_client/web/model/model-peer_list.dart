/*                  This file is part of OpenReception
                   Copyright (C) 2014-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of model;

class PeerList extends IterableBase<Peer> {

  static const String className = "${libraryName}.PeerList";

  static final EventType reload = new EventType();
  static final EventType<Peer> stateChange = new EventType<Peer>();

  EventBus _eventStream =  event.bus; // Hooks into the global event bus.
  EventBus get events   => _eventStream;

  /// Singleton instance - for quick and easy reference.
  static PeerList _instance = new PeerList();
  static PeerList get instance => _instance;
  static set instance(PeerList newList) => _instance = newList;

  /// A set would have been a better fit here, but it makes the code read terrible.
  Map<String, Peer> _map = new Map<String, Peer>();

  /**
   * Iterator.
   *
   * This merely forwards the values from within the internal map.
   * We are not interested in the keys (Peer ID) as they are already stored inside
   * the Peer Object.
   */
  Iterator<Peer> get iterator => this._map.values.iterator;

  /**
   * Default constructor.
   */
  PeerList();

  /**
   * Updates or inserts a [Peer] object into the [PeerList].
   */
  void updateOrInsert(Peer peer) {
    const String context = '${className}.update';

    if (this._map.containsKey(peer.ID)) {
      log.debugContext("Updating peer ${peer.ID}", context);
      this._map[peer.ID].update(peer);
    } else {
      log.debugContext("Inserting peer ${peer.ID}", context);
      this._map[peer.ID] = peer;
    }
  }

  /**
   * Reloads the PeerList from a List of Maps.
   *
   * TODO: Document the map format in the wiki.
   */
  PeerList.fromList (List<Map> peerMaps) {
    const String context = '${className}.fromList';

    try {
      peerMaps.forEach((Map peerMap) {
        this.updateOrInsert(new Peer.fromMap(peerMap));
      });
    } catch (error) {
      log.criticalError(error, context);
      throw(error);
    }
  }

  /**
   * Reloads the instance from the server
   *
   * Returns a Future with the [PeerList] instance - updated with new elements.
   */
  Future<PeerList> reloadFromServer() {
    return Service.Peer.list().then ((PeerList peerList){
      this._map = peerList._map;

      this._eventStream.fire(PeerList.reload, null);
      return this;
    });
  }
}
