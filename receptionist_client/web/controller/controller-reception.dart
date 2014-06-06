part of controller;

abstract class Reception {
  
  static void change (Model.Reception newReception) {
    Model.Reception.currentReception = newReception;    
  }
  
}