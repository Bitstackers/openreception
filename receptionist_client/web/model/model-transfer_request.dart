part of model;

class TransferRequest {
  
  final Call source;
  
  static TransferRequest current = null;
  
  TransferRequest (this.source);
  
  void confirm(Call destination){
    this.source.transfer(destination);
  }

  void cancel(){
    this.source.pickup();
  }

}