###  - moving files to Google Drive
drvupld simply polls a directory for files, and uploads all non-directory
files it finds to the configured Google Drive folders.

### Dependencies
Besides [Dart](https://www.dartlang.org/), drvupld depends on running instances of:

* OpenReception/server_stack/config server
* OpenReception/server_stack/reception server
* OpenReception/server_stack/callflow server

[OpenReception](https://github.com/Bitstackers/openreception)

drvupld also requires a Google Service Account with domain-wide delegation
activated, which in turn means it will only work for Google Apps accounts. Read
more here: https://developers.google.com/identity/protocols/OAuth2ServiceAccount

### File format
drvupld requires files to be named in the following format:

`"agent"-[agentId]-[msec timestamp]_[uuid]_[rid]_["in"|"out"]_[remote number].wav`

* `"agent"-[agentId]-[msec timestamp]` is the channel id.
* `[agentId]` is an int agent id.
* `[msec timestamp]` is an int Unix timestamp in milliseconds (local server time).
* `[uuid]` is a string uuid (rfc4122). This uniquely identifies a call.
* `[rid]` is an int reception id.
* `["in"|"out"]` is the call direction.
* `[remote_number]` is a string telephone number. The direction decides whether
this is a caller (in) or callee (out) number.

drvupld resolves the rid to the actual extension (telephonenumber) of
the reception. This is REQUIRED to be a danish telephone number with an exact
length of 8 characters.

### Folder/file structure of uploads
Files are stored to Google Drive using the following folder/file setup:

```
  config.allFolder
    |__ [year-folder]
          |__ [date-folder]
                |__ [all-files]
  config.agentsFolder
    |__ [year-folder]
          |__ [date-folder]
                |__ [agent-name-folder]
                      |__ [agent-files]
  config.receptionsFolder
    |__ [year-folder]
          |__ [date-folder]
                |__ [short-reception-extension-folder]
                      |__ [reception-extension-folder]
                            |__ [reception-files]
```

### Installing and starting
Follow these few simple steps to get drvupld up and running:

* `git clone https://github.com/Bitstackers/openreception`
* `cd tools/drvupld/`
* `cp bin/config.dart.dist bin/config.dart`
* Adjust `bin/config.dart`
* `cp makefile.setup.dist makefile.setup`
* Adjust makefile.setup
* `make`
* Run drvupld with `dart /path/to/drvupld.dart` where `/path/to` is the
`PREFIX` value found in `makefile.setup`

**NOTE:** The configuration is part of the final executable. If you make changes to
`bin/config.dart` then remember to call `make` again to produce a new executable.

**NOTE:** Make sure you monitor drvupld, since it will exit if calls to Google
Drive API are stuck for more than 300 seconds. If you use supervisord, then the
monitoring/restarting is automatically handled for you.

### Logging to rsyslog
Take a look at the following two files:

  `misc/drvupld.rsyslog.conf` and `misc/drvupld.logrotate.conf`

Adjust them according to your needs and copy them to `/etc/rsyslog.d/` and
`/etc/logrotate.d/` respectively. Restart `rsyslog` and then start drvupld
like this:

```bash
$ dart drvupld.dart 2>&1 | logger -t "drvupld" &
```

Now lean back and feel comfort in knowing that `rsyslog` and `logrotate` now
takes good care of the drvupld log data.

### Let Supervisor handle start/stop and logging
Take a look at `misc/drvupld.supervisor.conf` and adjust it to your needs.
Copy the file to `/etc/supervisor/conf.d/` and let supervisor work its magic.

[Read more about the wonders of Supervisor](http://supervisord.org/)
