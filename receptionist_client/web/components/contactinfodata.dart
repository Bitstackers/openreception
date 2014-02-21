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
              <div class="contact-info-field">
                <ul id="contactWorkHoursList" class="zebra"></ul>
              </div>
            </td>
            <td>
              <h5>Kald</h5>
              <div class="contact-info-field">
                <ul id="contactHandlingList" class="zebra"></ul>
              </div>
            </td>
          </tr>
          <tr>
            <td>
              <h5>Stilling</h5>
              <div id="contactPosition" class="contact-info-field"></div>
            </td>
            <td>
              <h5>Ansvar</h5>
              <div id="contactResponsibility" class="contact-info-field"></div>
            </td>
          </tr>
          <tr>
            <td>
              <h5>Afdeling</h5>
              <div id="contactDepartment" class="contact-info-field"></div>
            </td>
            <td>
              <h5>Telefon</h5>
              <div class="contact-info-field">
                <ul id="contactTelephoneNumberList" class="zebra"></ul>
              </div>
            </td>
          </tr>
          <tr>
            <td>
              <h5>Relationer</h5>
              <div id="contactRelations" class="contact-info-field"></div>
            </td>
            <td>
              <h5>Email</h5>
              <div class="contact-info-field">
                <ul id="contactEmailAddressList" class="zebra"></ul>
              </div>
            </td>
          </tr>
          <tr>
            <td>
              <h5>Info</h5>
              <div id="contactAdditionalInfo" class="contact-info-field"></div>
            </td>
            <td>
              <h5>Backup</h5>
              <div class="contact-info-field">
                <ul id="contactBackupList" class="zebra"></ul>
              </div>
            </td>
          </tr>
        </table>
    ''';

    TableElement body = new DocumentFragment.html(html).querySelector('table');

    workHoursList       = body.querySelector('#${id.CONTACT_WORK_HOURS_LIST}');
    handlingList        = body.querySelector('#${id.CONTACT_HANDLING_LIST}');
    position            = body.querySelector('#${id.CONTACT_PISITION}');
    responsibility      = body.querySelector('#${id.CONTACT_RESPONSIBILITY}');
    department          = body.querySelector('#${id.CONTACT_DEPARTMENT}');
    telephoneNumberList = body.querySelector('#${id.CONTACT_TELEPHONE_NUMBER_LIST}');
    relations           = body.querySelector('#${id.CONTACT_RELATIONS}');
    emailAddressList    = body.querySelector('#${id.CONTACT_EMAIL_ADDRESS_LIST}');
    info                = body.querySelector('#${id.CONTACT_ADDITIONAL_INFO}');
    backupList          = body.querySelector('#${id.CONTACT_BACKUP_LIST}');

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
      handlingList.children.add(new LIElement()
        ..text = item.value);
    }

    position.innerHtml = contact.position != null ? contact.position: '';
    responsibility.innerHtml = contact.responsibility != null ? contact.responsibility: '';
    department.innerHtml = contact.department  != null ? contact.department: '';

    telephoneNumberList.children.clear();
    for(var item in contact.telephoneNumberList) {
      telephoneNumberList.children.add(new LIElement()
        ..text = item.value);
    }

    relations.innerHtml = contact.relations != null ? contact.relations: '';

    emailAddressList.children.clear();
    for(var item in contact.emailAddressList) {
      emailAddressList.children.add(new LIElement()
        ..text = item.value);
    }

    info.innerHtml = contact.info  != null ? contact.info: '';

    backupList.children.clear();
    for(var item in contact.emailAddressList) {
      backupList.children.add(new LIElement()
        ..text = item.value);
    }
  }
}