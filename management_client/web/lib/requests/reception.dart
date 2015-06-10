part of request;

Future<Iterable<ORModel.Reception>> getReceptionList() =>
    receptionController.list();

Future<Iterable<ORModel.Contact>> getReceptionContactList(int receptionId) =>
    receptionController.contacts(receptionId);

Future<ORModel.Reception> getReception(int receptionId) =>
    receptionController.get(receptionId);

Future<ORModel.Reception> createReception(
        int organizationId, ORModel.Reception reception) =>
    receptionController.create(reception);

Future updateReception(ORModel.Reception reception) =>
    receptionController.update(reception);

Future deleteReception(int receptionId) =>
    receptionController.remove(receptionId);
