
-------------------------------------------------------------------------------
--  System users:

CREATE TABLE users (
   id               INTEGER NOT NULL PRIMARY KEY, --  AUTOINCREMENT
   name             TEXT    NOT NULL,
   extension        TEXT    NULL
);

CREATE TABLE groups (
   id  INTEGER NOT NULL PRIMARY KEY, --  AUTOINCREMENT
   name TEXT    NOT NULL
);

CREATE TABLE user_groups (
   uid INTEGER NOT NULL REFERENCES users (id),
   gid INTEGER NOT NULL REFERENCES groups (id),

  PRIMARY KEY (uid, gid)
);

CREATE TABLE auth_identities (
   identity TEXT    NOT NULL PRIMARY KEY,
   user_id  INTEGER NOT NULL REFERENCES users (id)
);

CREATE TABLE openids (
   user_id  INTEGER NOT NULL REFERENCES users (id),
   openid   TEXT    NOT NULL PRIMARY KEY,
   priority INTEGER NOT NULL
);

-------------------------------------------------------------------------------
--  Dial-plans:

CREATE TABLE dial_plans (
   phone_number TEXT NOT NULL PRIMARY KEY,
   dial_plan    XML  NOT NULL
);

-------------------------------------------------------------------------------
--  Calendar of special days:

CREATE TABLE kinds (
   id          TEXT NOT NULL PRIMARY KEY,
   description TEXT
);

CREATE TABLE special_days (
   kind TEXT NOT NULL REFERENCES kinds (id) ON UPDATE CASCADE ON DELETE CASCADE,
   day  DATE NOT NULL,

   PRIMARY KEY (kind, day)
);

-------------------------------------------------------------------------------
--  Contacts and organizations:

CREATE TABLE contact_types (value TEXT NOT NULL PRIMARY KEY);
INSERT INTO contact_types VALUES ('human'), ('function'), ('invisible');

