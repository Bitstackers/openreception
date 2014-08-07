
-------------------------------------------------------------------------------
--  System users:

CREATE TABLE users (
   id               INTEGER NOT NULL PRIMARY KEY, --  AUTOINCREMENT
   name             TEXT    NOT NULL,
   send_from        TEXT    NULL,
   extension        TEXT    NULL
);

CREATE TABLE groups (
   id   INTEGER NOT NULL PRIMARY KEY, --  AUTOINCREMENT
   name TEXT    NOT NULL
);

CREATE TABLE user_groups (
   user_id  INTEGER NOT NULL REFERENCES users (id) ON UPDATE CASCADE ON DELETE CASCADE,
   group_id INTEGER NOT NULL REFERENCES groups (id) ON UPDATE CASCADE ON DELETE CASCADE,

  PRIMARY KEY (user_id, group_id)
);

CREATE TABLE auth_identities (
   identity  TEXT    NOT NULL PRIMARY KEY,
   user_id   INTEGER NOT NULL REFERENCES users (id) ON UPDATE CASCADE ON DELETE CASCADE
);


-- CREATE TABLE openids (
--    user_id  INTEGER NOT NULL REFERENCES users (id),
--    openid   TEXT    NOT NULL PRIMARY KEY,
--    priority INTEGER NOT NULL
-- );

-------------------------------------------------------------------------------
--  Dial-plans:

