part of model;



class Extension {
  
  final String _value;
  
  static final nullExtension = new Extension._null(); 

  static Extension currentExtension = nullExtension; 
  
  Extension (this._value);

  Extension._null ([this._value = ""]);
  
  String get dialString {
    return this._value;
  }
  
  bool get valid => this != nullExtension && this._value.length > 1; 
}