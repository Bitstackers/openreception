/**
 * basic_agent.c
 *
 * This is a very simple but fully featured SIP user agent, with the
 * following capabilities:
 *  - SIP registration
 *  - Making and receiving call
 */

#include <stdio.h>
#include <unistd.h>
#include <strings.h>
#include <stdbool.h>
#include <pjsua-lib/pjsua.h>

#define THIS_FILE	"BASIC_AGENT"

typedef enum {AH_ERROR, AH_READY, AH_OK, AH_CALL} ah_status_t;

bool          is_registered = false;
bool          processing    = false;
bool          autoanswer    = true;
pjsua_call_id current_call  = PJSUA_INVALID_ID;


char *ah_status_to_string[] = {
  [AH_ERROR] = "-ERROR",
  [AH_READY] = "+READY",
  [AH_OK] = "+OK",
  [AH_CALL] = "+CALL"
};

/*
 * status()
 *
 * Prints out the usage information.
 */

void ah_status(ah_status_t status, char* message) {
  fprintf (stdout, "%s %s \n", ah_status_to_string[status], message);
  fflush(stdout);
}

/* Callback called by the library upon receiving incoming call */
static void on_incoming_call(pjsua_acc_id acc_id, pjsua_call_id call_id,
                             pjsip_rx_data *rdata) {
  pjsua_call_info ci;

  PJ_UNUSED_ARG(acc_id);
  PJ_UNUSED_ARG(rdata);

  pjsua_call_get_info(call_id, &ci);

  current_call = call_id;

  PJ_LOG(3, (THIS_FILE, "Incoming call from %.*s!!",
             (int) ci.remote_info.slen,
             ci.remote_info.ptr));

  if (autoanswer) {
    pjsua_call_answer(call_id, 200, NULL, NULL);
  } else {
    ah_status(AH_CALL, "Incoming call.");
    pjsua_call_answer(call_id, 180, NULL, NULL);
  }

}

/* Callback called by the library when call's state has changed */
static void on_call_state(pjsua_call_id call_id, pjsip_event *e) {
  pjsua_call_info ci;

  PJ_UNUSED_ARG(e);

  pjsua_call_get_info(call_id, &ci);
  PJ_LOG(3, (THIS_FILE, "Call %d state=%.*s", call_id,
             (int) ci.state_text.slen,
             ci.state_text.ptr));
}

