part of usermon.view;

class AgentInfoList {
  Map<int, AgentInfo> _info = {};

  final TableSectionElement element = new TableElement().createTBody();

  AgentInfoList(
      Iterable<or_model.User> users,
      or_service.CallFlowControl callFlow,
      or_service.NotificationSocket notificationSocket,
      or_service.RESTMessageStore messageStore) {
    element.children = users.map((user) {
      _info[user.ID] = new AgentInfo.fromModel(user);

      return _info[user.ID].element;
    }).toList(growable: false);

    /// Fetch initial user status
    callFlow.userStatusList().then((Iterable<or_model.UserStatus> statuses) {
      statuses.forEach((status) {
        _info[status.userID].userStatus = status;
      });
    });

    /// Fetch initial agent statistics information
    callFlow.agentStats().then((Iterable<or_model.AgentStatistics> stats) {
      stats.forEach((stat) {
        _info[stat.uid].agentStatistics = stat;
      });
    });

    /// Fetch initial message information
    messageStore.list().then((Iterable<or_model.Message> messages) {
      messages.forEach((message) {
        DateTime now = new DateTime.now();
        DateTime midnight = new DateTime(now.year, now.month, now.day);
        if (message.createdAt.isAfter(midnight)) {
          _info[message.senderId].numMessage++;
        }
      });
    });

    dispatchEvent(or_event.Event event) async {
      if (event is or_event.UserState) {
        _info[event.status.userID].userStatus = event.status;
      } else if (event is or_event.CallEvent) {
        if (event is or_event.CallHangup &&
            event.call.assignedTo != or_model.User.noID) {
          int uid = event.call.assignedTo;

          _info[uid].agentStatistics = await callFlow.agentStat(uid);
        }
      } else if (event is or_event.MessageChange) {
        if (event.state == or_event.MessageChangeState.CREATED) {
          or_model.Message msg = await messageStore.get(event.messageID);

          _info[msg.senderId].numMessage++;
        } else if (event.state == or_event.MessageChangeState.DELETED) {
          or_model.Message msg = await messageStore.get(event.messageID);

          _info[msg.senderId].numMessage--;
        }
      }
    }
    notificationSocket.eventStream.listen(dispatchEvent);
  }
}
