/**
 * basic_agent.c
 *
 * This is a very simple but fully featured SIP user agent, with the
 * following capabilities:
 *  - SIP registration
 *  - Making and receiving call
 *
 * It is controlled via STDIN and uses a very primitive command format
 * consisting of a single character followed by an optional parameter.
 *
 * Asynchronous events are delivered in JSON format, and are easily parseable.
 */

// Remove usleep warnings.
#define _BSD_SOURCE

#include <stdio.h>
#include <unistd.h>
#include <strings.h>
#include <stdbool.h>
#include <pjsua-lib/pjsua.h>
#include <json-c/json.h>

#define THIS_FILE "BASIC_AGENT"

typedef enum { OR_ERROR, OR_OK, OR_BUSY } or_reply_t;

typedef enum {
  OR_READY,
  OR_CALL_INCOMING,
  OR_CALL_OUTGOING,
  OR_CALL_STATE,
  OR_CALL_MEDIA_STATE,
  OR_CALL_TSX_STATE,
  OR_ACCOUNT_STATE
} or_event_t;

bool is_registered = false;
bool processing = false;
bool autoanswer[16];
pjsua_call_id current_call = PJSUA_INVALID_ID;
pjsip_inv_state previous_invitation_state = PJSIP_INV_STATE_NULL;

pjsua_conf_port_id rec_conf_port_id = -1;
pjsua_conf_port_id player_conf_port_id = -1;

static char *or_event_table[] = {[OR_READY] = "!READY",
                                 [OR_CALL_INCOMING] = "CALL_INCOMING",
                                 [OR_CALL_OUTGOING] = "CALL_OUTGOING",
                                 [OR_CALL_STATE] = "CALL_STATE",
                                 [OR_CALL_MEDIA_STATE] = "CALL_MEDIA",
                                 [OR_CALL_TSX_STATE] = "CALL_TSX_STATE",
                                 [OR_ACCOUNT_STATE] = "ACCOUNT_STATE"};

char *or_reply_table[] = {[OR_ERROR] = "-ERROR", [OR_OK] = "+OK",
                          [OR_BUSY] = "-BUSY"};

void or_event_incoming_call(char *extension, int call_id, int call_state);
void or_event_outgoing_call(char *extension, int call_id, int call_state);

/* Lookup functions Primarily here to supply type hinting. */
char *or_event_to_string(or_event_t event) { return or_event_table[event]; }
/* Lookup function. Primarily here to supply type hinting. */
char *or_reply_to_string(or_reply_t reply) { return or_reply_table[reply]; }

void or_dump_status() {
  char *autoanswer_text = NULL;
  if (autoanswer[0]) {
    autoanswer_text = "true";
  } else {
    autoanswer_text = "false";
  }

  fprintf(stdout, "{\"autoanswer\" : %s,"
                  "\"currentCall\" : %d}\n",
          autoanswer_text, current_call);
  fflush(stdout);
}

/*
 * status()
 *
 */
void or_status(or_reply_t status, char *message) {
  fprintf(stdout, "{"
                  "\"reply\":\"%s\","
                  "\"message\": \"%s\""
                  "}\n",
          or_reply_to_string(status), message);
  fflush(stdout);
}

void or_event(or_event_t event, char *message) {
  fprintf(stdout, "{"
                  "\"event\":\"%s\","
                  "\"message\": \"%s\""
                  "}\n",
          or_event_to_string(event), message);
  fflush(stdout);
}

void or_event_call_state(int call_id, int call_state) {
  fprintf(stdout, "{"
                  "\"event\":\"%s\","
                  "\"call\":{"
                  "\"id\":%d,"
                  "\"state\" : %d}"
                  "}\n",
          or_event_to_string(OR_CALL_STATE), call_id, call_state);

  fflush(stdout);
}

void or_event_call_media_state(int call_id, int media_state) {
  fprintf(stdout, "{"
                  "\"event\":\"%s\","
                  "\"call\":{"
                  "\"id\":%d,"
                  "\"media_state\" : %d}"
                  "}\n",
          or_event_to_string(OR_CALL_MEDIA_STATE), call_id, media_state);

  fflush(stdout);
}