CREATE TABLE contacts (
   id           INTEGER NOT NULL PRIMARY KEY, --  AUTOINCREMENT
   full_name    TEXT    NOT NULL,
   contact_type TEXT    NOT NULL REFERENCES contact_types (value),
   enabled      BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE organizations (
   id         INTEGER NOT NULL PRIMARY KEY, --  AUTOINCREMENT
   full_name  TEXT    NOT NULL,
   uri        TEXT    NOT NULL UNIQUE,
   attributes JSON    NOT NULL,
   extradata  TEXT    NOT NULL,
   enabled    BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE INDEX organization_uri_index ON organizations (uri);

CREATE TABLE organization_contacts (
   organization_id      INTEGER NOT NULL REFERENCES organizations (id) ON UPDATE CASCADE ON DELETE CASCADE,
   contact_id           INTEGER NOT NULL REFERENCES contacts (id) ON UPDATE CASCADE ON DELETE CASCADE,
   wants_messages       BOOLEAN NOT NULL DEFAULT TRUE,
   distribution_list_id INTEGER, --  Reference constraint added further down
   attributes           JSON,
   enabled              BOOLEAN NOT NULL DEFAULT TRUE,

   PRIMARY KEY (organization_id, contact_id)
);

CREATE INDEX organization_contacts_contact_id_index      ON organization_contacts (contact_id);
CREATE INDEX organization_contacts_organization_id_index ON organization_contacts (organization_id);

-------------------------------------------------------------------------------
--  Addresses and messaging:

CREATE TABLE messaging_address_types (value TEXT NOT NULL PRIMARY KEY);
INSERT INTO messaging_address_types VALUES ('e-mail'), ('sms');

CREATE TABLE messaging_addresses (
   id           INTEGER NOT NULL PRIMARY KEY, --  AUTOINCREMENT
   address      TEXT    NOT NULL,
   address_type TEXT    NOT NULL REFERENCES messaging_address_types (value),

   UNIQUE (address, address_type)
);

CREATE TABLE messaging_end_points (
   contact_id      INTEGER NOT NULL,
   organization_id INTEGER NOT NULL,
   address_id      INTEGER NOT NULL REFERENCES messaging_addresses (id),
   confidential    BOOLEAN NOT NULL DEFAULT TRUE,
   enabled         BOOLEAN NOT NULL DEFAULT FALSE,
   priority        INTEGER NOT NULL DEFAULT 0,

   PRIMARY KEY (contact_id, organization_id, address_id),

   FOREIGN KEY (contact_id, organization_id)
      REFERENCES organization_contacts (contact_id, organization_id)
      ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE recipient_visibilities (value TEXT NOT NULL PRIMARY KEY);
INSERT INTO recipient_visibilities VALUES ('to'), ('cc'), ('bcc');

CREATE TABLE distribution_lists (
   id                      INTEGER NOT NULL PRIMARY KEY, --  AUTOINCREMENT
   send_to_contact_id      INTEGER NOT NULL,
   send_to_organization_id INTEGER NOT NULL,
   recipient_visibility    TEXT    NOT NULL REFERENCES recipient_visibilities (value),

   FOREIGN KEY (send_to_contact_id, send_to_organization_id)
      REFERENCES organization_contacts (contact_id, organization_id)
      ON UPDATE CASCADE ON DELETE CASCADE
);

-------------------------------------------------------------------------------
--  Late reference from organization_contacts to distribution_lists:

ALTER TABLE organization_contacts
   ADD CONSTRAINT organization_contacts_distribution_list_id_foreign_key
      FOREIGN KEY (distribution_list_id)
         REFERENCES distribution_lists (id) MATCH SIMPLE
         ON UPDATE CASCADE ON DELETE SET DEFAULT;

-------------------------------------------------------------------------------
--  Message dispatching:

CREATE TABLE message_queue (
   id                INTEGER   NOT NULL PRIMARY KEY, --  AUTOINCREMENT
   message           TEXT      NOT NULL,
   subject           TEXT      NOT NULL,
   to_contact_id     INTEGER   NOT NULL REFERENCES contacts (id),
   taken_from        TEXT      NOT NULL,
   taken_by_agent    INTEGER   NOT NULL REFERENCES users (id),
   urgent            BOOLEAN   NOT NULL DEFAULT FALSE,
   created_at        TIMESTAMP NOT NULL,
   last_try          TIMESTAMP,
   tries             INTEGER   NOT NULL DEFAULT 0
);

CREATE TABLE message_queue_recipients (
   contact_id      INTEGER NOT NULL,
   organization_id INTEGER NOT NULL,
   message_id      INTEGER NOT NULL,
   recipient_role  TEXT    NOT NULL  REFERENCES recipient_visibilities (value),

   PRIMARY KEY (contact_id, organization_id, message_id),

   FOREIGN KEY (contact_id, organization_id)
      REFERENCES organization_contacts (contact_id, organization_id)
      ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE archive_message_queue (
   id                INTEGER   NOT NULL PRIMARY KEY,
   message           TEXT      NOT NULL,
   subject           TEXT      NOT NULL,
   to_contact_id     INTEGER   NOT NULL REFERENCES contacts (id),
   taken_from        TEXT      NOT NULL,
   taken_by_agent    INTEGER   NOT NULL REFERENCES users (id),
   urgent            BOOLEAN   NOT NULL,
   created_at        TIMESTAMP NOT NULL,
   last_try          TIMESTAMP NOT NULL,
   tries             INTEGER   NOT NULL
);

CREATE TABLE archive_message_queue_recipients (
   contact_id         INTEGER NOT NULL,
   organization_id    INTEGER NOT NULL,
   message_id         INTEGER NOT NULL,
   recipient_role     TEXT    NOT NULL REFERENCES recipient_visibilities (value),
   resolved_addresses TEXT    NOT NULL,

   PRIMARY KEY (contact_id, organization_id, message_id),

   FOREIGN KEY (contact_id, organization_id)
      REFERENCES organization_contacts (contact_id, organization_id)
      ON UPDATE CASCADE ON DELETE CASCADE
);

-------------------------------------------------------------------------------
--  Message draft:
CREATE TABLE message_draft (
   id     INTEGER   NOT NULL PRIMARY KEY,
   owner  INTEGER   NOT NULL REFERENCES users (id),
   json   JSON      NOT NULL
);


-------------------------------------------------------------------------------
--  Calendar events:

CREATE TABLE calendar_events (
   id      INTEGER   NOT NULL PRIMARY KEY, --  AUTOINCREMENT
   start   TIMESTAMP NOT NULL,
   stop    TIMESTAMP NOT NULL,
   message TEXT      NOT NULL
);

CREATE TABLE contact_calendar (
   organization_id INTEGER NOT NULL,
   contact_id      INTEGER NOT NULL,
   event_id        INTEGER NOT NULL REFERENCES calendar_events (id) ON UPDATE CASCADE ON DELETE CASCADE,

   PRIMARY KEY (contact_id, organization_id, event_id),

   FOREIGN KEY (contact_id, organization_id)
      REFERENCES organization_contacts (contact_id, organization_id)
      ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE organization_calendar (
   organization_id INTEGER NOT NULL REFERENCES organizations (id)   ON UPDATE CASCADE ON DELETE CASCADE,
   event_id        INTEGER NOT NULL REFERENCES calendar_events (id) ON UPDATE CASCADE ON DELETE CASCADE,

   PRIMARY KEY (organization_id, event_id)
);

-------------------------------------------------------------------------------
--  Recurring calendar events:

CREATE TABLE recurring_calendar_events (
  id               INTEGER   NOT NULL PRIMARY KEY, --  AUTOINCREMENT
  start            TIMESTAMP NOT NULL,
  stop             TIMESTAMP NOT NULL,
  message          TEXT      NOT NULL,
  pattern          JSON      NOT NULL,
  first_occurrence TIMESTAMP NOT NULL,
  expires          TIMESTAMP NOT NULL
);

CREATE TABLE contact_recurring_calendar (
   organization_id INTEGER NOT NULL,
   contact_id      INTEGER NOT NULL,
   event_id        INTEGER NOT NULL REFERENCES recurring_calendar_events (id) ON UPDATE CASCADE ON DELETE CASCADE,

   PRIMARY KEY (contact_id, organization_id, event_id),

   FOREIGN KEY (contact_id, organization_id)
      REFERENCES organization_contacts (contact_id, organization_id)
      ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE organization_recurring_calendar (
   organization_id INTEGER NOT NULL REFERENCES organizations (id) ON UPDATE CASCADE ON DELETE CASCADE,
   event_id        INTEGER NOT NULL REFERENCES recurring_calendar_events (id) ON UPDATE CASCADE ON DELETE CASCADE,

   PRIMARY KEY (organization_id, event_id)
);

-------------------------------------------------------------------------------
--  Phones

CREATE TABLE phone_number_types (value TEXT NOT NULL PRIMARY KEY);
INSERT INTO phone_number_types (value) VALUES ('SIP'), ('PSTN');

CREATE TABLE phone_numbers (
   id    INTEGER NOT NULL PRIMARY KEY, --  AUTOINCREMENT
   value TEXT    NOT NULL UNIQUE,
   kind  TEXT    NOT NULL REFERENCES phone_number_types (value)
);

CREATE TABLE contact_phone_numbers (
   organization_id INTEGER NOT NULL,
   contact_id      INTEGER NOT NULL,
   phone_number_id INTEGER NOT NULL REFERENCES phone_numbers (id) ON UPDATE CASCADE ON DELETE CASCADE,

   PRIMARY KEY (contact_id, organization_id, phone_number_id),

   FOREIGN KEY (contact_id, organization_id)
      REFERENCES organization_contacts (contact_id, organization_id)
      ON UPDATE CASCADE ON DELETE CASCADE
);

-------------------------------------------------------------------------------
