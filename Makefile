
#PREFIX=/opt/noflo-gegl
PREFIX=$(shell echo `pwd`/install)
DEPS=`pkg-config --libs --cflags gegl-0.3 json-glib-1.0`
FLAGS=-Wall -Werror -std=c99

GLIB_MAJOR=2.38
GLIB_VERSION=2.38.2

all: run

run: install
	$(PREFIX)/env.sh ./bin/noflo-gegl

install: noflo-gegl
	cp ./bin/noflo-gegl $(PREFIX)/bin/

noflo-gegl:
	$(PREFIX)/env.sh gcc -o ./bin/noflo-gegl bin/noflo-gegl.c -I. $(FLAGS) $(DEPS)

env:
	mkdir -p $(PREFIX) || true
	sed -e 's|@PREFIX@|$(PREFIX)|' env.sh.in > $(PREFIX)/env.sh
	chmod +x $(PREFIX)/env.sh

glib: env
	cd thirdparty && wget http://ftp.gnome.org/pub/gnome/sources/glib/$(GLIB_MAJOR)/glib-$(GLIB_VERSION).tar.xz
	cd thirdparty && tar -xf glib-$(GLIB_VERSION).tar.xz
	cd thirdparty/glib-$(GLIB_VERSION) && $(PREFIX)/env.sh ./autogen.sh --prefix=$(PREFIX)
	cd thirdparty/glib-$(GLIB_VERSION) && $(PREFIX)/env.sh make -j4 install

babl: env
	cd thirdparty/babl && $(PREFIX)/env.sh ./autogen.sh --prefix=$(PREFIX)
	cd thirdparty/babl && $(PREFIX)/env.sh make -j4 install

gegl: babl env
	cd thirdparty/gegl && $(PREFIX)/env.sh ./autogen.sh --prefix=$(PREFIX)
	cd thirdparty/gegl && $(PREFIX)/env.sh make -j4 install

libsoup: env
	cd thirdparty/libsoup && $(PREFIX)/env.sh ./autogen.sh --prefix=$(PREFIX) --disable-tls-check
	cd thirdparty/libsoup && $(PREFIX)/env.sh make -j4 install

dependencies: gegl babl libsoup

# FIXME: add tests
check: run

.PHONY=all noflo-gegl run
