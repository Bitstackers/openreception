part of model;



class Extension {
  
  final String _value;
  
  static final nullExtension = new Extension._null(); 

  static Extension _selectedExtension = nullExtension; 
  
  static final EventType<Extension> activeExtensionChanged = new EventType<Extension>();
  
  static Extension get selectedExtension                       =>  _selectedExtension;
  static           set selectedExtension (Extension extension) {
    _selectedExtension = extension;
    event.bus.fire(activeExtensionChanged, _selectedExtension);
  }
  
  Extension (this._value);

  Extension._null ([this._value = ""]);
  
  String get dialString {
    return this._value;
  }
  
  bool get valid => this != nullExtension && this._value.length > 1; 
}