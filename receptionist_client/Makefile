HOME=$(CURDIR)

deployment: dart-sdk copy-static-files update-pub compile-js link-to-packages
	rm deploy/pubspec.*

dart-sdk:
	make -C lib dart-sdk
	echo $(HOME)

copy-static-files: dart-sdk
	-mkdir deploy
	-cp -r src/* deploy
	-cp -r pubspec.* deploy

	# Delete old packages/ directories
	-rm -r deploy/css/packages
	-rm -r deploy/css_old/packages
	-rm -r deploy/dart/packages
	-rm -r deploy/img/packages
	-rm -r deploy/js/packages

link-to-packages: update-pub copy-static-files
	# Create links to the local packages cache.
	mkdir deploy/dart/packages
	for lib_dir in deploy/.pub-cache/hosted/pub.dartlang.org/*/lib; do package=$$(basename $$(dirname $${lib_dir})); ln -s $$(pwd)/$${lib_dir} deploy/dart/packages/$${package/-*}; done

compile-js: dart-sdk copy-static-files update-pub link-to-packages
	lib/dart-sdk/bin/dart2js --minify -odeploy/dart/bob.dart.js deploy/dart/bob.dart

	# Delete and re-create the deploy/packages directory.
	-rm -r deploy/packages

update-pub: copy-static-files dart-sdk
	(cd deploy && HOME=$(CURDIR)/deploy ../lib/dart-sdk/bin/pub update)

distclean:
	-rm -r deploy
	make -C lib distclean
