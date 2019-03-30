DESTDIR =
prefix = /usr/pkg
bindir = $(prefix)/bin
libexecdir = $(prefix)/libexec
datadir = $(prefix)/share

CXX	= g++
RM	= rm -f
INSTALL = /usr/bin/install
PKGCONFIG = $(bindir)/pkg-config

MOZC_SRC = ..
MOZC_RELEASE = $(MOZC_SRC)/out_bsd/Release

CFLAGS	= -O -std=gnu++11
CFLAGS += -DOS_NETBSD


LDFLAGS	=

INCS	= -I$(MOZC_SRC) \
	      -I$(MOZC_RELEASE)/gen \
	      -I$(MOZC_RELEASE)/gen/proto_out \
	      -I$(prefix)/include

MOZC_CONF	= mozc-config

MOZC_CONF_OBJS	= mozc_config_main.o

#MOZC_DICT	= mozc-dict

#MOZC_DICT_OBJS	= mozc_dict_main.o

EXTOBJS	= $(MOZC_RELEASE)/obj/protocol/gen/proto_out/protocol/config_proto.config.pb.o \
          $(MOZC_RELEASE)/obj/config/libconfig_handler.a \
		  $(MOZC_RELEASE)/obj/dictionary/libsuppression_dictionary.a \
		  $(MOZC_RELEASE)/obj/dictionary/libuser_dictionary.a \
          $(MOZC_RELEASE)/obj/base/*.a


LIBS	!= $(PKGCONFIG) protobuf --libs

IBUS_SETUP_MOZC = ibus-setup-mozc

IBUS_MOZC_DICT = ibus-mozc-dict

MOS = ja.mo

all:	$(MOZC_CONF) $(MOZC_DICT) $(MOS)

$(MOZC_CONF):	$(MOZC_CONF_OBJS)
	$(CXX) $(LDFLAGS) -o $@ $(MOZC_CONF_OBJS) $(EXTOBJS) $(LIBS)

$(MOZC_DICT):	$(MOZC_DICT_OBJS)
	$(CXX) $(LDFLAGS) -o $@ $(LIBS) $(MOZC_DICT_OBJS) $(EXTOBJS)

$(IBUS_SETUP_MOZC) :	$(IBUS_SETUP_MOZC).in
	sed -e 's|@LOCALE_DIR@|$(DESTDIR)/$(datadir)/locale|' \
		-e 's|@IBUS_MOZC_DIR@|$(DESTDIR)/$(datadir)/ibus-mozc/setup|' \
		-e 's|@BIN_DIR@|$(DESTDIR)/$(bindir)|' $@.in > $@
	chmod +x $@

$(IBUS_MOZC_DICT) :	$(IBUS_MOZC_DICT).in
	sed -e 's|@LOCALE_DIR@|$(DESTDIR)/$(datadir)/locale|' \
		-e 's|@IBUS_MOZC_DIR@|$(DESTDIR)/$(datadir)/ibus-mozc/setup|' \
		-e 's|@BIN_DIR@|$(DESTDIR)/$(bindir)|' $@.in > $@
	chmod +x $@

install: all $(IBUS_SETUP_MOZC) $(IBUS_MOZC_DICT)
	$(INSTALL) -d $(DESTDIR)/$(bindir)
	$(INSTALL) -d $(DESTDIR)/$(libexecdir)
	$(INSTALL) -d $(DESTDIR)/$(datadir)/locale/ja/LC_MESSAGES
	$(INSTALL) -d $(DESTDIR)/$(datadir)/ibus-mozc/setup
	$(INSTALL) -m755 $(MOZC_CONF) $(MOZC_DICT) $(DESTDIR)/$(bindir)
	$(INSTALL) -m755 $(IBUS_SETUP_MOZC) $(DESTDIR)/$(libexecdir)
	$(INSTALL) -m755 $(IBUS_MOZC_DICT) $(DESTDIR)/$(libexecdir)
	$(INSTALL) -m644 ja.mo $(DESTDIR)/$(datadir)/locale/ja/LC_MESSAGES/ibus-mozc.mo
	$(INSTALL) -m644 setup.glade $(DESTDIR)/$(datadir)/ibus-mozc/setup
	$(INSTALL) -m644 dict.glade $(DESTDIR)/$(datadir)/ibus-mozc/setup
 
clean:
	$(RM) $(MOZC_CONF) $(MOZC_CONF_OBJS) $(MOZC_DICT) $(MOZC_DICT_OBJS) $(IBUS_SETUP_MOZC) $(MOS) $(IBUS_MOZC_DICT)

.SUFFIXES: .cc .o .po .mo

.cc.o:
	$(CXX) $(CFLAGS) $(INCS) -c $<

.po.mo:
	msgfmt -o $*.mo $*.po

