```
   ____                   _____                     _   _             
  / __ \                 |  __ \                   | | (_)            
 | |  | |_ __   ___ _ __ | |__) |___  ___ ___ _ __ | |_ _  ___  _ __  
 | |  | | '_ \ / _ \ '_ \|  _  // _ \/ __/ _ \ '_ \| __| |/ _ \| '_ \ 
 | |__| | |_) |  __/ | | | | \ \  __/ (_|  __/ |_) | |_| | (_) | | | |
  \____/| .__/ \___|_| |_|_|  \_\___|\___\___| .__/ \__|_|\___/|_| |_|
        | |                                  | |                      
        |_|                                  |_|                      
```
# OpenReception

The OpenReception project is an inbound call-center software stack built to
provide a turn-key solution for external reception hosting companies as well
as front-desk receptionists.

The system consists of a set of microservices, a call-handling client and a
back-office application for datatore management.

## Prerequisites

In order to install this software you need:

  - A computer running a recent Linux for the stack
  - The FreeSWITCH soft-PBX (version 1.4+)
  - A SIP-capable phone for each call-handling agent (hardware or software)
    with auto-answer feature
  - A web server capable of serving flat files
  - A Google Account for setting up OAuth2.

### FreeSWITCH

The OpenReception projects uses the software PBX FreeSWITCH as its telephony
and dialplan routing platform, so you will need to install the FreeSWITCH
software prior to running OpenReception.

Please follow the official FreeSWITCH installation docs located at:

  https://freeswitch.org/confluence/display/FREESWITCH/Installation

### SIP-Phones

The system have been successfully depoyed using physical SNOM [1] phones


## Installation

After FreeSWITCH is installed (see Prerequisites), the stack may be built.
Go to the project root folder and run:

   make build


### Creating a new datastore

  dart bin/datastore_ctl.dart create --filestore ~/openreception-datastore

### Add an admin user

  dart bin/datastore_ctl.dart manage --add-admin-identity user@examplecom  --filestore ~/openreception-datastore

### Generate authentication tokens


### Create an OAuth2 account at Google

Follow the instructions found at [2].


[1] https://www.snom.com/
[2] https://developers.google.com/identity/protocols/OAuth2