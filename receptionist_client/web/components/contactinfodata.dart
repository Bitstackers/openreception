part of components;

class ContactInfoData {
  UListElement  backupList;
  UListElement  calendarBody;
  model.Contact contact;
  DivElement    department;
  DivElement    element;
  UListElement  emailAddressList;
  UListElement  handlingList;
  DivElement    info;
  DivElement    position;
  DivElement    relations;
  DivElement    responsibility;
  UListElement  telephoneNumberList;
  UListElement  workHoursList;

  ContactInfoData(DivElement this.element) {
    String html = '''
        <table>
          <tr>
            <td>
              <h5>Arbejdstider</h5>
              <div>
                <ul id="contactWorkHoursList" class="zebra"></ul>
              </div>
            </td>
            <td>
              <h5>Kald</h5>
              <div>
                <ul id="contactHandlingList" class="zebra"></ul>
              </div>
            </td>
          </tr>
          <tr>
            <td>
              <h5>Stilling</h5>
              <div id="contactPosition"></div>
            </td>
            <td>
              <h5>Ansvar</h5>
              <div id="contactResponsibility"></div>
            </td>
          </tr>
          <tr>
            <td>
              <h5>Afdeling</h5>
              <div id="contactDepartment"></div>
            </td>
            <td>
              <h5>Telefon</h5>
              <div>
                <ul id="contactTelephoneNumberList" class="zebra"></ul>
              </div>
            </td>
          </tr>
          <tr>
            <td>
              <h5>Relationer</h5>
              <div id="contactRelations"></div>
            </td>
            <td>
              <h5>Email</h5>
              <div>
                <ul id="contactEmailAddressList" class="zebra"></ul>
              </div>
            </td>
          </tr>
          <tr>
            <td>
              <h5>Info</h5>
              <div id="contactInfo"></div>
            </td>
            <td>
              <h5>Backup</h5>
              <div>
                <ul id="contactBackupList" class="zebra"></ul>
              </div>
            </td>
          </tr>
        </table>
    ''';

    TableElement body = new DocumentFragment.html(html).querySelector('table');

    workHoursList       = body.querySelector('#contactWorkHoursList');
    handlingList        = body.querySelector('#contactHandlingList');
    position            = body.querySelector('#contactPosition');
    responsibility      = body.querySelector('#contactResponsibility');
    department          = body.querySelector('#contactDepartment');
    telephoneNumberList = body.querySelector('#contactTelephoneNumberList');
    relations           = body.querySelector('#contactRelations');
    emailAddressList    = body.querySelector('#contactEmailAddressList');
    info                = body.querySelector('#contactInfo');
    backupList          = body.querySelector('#contactBackupList');

    element.children.add(body);

    event.bus.on(event.contactChanged).listen((model.Contact value) {
      contact = value;
      render();
    });
  }

  void render() {
    workHoursList.children.clear();
    for(var item in contact.workHoursList) {
      workHoursList.children.add(new LIElement()
        ..text = item.value);
    }

    handlingList.children.clear();
    for(var item in contact.handlingList) {
      workHoursList.children.add(new LIElement()
        ..text = item.value);
    }

    position.innerHtml = contact.position;
    responsibility.innerHtml = contact.responsibility;
    department.innerHtml = contact.department;

    telephoneNumberList.children.clear();
    for(var item in contact.telephoneNumberList) {
      telephoneNumberList.children.add(new LIElement()
        ..text = item.value);
    }

    relations.innerHtml = contact.relations;

    emailAddressList.children.clear();
    for(var item in contact.emailAddressList) {
      emailAddressList.children.add(new LIElement()
        ..text = item.value);
    }

    info.innerHtml = contact.info;

    backupList.children.clear();
    for(var item in contact.emailAddressList) {
      backupList.children.add(new LIElement()
        ..text = item.value);
    }
  }
}