void or_event_call_tsx_state(int call_id, int tsx_status) {
  fprintf(stdout, "{"
                  "\"event\":\"%s\","
                  "\"call\":{"
                  "\"id\":%d,"
                  "\"tsx_status\" : %d}"
                  "}\n",
          or_event_to_string(OR_CALL_TSX_STATE), call_id, tsx_status);

  fflush(stdout);
}

/* Callback called by the library upon receiving incoming call */
static void on_incoming_call(pjsua_acc_id acc_id, pjsua_call_id call_id,
                             pjsip_rx_data *rdata) {
  pjsua_call_info ci;

  PJ_UNUSED_ARG(acc_id);
  PJ_UNUSED_ARG(rdata);

  pjsua_call_get_info(call_id, &ci);

  char buf[ci.remote_info.slen + 1];
  memcpy(&buf, ci.remote_info.ptr, ci.remote_info.slen);

  buf[ci.remote_info.slen] = '\0';

  or_event_incoming_call(buf, call_id, ci.state);

  current_call = call_id;

  PJ_LOG(3, (THIS_FILE, "Incoming call from %.*s!!", (int)ci.remote_info.slen,
             ci.remote_info.ptr));

  if (autoanswer[0]) {
    pjsua_call_answer(call_id, 200, NULL, NULL);
  } else {
    pjsua_call_answer(call_id, 180, NULL, NULL); // Acknowledge the call.
  }
}

/* Callback called by the library when call's state has changed */
static void on_call_state(pjsua_call_id call_id, pjsip_event *e) {
  pjsua_call_info ci;

  PJ_UNUSED_ARG(e);

  pjsua_call_get_info(call_id, &ci);
  PJ_LOG(3, (THIS_FILE, "Call %d state=%.*s", call_id, (int)ci.state_text.slen,
             ci.state_text.ptr));

  pjsua_call_get_info(call_id, &ci);

  char buf[ci.remote_info.slen + 1];
  memcpy(&buf, ci.remote_info.ptr, ci.remote_info.slen);

  buf[ci.remote_info.slen] = '\0';

  or_event_call_state(call_id, ci.state);

  if (ci.state == PJSIP_INV_STATE_CALLING) {
    or_event_outgoing_call(buf, call_id, ci.state);
  }

  else if (ci.state == PJSIP_INV_STATE_DISCONNECTED) {
    // TODO: or_event (OR_HANGUP, "Either you or the other party hung up.");
  }
}

/* Called by the library when a transaction within the call has changed state.
 */
static void on_call_tsx_state(pjsua_call_id call_id, pjsip_transaction *tsx,
                              pjsip_event *e) {
  PJ_UNUSED_ARG(e);

  pjsua_call_info ci;
  pjsua_call_get_info(call_id, &ci);

  if (tsx == NULL) {
    or_event_call_tsx_state(call_id, -1);
  } else {
    or_event_call_tsx_state(call_id, tsx->status_code);

    if ((tsx->status_code == 180) &&
        (previous_invitation_state == PJSIP_INV_STATE_CALLING)) {
      // TODO: or_event (OR_RINGING,   "Maybe somebody will pick up the phone at
      // the other end soon.");
    } else if ((tsx->status_code == 200) &&
               (ci.state == PJSIP_INV_STATE_CONFIRMED)) {
      // TODO: or_event (OR_CONNECTED, "Somebody picked up the phone at the
      // other end.");
    }
  }

  previous_invitation_state = ci.state;
}

/* Callback called by the library when call's media state has changed */
static void on_call_media_state(pjsua_call_id call_id) {
  pjsua_call_info ci;

  pjsua_call_get_info(call_id, &ci);

  or_event_call_media_state(call_id, ci.media_status);

  if (ci.media_status == PJSUA_CALL_MEDIA_ACTIVE) {
    if (rec_conf_port_id != -1) {
      pjsua_conf_connect(ci.conf_slot, rec_conf_port_id);
    }
    pjsua_conf_connect(player_conf_port_id, ci.conf_slot);
  }
}

/* Display error and exit application */
static void error_exit(const char *title, pj_status_t status) {
  pjsua_perror(THIS_FILE, title, status);
  pjsua_destroy();
  exit(1);
}

/*
 * usage()
 *
 * Prints out the usage information.
 */

void usage(char *command) {
  fprintf(stderr, "Usage: %s username password domain clientport [loglevel] \n",
          command);
}

