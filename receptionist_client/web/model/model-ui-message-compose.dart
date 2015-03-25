part of model;

class UIMessageCompose extends UIModel {
  final DivElement _root;

  UIMessageCompose(DivElement this._root);

  InputElement    get callerNameInput    => _root.querySelector('.names input.caller');
  InputElement    get callsBackInput     => _root.querySelector('.checks .calls-back');
  ButtonElement   get cancelButton       => _root.querySelector('.buttons .cancel');
  InputElement    get cellphoneInput     => _root.querySelector('.phone-numbers input.cell');
  InputElement    get companyNameInput   => _root.querySelector('.names input.company');
  InputElement    get draftInput         => _root.querySelector('.checks .draft');
  InputElement    get extensionInput     => _root.querySelector('.phone-numbers input.extension');
  InputElement    get hasCalledInput     => _root.querySelector('.checks .has-called');
  InputElement    get landlineInput      => _root.querySelector('.phone-numbers input.landline');
  TextAreaElement get messageTextarea    => _root.querySelector('.message textarea');
  InputElement    get pleaseCallInput    => _root.querySelector('.checks .please-call');
  DivElement      get recipientsDiv      => _root.querySelector('.recipients');
  DivElement      get root               => _root;
  ButtonElement   get saveButton         => _root.querySelector('.buttons .save');
  ButtonElement   get sendButton         => _root.querySelector('.buttons .send');
  SpanElement     get showRecipientsSpan => _root.querySelector('.show-recipients');
  InputElement    get urgentInput        => _root.querySelector('.checks .urgent');
}