/* Callback called by the library when call's media state has changed */
static void on_call_media_state(pjsua_call_id call_id) {
  pjsua_call_info ci;

  pjsua_call_get_info(call_id, &ci);

  if (ci.media_status == PJSUA_CALL_MEDIA_ACTIVE) {
    // When media is active, connect call to sound device.
    pjsua_conf_connect(ci.conf_slot, 0);
    pjsua_conf_connect(0, ci.conf_slot);
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
  fprintf (stderr, "Usage: %s username password domain clientport\n", command);
}

/**
 * register_account()
 * 
 */


void register_account(pjsua_acc_id acc_id) {

   const int   u_resolution    = 100000;
   const int   retries         = (10 * 1000000) / u_resolution;
   int         reconnect_count = 0;
   pj_status_t status          = !PJ_SUCCESS;

   status = pjsua_acc_set_registration (acc_id, PJ_TRUE);
   if (status != PJ_SUCCESS) { 
      error_exit("Error in register_account()", status);
   }

   pjsua_acc_info account_info;
   pjsua_acc_get_info(acc_id, &account_info);

   while (account_info.status < 200) {
      pjsua_acc_get_info(acc_id, &account_info);

      if(usleep(u_resolution) < 0 || reconnect_count > retries) {
        ah_status (AH_ERROR, "ACCOUNT_TIMEOUT");
        exit(1);
      }
      reconnect_count++;
   }
   is_registered = true;
   ah_status(AH_OK, "Account registered.");
} 

/**
 * unregister_account()
 * 
 */


void unregister_account(pjsua_acc_id acc_id) {

   pj_status_t status = !PJ_SUCCESS;

   if (is_registered) {
      
      const int   u_resolution    = 100000;
      const int   retries         = (10 * 1000000) / u_resolution;
      int         reconnect_count = 0;
      pj_status_t status          = !PJ_SUCCESS;
      
      status = pjsua_acc_set_registration (acc_id, PJ_FALSE);
      if (status != PJ_SUCCESS) { 
         error_exit("Error in unregister_account()", status);
      }

      pjsua_acc_info account_info;
      pjsua_acc_get_info(acc_id, &account_info);

      while (account_info.expires >= 0) {
         pjsua_acc_get_info(acc_id, &account_info);

         if(usleep(u_resolution) < 0 || reconnect_count > retries) {
            ah_status (AH_ERROR, "ACCOUNT_TIMEOUT");
            exit(1);
         }
         reconnect_count++;

      }
      is_registered = false;
   }
   ah_status (AH_OK, "Unregistered account ");
} 

/*
 * main()
 *
 * argv[] contains the registration information.
 */
int main(int argc, char *argv[]) {
  pj_status_t status;

  if (argc < 4) {
    usage(argv[0]);
    exit(1);
  }

  pjsua_acc_id acc_id;

  /* Create pjsua first! */
  status = pjsua_create();
  if (status != PJ_SUCCESS) error_exit("Error in pjsua_create()", status);


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

    pjsua_logging_config_default(&log_cfg);
    log_cfg.console_level = 0; // 0 = Mute console, 3 = somewhat userful, 4 = overly verbose.
    pjsua_media_config_default(&media_cfg);

    status = pjsua_init(&cfg, &log_cfg, &media_cfg);
    if (status != PJ_SUCCESS) error_exit("Error in pjsua_init()", status);
  }
  /* Add UDP transport. */
  {
    pjsua_transport_config cfg;

    pjsua_transport_config_default(&cfg);
    sscanf(argv[4], "%d", &cfg.port);
    status = pjsua_transport_create(PJSIP_TRANSPORT_UDP, &cfg, NULL);
    if (status != PJ_SUCCESS) error_exit("Error creating transport", status);
    printf("Created UDP transport on port %d.\n", cfg.port);
  }

 /* Initialization is done, now start pjsua */
  status = pjsua_start();
  if (status != PJ_SUCCESS) error_exit("Error starting pjsua", status);

  /* Register to SIP server by creating SIP account. */
  {
    char reg_uri_buf[80] = "sip:";

    char uri_buf[80] = "sip:";
    pjsua_acc_config cfg;
    char* username = argv[1];
    char* password = argv[2];
    char* domain   = argv[3];

    strcat (uri_buf, username);
    strcat (reg_uri_buf, domain);

    strcat (uri_buf, "@");
    strcat (uri_buf, domain);

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
    if (status != PJ_SUCCESS) error_exit("Error adding account", status);

    ah_status(AH_READY, "Agent initialized..");

  }

  /* Start by muting the audio device. This a passive agent, and sound
     is just wasted CPU time and uwanted side effects. */
  pjsua_set_null_snd_dev();

  fflush(stdout);
  /* Wait until user press "q" to quit. */
  for (;;) {
    char option[256];

    if (fgets(option, sizeof (option), stdin) == NULL) {
      ah_status (AH_ERROR, "EOF while reading stdin, will quit now..");
      break;
    }

    /* Dial command. */
    if (option[0] == 'd') {
      pj_str_t uri = pj_str(&option[1]);
      status = pjsua_call_make_call(acc_id, &uri, 0, NULL, NULL, NULL);
      if (status != PJ_SUCCESS) {
        ah_status (AH_ERROR, "Could not make call");
      }
      else {
        ah_status (AH_OK, "Dialling...");
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
      autoanswer = true;
      ah_status(AH_OK, "Autoanswer enabled.");
    }

    /* Disable autoanswer (manual answer) */
    else if (option[0] == 'm') {
      autoanswer = false;
      ah_status(AH_OK, "Autoanswer disabled.");
    }

    /* Pickup incoming call, unsupported for now. */
    else if (option[0] == 'p') {
      if (current_call != PJSUA_INVALID_ID) { 
        pjsua_call_answer(current_call, 200, NULL, NULL);
      } else {
        ah_status(AH_ERROR, "No call to pick up.");
      }
    }

    /* Full hangup.. */
    else if (option[0] == 'h') {
      pjsua_call_hangup_all();
      ah_status (AH_OK, "Hangin up all calls...");
    }

    /* Exit application. */
    else if (option[0] == 'q') {
      break;
    }
   
    else {
      ah_status (AH_ERROR, "Unknown command:");
    }
  }
  pjsua_destroy();
  ah_status (AH_OK, "Exiting...");

  return 0;
}
