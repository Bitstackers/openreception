part of usermon.view;

class AgentInfoList {
  Map<int, AgentInfo> _info = {};

  final TableSectionElement element = new TableElement().createTBody();

  AgentInfoList(
      Iterable<model.User> users,
      service.CallFlowControl callFlow,
      service.RESTUserStore userStore,
      service.NotificationSocket notificationSocket,
      service.RESTMessageStore messageStore) {
    element.children = users.map((user) {
      _info[user.id] = new AgentInfo.fromModel(user);

      return _info[user.id].element;
    }).toList(growable: false);

    /// Fetch initial user status
    userStore.userStatusList().then((Iterable<model.UserStatus> statuses) {
      statuses.forEach((status) {
        _info[status.userID].userStatus = status;
      });
    });

    /// Fetch initial agent statistics information
    callFlow.agentStats().then((Iterable<model.AgentStatistics> stats) {
      stats.forEach((stat) {
        _info[stat.uid].agentStatistics = stat;
      });
    });

    /// Fetch initial message information
    messageStore.list().then((Iterable<model.Message> messages) {
      messages.forEach((message) {
        DateTime now = new DateTime.now();
        DateTime midnight = new DateTime(now.year, now.month, now.day);
        if (message.createdAt.isAfter(midnight)) {
          _info[message.senderId].numMessage++;
        }
      });
    });

    dispatchEvent(event.Event e) async {
      if (e is event.UserState) {
        _info[e.status.userID].userStatus = e.status;
      } else if (e is event.CallEvent && e.call.assignedTo != model.User.noID) {
        _info[e.call.assignedTo].call = e.call;
      } else if (e is event.MessageChange) {
        if (e.state == event.MessageChangeState.CREATED) {
          model.Message msg = await messageStore.get(e.messageID);

          _info[msg.senderId].numMessage++;
        } else if (e.state == event.MessageChangeState.DELETED) {
          model.Message msg = await messageStore.get(e.messageID);

          _info[msg.senderId].numMessage--;
        }
      }
    }
    notificationSocket.eventStream.listen(dispatchEvent);
  }
}
