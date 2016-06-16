part of usermon.view;

class AgentInfoList {
  Map<int, AgentInfo> _info = {};

  final TableSectionElement element = new TableElement().createTBody();

  AgentInfoList(
      Iterable<model.UserReference> users,
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
        _info[status.userId].userStatus = status;
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
          _info[message.sender.id].numMessage++;
        }
      });
    });

    dispatchEvent(event.Event e) async {
      if (e is event.UserState) {
        _info[e.status.userId].userStatus = e.status;
      } else if (e is event.CallEvent && e.call.assignedTo != model.User.noId) {
        _info[e.call.assignedTo].call = e.call;
      } else if (e is event.MessageChange) {
        if (e.created) {
          model.Message msg = await messageStore.get(e.mid);

          _info[msg.sender.id].numMessage++;
        } else if (e.deleted) {
          model.Message msg = await messageStore.get(e.mid);

          _info[msg.sender.id].numMessage--;
        }
      }
    }
    notificationSocket.onEvent.listen(dispatchEvent);
  }
}
