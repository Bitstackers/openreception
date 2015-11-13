part of usermon.view;

class Call {

  final LIElement element = new LIElement();

  set call (or_model.Call c) {
    element.text = '${_remoteParty(c)} (${c.state})';
  }


  Call (or_model.Call c) {
    this.call = c;
  }

  static build(or_model.Call call) => new Call(call);

}