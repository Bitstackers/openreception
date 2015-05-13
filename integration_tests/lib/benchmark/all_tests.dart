part of or_test_fw;

void runBenchmarkTests () {
  
  group('Benchmark', () {
    //TODO: Clean the sets on every run.
    Set<Receptionist> receptionists;
    Set<Customer> customers;

    setUp (() {
      receptionists = new Set();
      customers  = new Set();
      
      while (ReceptionistPool.instance.available.length > 0) {
        receptionists.add(ReceptionistPool.instance.aquire());
      }
      
      while (CustomerPool.instance.available.length > 0) {
        customers.add(CustomerPool.instance.aquire());
      }
      
      return Future.wait(receptionists.map
        ((Receptionist receptionist) => receptionist.initialize()))
        .then((_) => 
            Future.wait(customers.map
          ((Customer customer) => customer.initialize())));
    });

    tearDown (() {
      receptionists.forEach(((Receptionist receptionist) =>
        ReceptionistPool.instance.release (receptionist)));

      customers.forEach(((Customer customer) =>
          CustomerPool.instance.release (customer)));

      return Future.wait(receptionists.map
        ((Receptionist receptionist) => receptionist.teardown()))
        .then((_) => 
            Future.wait(customers.map
          ((Customer customer) => customer.teardown())));
    });

    test('callRush', () =>
      Benchmark.callRush (receptionists, customers));
  });
  
}