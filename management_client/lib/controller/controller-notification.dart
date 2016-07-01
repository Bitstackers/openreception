part of management_tool.controller;

class Notification {
  final Logger _log = new Logger('$_libraryName.Notification');
  final service.NotificationSocket _service;
  final model.User _appUser;

  Notification(this._service, this._appUser) {
    void dispatch(event.Event e) {
      _log.info(e.eventName);
      try {
        if (e is event.ReceptionChange) {
          _log.finest(e.state);
        } else if (e is event.ReceptionData) {
          _log.finest(e.state);
        } else if (e is event.ContactChange) {
          _log.finest(e.state);
        } else if (e is event.OrganizationChange) {
          _log.finest(e.state);
        } else if (e is event.UserChange) {
          _log.finest(e.state);
        } else if (e is event.CalendarChange) {
          _log.finest(e.state);
        }
      } catch (e, s) {
        _log.warning('Failed to dispatch ${e.eventName}', e, s);
      }
    }

    _service.onEvent.listen(dispatch);

    _observers();
  }

  _observers() {
    _service.onReceptionChange.listen((event.ReceptionChange rc) {
      if (rc.modifierUid == _appUser.id) {
        return;
      }

      if (rc.state == event.Change.created) {
        popup.info('Uid ${rc.modifierUid} oprettede reception ${rc.rid}', '');
      } else if (rc.state == event.Change.updated) {
        popup.info('Uid ${rc.modifierUid} opdaterede reception ${rc.rid}', '');
      } else if (rc.state == event.Change.deleted) {
        popup.info('Uid ${rc.modifierUid} slettede reception ${rc.rid}', '');
      }
    });

    _service.onReceptionDataChange.listen((event.ReceptionData rd) {
      if (rd.modifierUid == _appUser.id) {
        return;
      }

      if (rd.state == event.Change.created) {
        popup.info(
            'Uid ${rd.modifierUid} tilføjede kontakt ${rd.cid} '
            'til reception ${rd.rid}',
            '');
      } else if (rd.state == event.Change.updated) {
        popup.info(
            'Uid ${rd.modifierUid} ændrede kontakt ${rd.cid} '
            'i reception ${rd.rid}',
            '');
      } else if (rd.state == event.Change.deleted) {
        popup.info(
            'Uid ${rd.modifierUid} slettede kontakt ${rd.cid} '
            'fra reception ${rd.rid}',
            '');
      }
    });

    _service.onContactChange.listen((event.ContactChange cc) {
      if (cc.modifierUid == _appUser.id) {
        return;
      }

      if (cc.state == event.Change.created) {
        popup.info(
            'Uid ${cc.modifierUid} oprettede kontaktperson ${cc.cid}', '');
      } else if (cc.state == event.Change.updated) {
        popup.info(
            'Uid ${cc.modifierUid} opdaterede kontaktperson ${cc.cid}', '');
      } else if (cc.state == event.Change.deleted) {
        popup.info(
            'Uid ${cc.modifierUid} slettede kontaktperson ${cc.cid}', '');
      }
    });

    _service.onOrganizationChange.listen((event.OrganizationChange oc) {
      if (oc.modifierUid == _appUser.id) {
        return;
      }

      if (oc.state == event.Change.created) {
        popup.info(
            'Uid ${oc.modifierUid} oprettede organisation ${oc.oid}', '');
      } else if (oc.state == event.Change.updated) {
        popup.info(
            'Uid ${oc.modifierUid} opdaterede organisation ${oc.oid}', '');
      } else if (oc.state == event.Change.deleted) {
        popup.info('Uid ${oc.modifierUid} slettede organisation ${oc.oid}', '');
      }
    });

    _service.onUserChange.listen((event.UserChange uc) {
      if (uc.modifierUid == _appUser.id) {
        return;
      }

      if (uc.state == event.Change.created) {
        popup.info('Uid ${uc.modifierUid} oprettede bruger ${uc.uid}', '');
      } else if (uc.state == event.Change.updated) {
        popup.info('Uid ${uc.modifierUid} opdaterede bruger ${uc.uid}', '');
      } else if (uc.state == event.Change.deleted) {
        popup.info('Uid ${uc.modifierUid} slettede bruger ${uc.uid}', '');
      }
    });

    _service.onCalendarChange.listen((event.CalendarChange cc) {
      if (cc.modifierUid == _appUser.id) {
        return;
      }

      if (cc.state == event.Change.created) {
        popup.info(
            'Uid ${cc.modifierUid} oprettede kalenderpost på ${cc.owner}', '');
      } else if (cc.state == event.Change.updated) {
        popup.info(
            'Uid ${cc.modifierUid} opdaterede kalenderpost på ${cc.owner}', '');
      } else if (cc.state == event.Change.deleted) {
        popup.info(
            'Uid ${cc.modifierUid} slettede kalenderpost på ${cc.owner}', '');
      }
    });
  }
}
