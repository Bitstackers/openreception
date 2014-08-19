part of model;

class MessageFilter extends ORModel.MessageFilter {

  static MessageFilter current = new MessageFilter.empty();

  MessageFilter.empty() : super.empty();

  static MessageFilter get none => new MessageFilter.empty();


}