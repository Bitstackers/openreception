### wavadjust
CLI program to adjust WAV files to a suitable FreeSWITCH voicemail format.

### Dependencies
You need two things:

* [Dart](https://www.dartlang.org/)
* [sox and soxi](http://sox.sourceforge.net/) version >= v14.4.1 and < v15

### Installing
Follow these few simple steps to get `wavadjust` up and running:

* `git clone https://github.com/Bitstackers/openreception.git`
* `cd tools/wavadjust/`
* `cp makefile.setup.dist makefile.setup`
* Adjust makefile.setup
* `make`
* Run wavadjust with `dart /path/to/wavadjust.dart` where `/path/to` is the
`PREFIX` value found in `makefile.setup`

### usage
To adjust stereo 48K WAV files to mono 8K files do this:

`dart wavadjust.dart -i infile1.wav,infile2.wav -o /tmp/somefolder`

The above will dump two new files named `infile1.wav` and `infile2.wav` in the
`/tmp/somefolder` directory.

To get help: `dart wavadjust.dart -h`