/**
 * register_account()
 *
 */

void register_account(pjsua_acc_id acc_id) {

  const int u_resolution = 100000;
  const int retries = (10 * 1000000) / u_resolution;
  int reconnect_count = 0;
  pj_status_t status = !PJ_SUCCESS;

  status = pjsua_acc_set_registration(acc_id, PJ_TRUE);
  if (status != PJ_SUCCESS) {
    error_exit("Error in register_account()", status);
  }

  pjsua_acc_info account_info;
  pjsua_acc_get_info(acc_id, &account_info);

  while (account_info.status < 200) {
    pjsua_acc_get_info(acc_id, &account_info);

    if (usleep(u_resolution) < 0 || reconnect_count > retries) {
      or_status(OR_ERROR, "ACCOUNT_TIMEOUT");
      exit(1);
    }
    reconnect_count++;
  }
  is_registered = true;
  or_status(OR_OK, "Account registered.");
}

/**
 * unregister_account()
 *
 */

void unregister_account(pjsua_acc_id acc_id) {

  if (is_registered) {

    const int u_resolution = 100000;
    const int retries = (10 * 1000000) / u_resolution;
    int reconnect_count = 0;
    pj_status_t status = !PJ_SUCCESS;

    status = pjsua_acc_set_registration(acc_id, PJ_FALSE);
    if (status != PJ_SUCCESS) {
      error_exit("Error in unregister_account()", status);
    }

    pjsua_acc_info account_info;
    pjsua_acc_get_info(acc_id, &account_info);

    while (account_info.expires >= 0) {
      pjsua_acc_get_info(acc_id, &account_info);

      if (usleep(u_resolution) < 0 || reconnect_count > retries) {
        or_status(OR_ERROR, "ACCOUNT_TIMEOUT");
        exit(1);
      }
      reconnect_count++;
    }
    is_registered = false;
  }
  or_status(OR_OK, "Unregistered account ");
}

/**
 * Setup playback.
 */
void setup_playback() {
  pj_status_t status;
  pjsua_player_id pl_id;
  pj_str_t file = pj_str("pjsua-input.wav");

  status = pjsua_player_create(&file, 0, &pl_id);
  if (status != PJ_SUCCESS)
    error_exit("Error starting player", status);

  player_conf_port_id = pjsua_player_get_conf_port(pl_id);
  fprintf(stdout, "Created player. File: %.*s\n", (int)file.slen, file.ptr);
}

/**
 * Setup recording.
 */
void setup_recording() {
  pj_status_t status;
  pjsua_recorder_id rec_id;
  pj_str_t file = pj_str("pjsua-output.wav");

  status = pjsua_recorder_create(&file, 0, NULL, 0, 0, &rec_id);
  if (status != PJ_SUCCESS)
    error_exit("Error starting recorder", status);

  rec_conf_port_id = pjsua_recorder_get_conf_port(rec_id);
  fprintf(stdout, "Created recorder. File: %.*s\n", (int)file.slen, file.ptr);
}

/*
 * main()
 *
 * argv[] contains the registration information.
 */
