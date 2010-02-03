prefix = /usr

CFLAGS = -g -O2

PERL = perl
INSTALL = install

whois_OBJECTS := whois.o utils.o
mkpasswd_OBJECTS := mkpasswd.o utils.o

##############################################################################
# Solaris
#whois_LDADD += -lnsl -lsocket -liconv

# FreeBSD
#whois_LDADD += -liconv
#LIBS += -L/usr/local/lib -lintl
#INCLUDES += -I/usr/local/include

# OS/2 EMX
#whois_LDADD += -lsocket
#LDFLAGS += -Zexe -Dstrncasecmp=strnicmp

# OS X
#whois_LDADD += -liconv

ifdef CONFIG_FILE
DEFS += -DCONFIG_FILE=\"$(CONFIG_FILE)\"
endif

ifdef LOCALEDIR
DEFS += -DLOCALEDIR=\"$(BASEDIR)$(prefix)/share/locale\"
endif

ifdef HAVE_LIBIDN
whois_LDADD += -lidn
DEFS += -DHAVE_LIBIDN
endif

ifdef HAVE_ICONV
whois_OBJECTS += simple_recode.o
DEFS += -DHAVE_ICONV
endif

ifdef HAVE_XCRYPT
mkpasswd_LDADD += -lxcrypt
DEFS += -DHAVE_XCRYPT
else
mkpasswd_LDADD += -lcrypt
endif

##############################################################################
all: Makefile.depend whois mkpasswd #pos

##############################################################################
%.o: %.c
	$(CC) $(DEFS) $(INCLUDES) $(CFLAGS) -c $<

whois: $(whois_OBJECTS)
	$(CC) $(LDFLAGS) -o $@ $^ $(whois_LDADD) $(LIBS)

mkpasswd: $(mkpasswd_OBJECTS)
	$(CC) $(LDFLAGS) -o $@ $^ $(mkpasswd_LDADD) $(LIBS)

##############################################################################
as_del.h: as_del_list make_as_del.pl
	$(PERL) -w make_as_del.pl < $< > $@

as32_del.h: as32_del_list make_as32_del.pl
	$(PERL) -w make_as32_del.pl < $< > $@

ip_del.h: ip_del_list make_ip_del.pl
	$(PERL) -w make_ip_del.pl < $< > $@

ip6_del.h: ip6_del_list make_ip6_del.pl
	$(PERL) -w make_ip6_del.pl < $< > $@

tld_serv.h: tld_serv_list make_tld_serv.pl
	$(PERL) -w make_tld_serv.pl < $< > $@

servers_charset.h: servers_charset_list make_servers_charset.pl
	$(PERL) -w make_servers_charset.pl < $< > $@

##############################################################################
install: install-whois install-mkpasswd #install-pos

install-whois: whois
	$(INSTALL) -d $(BASEDIR)$(prefix)/bin/
	$(INSTALL) -d $(BASEDIR)$(prefix)/share/man/man1/
	$(INSTALL) -m 0755 whois $(BASEDIR)$(prefix)/bin/
	$(INSTALL) -m 0644 whois.1 $(BASEDIR)$(prefix)/share/man/man1/

install-mkpasswd: mkpasswd
	$(INSTALL) -d $(BASEDIR)$(prefix)/bin/
	$(INSTALL) -d $(BASEDIR)$(prefix)/share/man/man1/
	$(INSTALL) -m 0755 mkpasswd $(BASEDIR)$(prefix)/bin/
	$(INSTALL) -m 0644 mkpasswd.1 $(BASEDIR)$(prefix)/share/man/man1/

install-pos:
	cd po && $(MAKE) install

distclean: clean
	rm -f po/whois.pot

clean:
	rm -f Makefile.depend as_del.h ip_del.h ip6_del.h tld_serv.h \
		*.o whois mkpasswd
	rm -f po/*.mo

pos:
	cd po && $(MAKE)

depend: Makefile.depend
Makefile.depend:
	$(CC) $(DEFS) $(INCLUDES) $(CFLAGS) -MM -MG *.c > $@

-include Makefile.depend