CREATE TABLE dialplan_templates (
   id       INTEGER NOT NULL PRIMARY KEY, --  AUTOINCREMENT
   template JSON    NOT NULL
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
--  Contacts and receptions:

CREATE TABLE contact_types (value TEXT NOT NULL PRIMARY KEY);
INSERT INTO contact_types VALUES ('human'), ('function'), ('invisible');

CREATE TABLE contacts (
   id           INTEGER NOT NULL PRIMARY KEY, --  AUTOINCREMENT
   full_name    TEXT    NOT NULL,
   contact_type TEXT    NOT NULL REFERENCES contact_types (value),
   enabled      BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE organizations (
   id           INTEGER NOT NULL PRIMARY KEY, --  AUTOINCREMENT
   full_name    TEXT NOT NULL,
   billing_type TEXT NOT NULL,
   flag         TEXT NOT NULL);

CREATE TABLE receptions (
   id              INTEGER NOT NULL PRIMARY KEY, --  AUTOINCREMENT
   organization_id INTEGER NOT NULL REFERENCES organizations(id) ON UPDATE CASCADE ON DELETE CASCADE,
   full_name       TEXT    NOT NULL,
--   uri             TEXT    NOT NULL UNIQUE,
   attributes      JSON    NOT NULL,
   extradatauri    TEXT,
   reception_telephonenumber TEXT UNIQUE,
   dialplan        JSON,
   ivr             JSON,
   last_check      TIMESTAMP NOT NULL DEFAULT NOW(),
   enabled         BOOLEAN NOT NULL DEFAULT TRUE
);

--CREATE INDEX reception_uri_index ON receptions (uri);

CREATE TABLE reception_contacts (
   reception_id         INTEGER NOT NULL REFERENCES receptions (id) ON UPDATE CASCADE ON DELETE CASCADE,
   contact_id           INTEGER NOT NULL REFERENCES contacts (id) ON UPDATE CASCADE ON DELETE CASCADE,
   wants_messages       BOOLEAN NOT NULL DEFAULT TRUE,
--   distribution_list_id INTEGER, --  Reference constraint added further down
   attributes           JSON,
   distribution_list    JSON,
   phonenumbers		JSON,
   enabled              BOOLEAN NOT NULL DEFAULT TRUE,
   data_contact    	BOOLEAN NOT NULL DEFAULT FALSE,
   status_email         BOOLEAN NOT NULL DEFAULT TRUE,
   PRIMARY KEY (reception_id, contact_id)
);

CREATE INDEX reception_contacts_contact_id_index   ON reception_contacts (contact_id);
CREATE INDEX reception_contacts_reception_id_index ON reception_contacts (reception_id);

-------------------------------------------------------------------------------
--  Addresses and messaging:

CREATE TABLE messaging_address_types (value TEXT NOT NULL PRIMARY KEY);
INSERT INTO messaging_address_types VALUES ('email'), ('sms');

CREATE TABLE messaging_end_points (
   contact_id   INTEGER NOT NULL,
   reception_id INTEGER NOT NULL,
   address      TEXT    NOT NULL,
   address_type TEXT    NOT NULL REFERENCES messaging_address_types (value),
   confidential BOOLEAN NOT NULL DEFAULT TRUE,
   enabled      BOOLEAN NOT NULL DEFAULT FALSE,
   priority     INTEGER NOT NULL DEFAULT 0,
   description  TEXT    NULL,

   PRIMARY KEY (contact_id, reception_id, address, address_type),

   FOREIGN KEY (contact_id, reception_id)
      REFERENCES reception_contacts (contact_id, reception_id)
      ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE recipient_visibilities (value TEXT NOT NULL PRIMARY KEY);
INSERT INTO recipient_visibilities VALUES ('to'), ('cc'), ('bcc');

-------------------------------------------------------------------------------
--  Late reference from reception_contacts to distribution_lists:
--  Currently folded to a single JSON object.

--  ALTER TABLE reception_contacts
--     ADD CONSTRAINT reception_contacts_distribution_list_id_foreign_key
--        FOREIGN KEY (distribution_list_id)
--           REFERENCES distribution_lists (id) MATCH SIMPLE
--           ON UPDATE CASCADE ON DELETE SET DEFAULT;

-------------------------------------------------------------------------------
--  Message dispatching:

CREATE TABLE messages (
   id                        INTEGER   NOT NULL PRIMARY KEY, --  AUTOINCREMENT
   message                   TEXT      NOT NULL,
   context_contact_id        INTEGER       NULL REFERENCES contacts   (id),  
   context_reception_id      INTEGER   NOT NULL REFERENCES receptions (id),  
   context_contact_name      TEXT          NULL DEFAULT NULL, --  Dereferenced contact name.
   context_reception_name    TEXT      NOT NULL,              --  Dereferenced reception name.
   taken_from_name           TEXT      NOT NULL DEFAULT '',
   taken_from_company        TEXT      NOT NULL DEFAULT '',
   taken_from_phone          TEXT      NOT NULL DEFAULT '',
   taken_from_cellphone      TEXT      NOT NULL DEFAULT '',
   taken_by_agent            INTEGER   NOT NULL REFERENCES users (id),
   flags                     JSON      NOT NULL DEFAULT '{}',
   created_at                TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE message_recipients (
   contact_id     INTEGER NOT NULL,
   reception_id   INTEGER NOT NULL,
   message_id     INTEGER NOT NULL,
   recipient_role TEXT    NOT NULL,
   contact_name   TEXT    NOT NULL, --  Dereferenced contact name.
   reception_name TEXT    NOT NULL, --  Dereferenced reception name.

   PRIMARY KEY (contact_id, reception_id, message_id)
);

--  The message_queue is a simple job-stack that, when a item is present in the 
--  table, indicates that is has not been delived to a transport agent.

CREATE TABLE message_queue (
   id             INTEGER   NOT NULL PRIMARY KEY, --  AUTOINCREMENT
   message_id     INTEGER   NOT NULL REFERENCES messages (id),
   enqueued_at    TIMESTAMP NOT NULL DEFAULT NOW(),
   last_try       TIMESTAMP     NULL DEFAULT NULL,
   tries          INTEGER   NOT NULL DEFAULT 0
);

CREATE TABLE message_queue_history (
   id             INTEGER   NOT NULL PRIMARY KEY,
   message_id     INTEGER   NOT NULL REFERENCES messages (id),
   enqueued_at    TIMESTAMP NOT NULL,
   sent_at        TIMESTAMP NOT NULL DEFAULT NOW(),
   last_try       TIMESTAMP     NULL DEFAULT NULL,
   tries          INTEGER   NOT NULL DEFAULT 0
);

-------------------------------------------------------------------------------
--  Message drafts:

--  Message drafts are weak document stores, given the fact that we do not want
--  to constrain the fields or format of a work-in-progress message for the
--  client. When the message is done, however, the client must encode it to a
--  more basic format (see Messages table).

CREATE TABLE message_draft (
   id     INTEGER   NOT NULL PRIMARY KEY, --  AUTOINCREMENT
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
   reception_id      INTEGER NOT NULL,
   contact_id        INTEGER NOT NULL,
   distribution_list JSON        NULL DEFAULT NULL, 
   --  A not-null distribution list will override the distribution list for the
   --  contact for the duration of the calendar event.
   event_id          INTEGER NOT NULL REFERENCES calendar_events (id) 
                ON UPDATE CASCADE ON DELETE CASCADE,

   PRIMARY KEY (contact_id, reception_id, event_id),

   FOREIGN KEY (contact_id, reception_id)
      REFERENCES reception_contacts (contact_id, reception_id)
      ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE reception_calendar (
   reception_id INTEGER NOT NULL REFERENCES receptions (id)
       ON UPDATE CASCADE ON DELETE CASCADE,
   event_id     INTEGER NOT NULL REFERENCES calendar_events (id) 
       ON UPDATE CASCADE ON DELETE CASCADE,

   PRIMARY KEY (reception_id, event_id)
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
   reception_id INTEGER NOT NULL,
   contact_id   INTEGER NOT NULL,
   event_id     INTEGER NOT NULL REFERENCES recurring_calendar_events (id) ON UPDATE CASCADE ON DELETE CASCADE,

   PRIMARY KEY (contact_id, reception_id, event_id),

   FOREIGN KEY (contact_id, reception_id)
      REFERENCES reception_contacts (contact_id, reception_id)
      ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE reception_recurring_calendar (
   reception_id INTEGER NOT NULL REFERENCES receptions (id) ON UPDATE CASCADE ON DELETE CASCADE,
   event_id     INTEGER NOT NULL REFERENCES recurring_calendar_events (id) ON UPDATE CASCADE ON DELETE CASCADE,

   PRIMARY KEY (reception_id, event_id)
);

-------------------------------------------------------------------------------
--  Phones
-- TODO These are now in the contact as JSON and are therefore deprecated

CREATE TABLE phone_number_types (value TEXT NOT NULL PRIMARY KEY);
INSERT INTO phone_number_types (value) VALUES ('SIP'), ('PSTN');

CREATE TABLE phone_numbers (
   id    INTEGER NOT NULL PRIMARY KEY, --  AUTOINCREMENT
   value TEXT    NOT NULL UNIQUE,
   kind  TEXT    NOT NULL REFERENCES phone_number_types (value)
);

CREATE TABLE contact_phone_numbers (
   reception_id    INTEGER NOT NULL,
   contact_id      INTEGER NOT NULL,
   phone_number_id INTEGER NOT NULL REFERENCES phone_numbers (id) ON UPDATE CASCADE ON DELETE CASCADE,

   PRIMARY KEY (contact_id, reception_id, phone_number_id),

   FOREIGN KEY (contact_id, reception_id)
      REFERENCES reception_contacts (contact_id, reception_id)
      ON UPDATE CASCADE ON DELETE CASCADE
);

-------------------------------------------------------------------------------
--  CDR data

CREATE TABLE cdr_entries (
   uuid         TEXT      NOT NULL PRIMARY KEY,
   inbound      BOOLEAN   NOT NULL,
   reception_id INTEGER   NOT NULL REFERENCES receptions (id),
   extension    TEXT      NOT NULL,
   duration     INTEGER   NOT NULL,
   wait_time    INTEGER   NOT NULL,
   started_at   TIMESTAMP NOT NULL,
   json         JSON      NOT NULL
);

CREATE INDEX cdr_entries_index ON cdr_entries (started_at);

CREATE TABLE cdr_checkpoints (
   checkpoint   TIMESTAMP NOT NULL PRIMARY KEY
);


CREATE TABLE playlists (
   id           INTEGER NOT NULL PRIMARY KEY, --  AUTOINCREMENT
   content      json    NOT NULL
);
--  The distribution lists are temporarily moved to an object residing inside
--  the contact table. Wheter or not we need the strong references will be
--  clear later on. From there, we can safely migrate to db-keys.

--  CREATE TABLE distribution_lists (
--     id                   INTEGER NOT NULL PRIMARY KEY, --  AUTOINCREMENT
--     send_to_contact_id   INTEGER NOT NULL,
--     send_to_reception_id INTEGER NOT NULL,
--     recipient_visibility TEXT    NOT NULL REFERENCES recipient_visibilities (value),
--  
--     FOREIGN KEY (send_to_contact_id, send_to_reception_id)
--     REFERENCES reception_contacts (contact_id, reception_id)
--        ON UPDATE CASCADE ON DELETE CASCADE
--  );



--  Unused at the moment. The message archive _could_ be realized by an IMAP store.
--
--  CREATE TABLE archive_message_queue (
--     id                INTEGER   NOT NULL PRIMARY KEY,
--     message           TEXT      NOT NULL,
--     subject           TEXT      NOT NULL,
--     to_contact_id     INTEGER   NOT NULL REFERENCES contacts (id),
--     taken_from        TEXT      NOT NULL,
--     taken_by_agent    INTEGER   NOT NULL REFERENCES users (id),
--     urgent            BOOLEAN   NOT NULL,
--     created_at        TIMESTAMP NOT NULL,
--     last_try          TIMESTAMP NOT NULL,
--     tries             INTEGER   NOT NULL
--  );

--  CREATE TABLE archive_message_queue_recipients (
--     contact_id         INTEGER NOT NULL,
--     reception_id       INTEGER NOT NULL,
--     message_id         INTEGER NOT NULL,
--     recipient_role     TEXT    NOT NULL REFERENCES recipient_visibilities (value),
--     resolved_addresses TEXT    NOT NULL,
--  
--     PRIMARY KEY (contact_id, reception_id, message_id),
--  
--     FOREIGN KEY (contact_id, reception_id)
--        REFERENCES reception_contacts (contact_id, reception_id)
--        ON UPDATE CASCADE ON DELETE CASCADE
--  );