int main(int argc, char *argv[]) {
  pj_status_t status;
  int loglevel = 0;

  if (argc < 4) {
    usage(argv[0]);
    exit(1);
  }

  if (argc > 5) {
    sscanf(argv[5], "%d", &loglevel);
  }

  pjsua_acc_id acc_id;

  /* Create pjsua first! */
  status = pjsua_create();
  if (status != PJ_SUCCESS)
    error_exit("Error in pjsua_create()", status);

  /* Init pjsua */
  {
    pjsua_config cfg;
    pjsua_logging_config log_cfg;
    pjsua_media_config media_cfg;

    // This will prevent the SIP stack from trying to switch to TCP.
    // It will prevent the stack from giving "Transport unavailable" errors.
    // http://trac.pjsip.org/repos/wiki/Using_SIP_TCP
    pjsip_cfg()->endpt.disable_tcp_switch = PJ_TRUE;

    pjsua_config_default(&cfg);
    cfg.cb.on_incoming_call = &on_incoming_call;
    cfg.cb.on_call_media_state = &on_call_media_state;
    cfg.cb.on_call_state = &on_call_state;
    cfg.cb.on_call_tsx_state = &on_call_tsx_state;
    cfg.max_calls = PJSUA_MAX_CALLS;

    pjsua_logging_config_default(&log_cfg);
    log_cfg.console_level =
        loglevel; // 0 = Mute console, 3 = somewhat useful, 4 = overly verbose.
    pjsua_media_config_default(&media_cfg);

    status = pjsua_init(&cfg, &log_cfg, &media_cfg);
    if (status != PJ_SUCCESS)
      error_exit("Error in pjsua_init()", status);
  }
  /* Add UDP transport. */
  {
    pjsua_transport_config cfg;

    pjsua_transport_config_default(&cfg);
    sscanf(argv[4], "%d", &cfg.port);
    status = pjsua_transport_create(PJSIP_TRANSPORT_UDP, &cfg, NULL);
    if (status != PJ_SUCCESS)
      error_exit("Error creating transport", status);
    printf("Created UDP transport on port %d.\n", cfg.port);
  }

  /* Initialization is done, now start pjsua */
  status = pjsua_start();
  if (status != PJ_SUCCESS)
    error_exit("Error starting pjsua", status);

  // setup_recording();
  setup_playback();

  /* Register to SIP server by creating SIP account. */
  {
    char reg_uri_buf[80] = "sip:";

    char uri_buf[80] = "sip:";
    pjsua_acc_config cfg;
    char *username = argv[1];
    char *password = argv[2];
    char *domain = argv[3];

    strcat(uri_buf, username);
    strcat(reg_uri_buf, domain);

    strcat(uri_buf, "@");
    strcat(uri_buf, domain);

    pjsua_acc_config_default(&cfg);
    cfg.id = pj_str(uri_buf);

    printf("Registering: %.*s.\n", (int)cfg.id.slen, cfg.id.ptr);

    cfg.reg_uri = pj_str(reg_uri_buf);
    cfg.cred_count = 1;
    cfg.cred_info[0].realm = pj_str(domain);
    cfg.cred_info[0].scheme = pj_str("Digest");
    cfg.cred_info[0].username = pj_str(username);
    cfg.cred_info[0].data_type = PJSIP_CRED_DATA_PLAIN_PASSWD;
    cfg.cred_info[0].data = pj_str(password);
    cfg.register_on_acc_add = PJ_FALSE;

    status = pjsua_acc_add(&cfg, PJ_TRUE, &acc_id);
    if (status != PJ_SUCCESS)
      error_exit("Error adding account", status);

    or_event(OR_READY, "Agent initialized..");
  }

  /* Start by muting the audio device. This a passive agent, and sound
     is just wasted CPU time and uwanted side effects. */
  pjsua_set_no_snd_dev();
  pjsua_set_null_snd_dev();
  fflush(stdout);

  /* Main loop. Wait until user press "q" to quit. */
  for (;;) {
    char option[256];

    if (fgets(option, sizeof(option), stdin) == NULL) {
      or_status(OR_ERROR, "EOF while reading stdin, will quit now..");
      break;
    }

    /* Dial command. */
    if (option[0] == 'd') {
      pj_str_t uri = pj_str(&option[1]);
      status = pjsua_call_make_call(acc_id, &uri, 0, NULL, NULL, NULL);
      if (status != PJ_SUCCESS) {
        or_status(OR_ERROR, "Could not make call");
      } else {
        or_status(OR_OK, "Dialling...");
      }
    }

    /* Register */
    else if (option[0] == 'r') {
      register_account(acc_id);
    }

    /* Unregister */
    else if (option[0] == 'u') {
      unregister_account(acc_id);
    }

    /* Enable autoanswer */
    else if (option[0] == 'a') {
      if (option[1] == '1') {
        autoanswer[0] = true;
        or_status(OR_OK, "Autoanswer enabled.");
      } else {
        or_status(OR_ERROR, "Invalid account.");
      }
    }

    /* Disable autoanswer (manual answer) */
    else if (option[0] == 'm') {
      autoanswer[0] = false;
      or_status(OR_OK, "Autoanswer disabled.");
    }

    /* Pickup default incoming call. */
    else if (option[0] == 'p') {
      if (current_call != PJSUA_INVALID_ID) {
        pjsua_call_answer(current_call, 200, NULL, NULL);
        or_status(OR_OK, "Call picked up.");
      } else {
        or_status(OR_ERROR, "No call to pick up.");
      }
    }

    /* Pickup specific incoming call. */
    else if (option[0] == 'P') {
      char *call_id_s = &option[1];
      int call_id = -1;
      sscanf(call_id_s, "%d", &call_id);

      if (call_id != PJSUA_INVALID_ID) {
        status = pjsua_call_answer(call_id, 200, NULL, NULL);

        if (status != PJ_SUCCESS) {
          or_status(OR_ERROR, "Could not make call");
        } else {
          or_status(OR_OK, "Call picked up.");
        }
      } else {
        or_status(OR_ERROR, "Invalid call id supplied!");
      }
    }

    /* Hangup specific call. */
    else if (option[0] == 'K') {
      char *call_id_s = &option[1];
      int call_id = -1;
      sscanf(call_id_s, "%d", &call_id);

      if (call_id != PJSUA_INVALID_ID) {
        status = pjsua_call_hangup(call_id, 0, NULL, NULL);

        if (status != PJ_SUCCESS) {
          or_status(OR_ERROR, "Could not hang up call");
        } else {
          or_status(OR_OK, "Call hung up.");
        }
      } else {
        or_status(OR_ERROR, "Invalid call id supplied!");
      }
    }

    /* Hang up current call */
    else if (option[0] == 'H') {
      if (current_call != PJSUA_INVALID_ID) {
        pjsua_call_hangup(current_call, 0, NULL, NULL);
        or_status(OR_OK, "Hanging up current call...");
      } else {
        or_status(OR_ERROR, "No call to hang up.");
      }
    }

    /* Full hangup.. */
    else if (option[0] == 'h') {
      pjsua_call_hangup_all();
      or_status(OR_OK, "Hanging up all calls...");
    }

    /* Status  */
    else if (option[0] == 's') {
      or_dump_status();
    }

    /* Exit application. */
    else if (option[0] == 'q') {
      break;
    }

    else {
      or_status(OR_ERROR, "Unknown command:");
    }
  }
  pjsua_destroy();
  or_status(OR_OK, "Exiting...");

  return 0;
}

