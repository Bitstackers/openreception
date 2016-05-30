### cdrctl
CLI program to manage parsing, storage and summaries / reporting from
[FreeSWITCH](http://freeswitch.org) CDR files.

### Dependencies
Since `cdrctl` upload files to Google Cloud, it requires a valid Service Account
key to an active Google Cloud project.

Other than that, all you need is [Dart](https://www.dartlang.org/).

### Installing and starting
Follow these few simple steps to get `cdrctl` up and running:

* `git clone https://github.com/Bitstackers/cdrctl.git`
* `cd cdrctl/`
* `cp bin/config.dart.dist bin/config.dart`
* Adjust `bin/config.dart`
* `cp makefile.setup.dist makefile.setup`
* Adjust makefile.setup
* `make`
* Run cdrctl with `dart /path/to/cdrctl.dart` where `/path/to` is the
`PREFIX` value found in `makefile.setup`

**NOTE:** The configuration is part of the final executable. If you make changes to
`bin/config.dart` then remember to call `make` again to produce a new executable.

If you don't like that, you can dump a `cdrctl.json` file in one of:

* the directory from where you're calling `cdrctl.dart`
* `~/.cdrctl/`
* `/etc/cdrctl/`

If any one of the above contains a `cdrctl.json` file, it will be loaded and
used instead of the build-in configuration.

See `bin/cdrctl.json.dist` for an example file.

### Google Cloud Storage object lifecycle management
To keep your bucket from growing forever in size, it is a good idea to set up
a basic object lifecycle configuration. You can find an example of one such in
`misc/lifecycle.json`.

To activate:

```bash
$ gsutil lifecycle set misc/lifecycle.json gs://bucket_name
```

You can check the current lifecycle configuration with this:

```bash
$ gsutil lifecycle get gs://bucket-name
```

### Logging to rsyslog
Take a look at the following two files:

  `misc/cdrctl.rsyslog.conf` and `misc/cdrctl.logrotate.conf`

Adjust them according to your needs and copy them to `/etc/rsyslog.d/` and
`/etc/logrotate.d/` respectively. Restart `rsyslog` and then start `cdrctl`
like this:

```bash
$ dart cdrctl.dart 2>&1 | logger -t "cdrctl" &
```

Now lean back and feel comfort in knowing that `rsyslog` and `logrotate` takes
good care of the `cdrctl` log data.

### Let Supervisor handle start/stop and logging
Take a look at `misc/cdrctl.supervisor.conf` and adjust it to your needs.
Copy the file to `/etc/supervisor/conf.d/` and let supervisor work its magic.

[Read more about the wonders of Supervisor](http://supervisord.org/)
