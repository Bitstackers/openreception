part of model;

class UserStatus extends ORModel.UserStatus {

  static UserStatus currentStatus = new UserStatus._null();

  UserStatus.fromMap(Map map) : super.fromMap(map);

  UserStatus._null() : super();

  void update (String newState) {
    this.state = newState;

    event.bus.fire(event.userStatusChanged, this);
  }
}