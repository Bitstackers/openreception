#export TARGET_NAME := x86_64-unknown-linux-gnu
export LIB_DIR := $(PWD)

PJVERSION=2.1

PJBASE=$(PWD)/pjproject-${PJVERSION}
PJOPTS=--enable-static  --disable-sound
-include $(PJBASE)/build.mak

CC      = $(APP_CC)
LDFLAGS = $(APP_LDFLAGS)
LDLIBS  = $(APP_LDLIBS)
CFLAGS  = $(APP_CFLAGS)
CPPFLAGS= ${CFLAGS}
OBJ_DIR = objects/
#DEBUG   = "-DDEBUG"

all: basic_agent

deps: pjlibs

basic_agent: deps_install
	$(CC) -std=c99 -Wall -DDAEMONIZE=0 $(DEBUG) -Llib -Iinclude $(PWD)/src/$@.c -o $@ $(CPPFLAGS) $(LDFLAGS) $(LDLIBS)

clean:
	-rm objects/*.o

distclean: clean
	-rm basic_agent
	-rm deps_install pjlibs
	-rm -rf lib/ include/ pjproject-2.0/ pjproject-2.1 pjproject-2.1.0/
	-rm pjproject-2.1.tar.bz2
	-rm pjproject-2.0.tar.bz2

pjproject-2.0: pjproject-2.0.tar.bz2
	tar xjf pjproject-2.0.tar.bz2
	touch $@

pjproject-2.1: pjproject-2.1.tar.bz2
	tar xjf pjproject-2.1.tar.bz2
	-ln -s pjproject-2.1.0 pjproject-2.1
	touch $@

pjlibs: pjproject-${PJVERSION}
	(cd pjproject-${PJVERSION}; ./configure --prefix=$(LIB_DIR) ${PJOPTS}  && make lib && make && make install)	
	touch $@

pjproject-2.1.tar.bz2:
	wget http://www.pjsip.org/release/2.1/$@
	touch $@

deps_install: pjlibs
	(cd pjproject-2.1; make install);
	touch $@

.PHONY:  basic_agent