void or_event_incoming_call(char *extension, int call_id, int call_state) {
  json_object *jobj = json_object_new_object();
  json_object *jcall = json_object_new_object();

  json_object_object_add(
      jobj, "event",
      json_object_new_string(or_event_to_string(OR_CALL_INCOMING)));
  // Build call object.
  json_object_object_add(jcall, "extension", json_object_new_string(extension));
  json_object_object_add(jcall, "id", json_object_new_int(call_id));
  json_object_object_add(jcall, "state", json_object_new_int(call_state));

  // Add call object.
  json_object_object_add(jobj, "call", jcall);

  fprintf(stdout, "%s\n", json_object_to_json_string(jobj));
  fflush(stdout);
}

void or_event_outgoing_call(char *extension, int call_id, int call_state) {
  json_object *jobj = json_object_new_object();
  json_object *jcall = json_object_new_object();

  json_object_object_add(
      jobj, "event",
      json_object_new_string(or_event_to_string(OR_CALL_OUTGOING)));
  // Build call object.
  json_object_object_add(jcall, "extension", json_object_new_string(extension));
  json_object_object_add(jcall, "id", json_object_new_int(call_id));
  json_object_object_add(jcall, "state", json_object_new_int(call_state));

  // Add call object.
  json_object_object_add(jobj, "call", jcall);

  fprintf(stdout, "%s\n", json_object_to_json_string(jobj));
  fflush(stdout);
}

void or_event_account_state(int account_id, bool registered) {
  json_object *jobj = json_object_new_object();
  json_object *jaccount = json_object_new_object();

  json_object_object_add(
      jobj, "event",
      json_object_new_string(or_event_to_string(OR_ACCOUNT_STATE)));
  // Build call object.
  json_object_object_add(jaccount, "id", json_object_new_int(account_id));
  json_object_object_add(jaccount, "registered",
                         json_object_new_boolean(registered));

  // Add call object.
  json_object_object_add(jobj, "account", jaccount);

  fprintf(stdout, "%s\n", json_object_to_json_string(jobj));
  fflush(stdout);
}
