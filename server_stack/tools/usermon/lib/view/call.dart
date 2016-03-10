part of usermon.view;

class Call {

  final LIElement element = new LIElement();

  set call (model.Call c) {
    element.text = '${_remoteParty(c)} (${c.state})';
  }


  Call (model.Call c) {
    this.call = c;
  }

  static build(model.Call call) => new Call(call);

}
