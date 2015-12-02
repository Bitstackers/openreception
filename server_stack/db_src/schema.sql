-------------------------------------------------------------------------------
--  System users:

CREATE TABLE users (
   id               INTEGER NOT NULL PRIMARY KEY, --  AUTOINCREMENT
   name             TEXT    NOT NULL,
   send_from        TEXT    NOT NULL DEFAULT '',
   extension        TEXT    NOT NULL DEFAULT '',
   google_username  TEXT    NOT NULL DEFAULT '',
   google_appcode   TEXT    NOT NULL DEFAULT '',
   enabled          BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE groups (
   id   INTEGER NOT NULL PRIMARY KEY, --  AUTOINCREMENT
   name TEXT    NOT NULL
);

CREATE TABLE user_groups (
   user_id  INTEGER NOT NULL REFERENCES users  (id) ON UPDATE CASCADE ON DELETE CASCADE,
   group_id INTEGER NOT NULL REFERENCES groups (id) ON UPDATE CASCADE ON DELETE CASCADE,

  PRIMARY KEY (user_id, group_id)
);

CREATE TABLE auth_identities (
   identity  TEXT    NOT NULL PRIMARY KEY,
   user_id   INTEGER NOT NULL REFERENCES users (id) ON UPDATE CASCADE ON DELETE CASCADE
);

-------------------------------------------------------------------------------
--  Ivr menus

CREATE TABLE ivr_menus (
   id   SERIAL NOT NULL PRIMARY KEY,
   menu JSON   NOT NULL
);

-------------------------------------------------------------------------------
--  Reception dialplans

CREATE TABLE reception_dialplans (
   extension TEXT    NOT NULL PRIMARY KEY,
   dialplan  JSON    NOT NULL DEFAULT '{}'
);

-------------------------------------------------------------------------------
--  Dial-plans. DEPRECATED

CREATE TABLE dialplan_templates (
   id       INTEGER NOT NULL PRIMARY KEY, --  AUTOINCREMENT
   template JSON    NOT NULL
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
   id                INTEGER      NOT NULL PRIMARY KEY, --  AUTOINCREMENT
   organization_id   INTEGER      NOT NULL REFERENCES 
                        organizations(id) ON UPDATE CASCADE ON DELETE CASCADE,
   full_name         TEXT         NOT NULL,
   attributes        JSON         NOT NULL,
   extradatauri      TEXT         NOT NULL DEFAULT '',
   reception_telephonenumber TEXT NOT NULL UNIQUE,
   dialplan          TEXT         NOT NULL REFERENCES 
                         reception_dialplans(extension) DEFAULT 'empty',
-- last_check        TIMESTAMPTZ  NOT NULL DEFAULT '-infinity',
   last_check        TIMESTAMPTZ  NOT NULL DEFAULT 'epoch',
   enabled           BOOLEAN      NOT NULL DEFAULT TRUE
);

CREATE TABLE reception_contacts (
   reception_id         INTEGER NOT NULL REFERENCES receptions (id) ON UPDATE CASCADE ON DELETE CASCADE,
   contact_id           INTEGER NOT NULL REFERENCES contacts (id) ON UPDATE CASCADE ON DELETE CASCADE,
   wants_messages       BOOLEAN NOT NULL DEFAULT TRUE,
   attributes           JSON NOT NULL DEFAULT '{}',
   phonenumbers		JSON NOT NULL DEFAULT '[]',
   enabled              BOOLEAN NOT NULL DEFAULT TRUE,
   data_contact         BOOLEAN NOT NULL DEFAULT FALSE,
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
   id           INTEGER NOT NULL,
   contact_id   INTEGER NOT NULL,
   reception_id INTEGER NOT NULL,
   address      TEXT    NOT NULL,
   address_type TEXT    NOT NULL REFERENCES messaging_address_types (value),
   confidential BOOLEAN NOT NULL DEFAULT TRUE,
   enabled      BOOLEAN NOT NULL DEFAULT FALSE,
   priority     INTEGER NOT NULL DEFAULT 0,
   description  TEXT    NOT NULL DEFAULT '',

   PRIMARY KEY (id),
   UNIQUE (contact_id, reception_id, address, address_type),

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
   id                        INTEGER     NOT NULL PRIMARY KEY, --  AUTOINCREMENT
   message                   TEXT        NOT NULL,
   recipients                JSON        NOT NULL DEFAULT '[]',
   context_contact_id        INTEGER     NOT NULL REFERENCES contacts   (id),
   context_reception_id      INTEGER     NOT NULL REFERENCES receptions (id),
   context_contact_name      TEXT        NOT NULL DEFAULT '', --  Dereferenced contact name.
   context_reception_name    TEXT        NOT NULL DEFAULT '', --  Dereferenced reception name.
   taken_from_name           TEXT        NOT NULL DEFAULT '',
   taken_from_company        TEXT        NOT NULL DEFAULT '',
   taken_from_phone          TEXT        NOT NULL DEFAULT '',
   taken_from_cellphone      TEXT        NOT NULL DEFAULT '',
   taken_from_localexten     TEXT        NOT NULL DEFAULT '',
   taken_by_agent            INTEGER     NOT NULL REFERENCES users (id),
   flags                     JSON        NOT NULL DEFAULT '[]',
   created_at                TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

--  The message_queue is a simple job-stack that, when a item is present in the
--  table, indicates that is has not been delived to a transport agent.
--  'unhandled_endpoints' stores a list of recipient endpoints, still waiting
--  to be dispatched.

CREATE TABLE message_queue (
   id                  INTEGER     NOT NULL PRIMARY KEY, --  AUTOINCREMENT
   message_id          INTEGER     NOT NULL REFERENCES messages (id),
   enqueued_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
-- last_try            TIMESTAMPTZ NOT NULL DEFAULT 'infinity',
   last_try            TIMESTAMPTZ NOT NULL DEFAULT 'epoch',
   handled_endpoints   JSON        NOT NULL DEFAULT '[]',
   unhandled_endpoints JSON        NOT NULL DEFAULT '[]',
   tries               INTEGER     NOT NULL DEFAULT 0
);

CREATE TABLE message_queue_history (
   id                INTEGER     NOT NULL PRIMARY KEY, --  AUTOINCREMENT
   message_id        INTEGER     NOT NULL REFERENCES messages (id),
   enqueued_at       TIMESTAMPTZ NOT NULL,
   handled_endpoints JSON        NOT NULL DEFAULT '[]',
   sent_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
-- last_try          TIMESTAMPTZ NOT NULL DEFAULT '-infinity',
   last_try          TIMESTAMPTZ NOT NULL DEFAULT 'epoch',
   tries             INTEGER     NOT NULL DEFAULT 0
);

-------------------------------------------------------------------------------
--  Calendar events:

CREATE TABLE calendar_events (
   id      INTEGER     NOT NULL PRIMARY KEY, --  AUTOINCREMENT
   start   TIMESTAMPTZ NOT NULL,
   stop    TIMESTAMPTZ NOT NULL,
   message TEXT        NOT NULL
);

CREATE TABLE calendar_entry_changes (
   id         INTEGER     NOT NULL PRIMARY KEY, --  AUTOINCREMENT
   entry_id   INTEGER     NOT NULL REFERENCES calendar_events (id)
                                   ON UPDATE CASCADE ON DELETE CASCADE,
   user_id    INTEGER     NOT NULL,
   updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()

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

------------------------------------------------------------------------------
-- Distribution list
CREATE TABLE distribution_list_roles (value TEXT NOT NULL PRIMARY KEY);
INSERT INTO distribution_list_roles (value) VALUES ('to'), ('cc'), ('bcc');

CREATE TABLE distribution_list (
  id                     INTEGER NOT NULL PRIMARY KEY, --  AUTOINCREMENT
  owner_reception_id     INTEGER NOT NULL,
  owner_contact_id       INTEGER NOT NULL,
  role                   TEXT    NOT NULL REFERENCES distribution_list_roles(value)
                                          ON UPDATE CASCADE ON DELETE CASCADE,
  recipient_reception_id INTEGER NOT NULL,
  recipient_contact_id   INTEGER NOT NULL,
  UNIQUE(owner_reception_id, owner_contact_id, recipient_reception_id, recipient_contact_id),

  FOREIGN KEY (owner_contact_id, owner_reception_id)
      REFERENCES reception_contacts (contact_id, reception_id)
      ON UPDATE CASCADE ON DELETE CASCADE,

  FOREIGN KEY (recipient_contact_id, recipient_reception_id)
      REFERENCES reception_contacts (contact_id, reception_id)
      ON UPDATE CASCADE ON DELETE CASCADE
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
   phone_number_id INTEGER NOT NULL REFERENCES phone_numbers (id)
                                    ON UPDATE CASCADE ON DELETE CASCADE,

   PRIMARY KEY (contact_id, reception_id, phone_number_id),

   FOREIGN KEY (contact_id, reception_id)
      REFERENCES reception_contacts (contact_id, reception_id)
      ON UPDATE CASCADE ON DELETE CASCADE
);

-------------------------------------------------------------------------------
--  CDR data

CREATE TABLE cdr_entries (
   uuid         TEXT        NOT NULL PRIMARY KEY,
   inbound      BOOLEAN     NOT NULL,
   reception_id INTEGER     NOT NULL REFERENCES receptions (id),
   extension    TEXT        NOT NULL,
   duration     INTEGER     NOT NULL,
   wait_time    INTEGER     NOT NULL,
   started_at   TIMESTAMPTZ NOT NULL,
   json         JSON        NOT NULL
);

CREATE INDEX cdr_entries_index ON cdr_entries (started_at);

CREATE TABLE cdr_checkpoints (
   id          INTEGER     NOT NULL PRIMARY KEY, --  AUTOINCREMENT
   startDate   TIMESTAMPTZ NOT NULL,
   endDate     TIMESTAMPTZ NOT NULL,
   name	       TEXT	   NOT NULL,
   UNIQUE(startDate, endDate)
);

CREATE TABLE playlists (
   id           INTEGER NOT NULL PRIMARY KEY, --  AUTOINCREMENT
   content      json    NOT NULL
);

-------------------------------------------------------------------------------
--  Seqences

CREATE SEQUENCE users_id_sequence
  START WITH 1
  INCREMENT BY 1
  NO MINVALUE
  NO MAXVALUE
  CACHE 1;
ALTER SEQUENCE users_id_sequence OWNED BY users.id;
ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval ('users_id_sequence'::regclass);

CREATE SEQUENCE groups_id_sequence
  START WITH 1
  INCREMENT BY 1
  NO MINVALUE
  NO MAXVALUE
  CACHE 1;
ALTER SEQUENCE groups_id_sequence OWNED BY groups.id;
ALTER TABLE ONLY groups ALTER COLUMN id SET DEFAULT nextval ('groups_id_sequence'::regclass);

CREATE SEQUENCE dialplan_templates_id_sequence
  START WITH 1
  INCREMENT BY 1
  NO MINVALUE
  NO MAXVALUE
  CACHE 1;
ALTER SEQUENCE dialplan_templates_id_sequence OWNED BY dialplan_templates.id;
ALTER TABLE ONLY dialplan_templates ALTER COLUMN id SET DEFAULT nextval ('dialplan_templates_id_sequence'::regclass);

CREATE SEQUENCE contacts_id_sequence
  START WITH 1
  INCREMENT BY 1
  NO MINVALUE
  NO MAXVALUE
  CACHE 1;
ALTER SEQUENCE contacts_id_sequence OWNED BY contacts.id;
ALTER TABLE ONLY contacts ALTER COLUMN id SET DEFAULT nextval ('contacts_id_sequence'::regclass);

CREATE SEQUENCE organizations_id_sequence
  START WITH 1
  INCREMENT BY 1
  NO MINVALUE
  NO MAXVALUE
  CACHE 1;
ALTER SEQUENCE organizations_id_sequence OWNED BY organizations.id;
ALTER TABLE ONLY organizations ALTER COLUMN id SET DEFAULT nextval ('organizations_id_sequence'::regclass);

CREATE SEQUENCE receptions_id_sequence
  START WITH 1
  INCREMENT BY 1
  NO MINVALUE
  NO MAXVALUE
  CACHE 1;
ALTER SEQUENCE receptions_id_sequence OWNED BY receptions.id;
ALTER TABLE ONLY receptions ALTER COLUMN id SET DEFAULT nextval ('receptions_id_sequence'::regclass);

CREATE SEQUENCE messages_id_sequence
  START WITH 1
  INCREMENT BY 1
  NO MINVALUE
  NO MAXVALUE
  CACHE 1;
ALTER SEQUENCE messages_id_sequence OWNED BY messages.id;
ALTER TABLE ONLY messages ALTER COLUMN id SET DEFAULT nextval ('messages_id_sequence'::regclass);

CREATE SEQUENCE message_queue_id_sequence
  START WITH 1
  INCREMENT BY 1
  NO MINVALUE
  NO MAXVALUE
  CACHE 1;
ALTER SEQUENCE message_queue_id_sequence OWNED BY message_queue.id;
ALTER TABLE ONLY message_queue ALTER COLUMN id SET DEFAULT nextval ('message_queue_id_sequence'::regclass);

CREATE SEQUENCE message_queue_history_id_sequence
  START WITH 1
  INCREMENT BY 1
  NO MINVALUE
  NO MAXVALUE
  CACHE 1;
ALTER SEQUENCE message_queue_history_id_sequence OWNED BY message_queue_history.id;
ALTER TABLE ONLY message_queue_history ALTER COLUMN id SET DEFAULT nextval ('message_queue_history_id_sequence'::regclass);

CREATE SEQUENCE calendar_events_id_sequence
  START WITH 1
  INCREMENT BY 1
  NO MINVALUE
  NO MAXVALUE
  CACHE 1;
ALTER SEQUENCE calendar_events_id_sequence OWNED BY calendar_events.id;
ALTER TABLE ONLY calendar_events ALTER COLUMN id SET DEFAULT nextval ('calendar_events_id_sequence'::regclass);

CREATE SEQUENCE distribution_list_id_sequence
  START WITH 1
  INCREMENT BY 1
  NO MINVALUE
  NO MAXVALUE
  CACHE 1;
ALTER SEQUENCE distribution_list_id_sequence OWNED BY distribution_list.id;
ALTER TABLE ONLY distribution_list ALTER COLUMN id SET DEFAULT nextval ('distribution_list_id_sequence'::regclass);

CREATE SEQUENCE cdr_checkpoints_id_sequence
  START WITH 1
  INCREMENT BY 1
  NO MINVALUE
  NO MAXVALUE
  CACHE 1;
ALTER SEQUENCE cdr_checkpoints_id_sequence OWNED BY cdr_checkpoints.id;
ALTER TABLE ONLY cdr_checkpoints ALTER COLUMN id SET DEFAULT nextval ('cdr_checkpoints_id_sequence'::regclass);

CREATE SEQUENCE playlists_id_sequence
  START WITH 1
  INCREMENT BY 1
  NO MINVALUE
  NO MAXVALUE
  CACHE 1;
ALTER SEQUENCE playlists_id_sequence OWNED BY playlists.id;
ALTER TABLE ONLY playlists ALTER COLUMN id SET DEFAULT nextval ('playlists_id_sequence'::regclass);

CREATE SEQUENCE calendar_entry_changes_id_sequence
  START WITH 1
  INCREMENT BY 1
  NO MINVALUE
  NO MAXVALUE
  CACHE 1;
ALTER SEQUENCE calendar_entry_changes_id_sequence OWNED BY calendar_entry_changes.id;
ALTER TABLE ONLY calendar_entry_changes ALTER COLUMN id SET DEFAULT nextval ('calendar_entry_changes_id_sequence'::regclass);

CREATE SEQUENCE messaging_end_points_id_sequence
  START WITH 1
  INCREMENT BY 1
  NO MINVALUE
  NO MAXVALUE
  CACHE 1;
ALTER SEQUENCE messaging_end_points_id_sequence OWNED BY messaging_end_points.id;
ALTER TABLE ONLY messaging_end_points ALTER COLUMN id SET DEFAULT nextval ('messaging_end_points_id_sequence'::regclass);


-------------------------------------------------------------------------------
--  Set ownership:

ALTER TABLE users OWNER TO openreception;
ALTER TABLE groups OWNER TO openreception;
ALTER TABLE user_groups OWNER TO openreception;
ALTER TABLE auth_identities OWNER TO openreception;
ALTER TABLE dialplan_templates OWNER TO openreception;
ALTER TABLE contact_types OWNER TO openreception;
ALTER TABLE contacts OWNER TO openreception;
ALTER TABLE organizations OWNER TO openreception;
ALTER TABLE receptions OWNER TO openreception;
ALTER TABLE reception_contacts OWNER TO openreception;
ALTER TABLE messaging_address_types OWNER TO openreception;
ALTER TABLE messaging_end_points OWNER TO openreception;
ALTER TABLE recipient_visibilities OWNER TO openreception;
ALTER TABLE messages OWNER TO openreception;
ALTER TABLE message_queue OWNER TO openreception;
ALTER TABLE message_queue_history OWNER TO openreception;
ALTER TABLE calendar_events OWNER TO openreception;
ALTER TABLE contact_calendar OWNER TO openreception;
ALTER TABLE reception_calendar OWNER TO openreception;
ALTER TABLE distribution_list_roles OWNER TO openreception;
ALTER TABLE distribution_list OWNER TO openreception;
ALTER TABLE contact_phone_numbers OWNER TO openreception;
ALTER TABLE cdr_entries OWNER TO openreception;
ALTER TABLE cdr_checkpoints OWNER TO openreception;
ALTER TABLE playlists OWNER TO openreception;
ALTER TABLE calendar_entry_changes OWNER TO openreception;

ALTER SEQUENCE users_id_sequence OWNER TO openreception;
ALTER SEQUENCE groups_id_sequence OWNER TO openreception;
ALTER SEQUENCE dialplan_templates_id_sequence OWNER TO openreception;
ALTER SEQUENCE contacts_id_sequence OWNER TO openreception;
ALTER SEQUENCE organizations_id_sequence OWNER TO openreception;
ALTER SEQUENCE receptions_id_sequence OWNER TO openreception;
ALTER SEQUENCE messages_id_sequence OWNER TO openreception;
ALTER SEQUENCE message_queue_id_sequence OWNER TO openreception;
ALTER SEQUENCE message_queue_history_id_sequence OWNER TO openreception;
ALTER SEQUENCE calendar_events_id_sequence OWNER TO openreception;
ALTER SEQUENCE distribution_list_id_sequence OWNER TO openreception;
ALTER SEQUENCE cdr_checkpoints_id_sequence OWNER TO openreception;
ALTER SEQUENCE playlists_id_sequence OWNER TO openreception;
ALTER SEQUENCE calendar_entry_changes_id_sequence OWNER TO openreception;

-------------------------------------------------------------------------------
