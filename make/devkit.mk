#
# devkit.mk --Recursive make considered useful.
#
# Contents:
# build:     --The default target
# STD_DIR:   --The standard target directories are built as needed.
# INSTALL_*: --Specialised install commands.
# install:   --common requirements of the install target(s)
# src:       --Make sure the src target can write to the Makefile
# clean:     --Devkit-specific customisations for the "clean" target.
# distclean: --devkit-specific customisations for the "distclean" target.
#
# Remarks:
# These makefiles taken together define a build system that extends
# the "standard" targets (as documented by GNU make) with a few extras
# for performing common maintenance functions.  The basic principles
# are:
#
# * the standard make targets are magically recursive
# * $(LANGUAGE).mk extends standard targets by defining "dependent" actions
# * per-system tool customisations defined in $(OS).mk, $(ARCH).mk
# * all system-specific files are saved in $(archdir) subdirectory
# * file dependencies are auto-included, and auto-generated by build target.
# * traditional macros work as expected (e.g. CFLAGS, LDFLAGS)
# 
# This file defines variables according to the conventions described
# in the GNU make documentation (c.f. "Makefile Conventions" section).
#
# Note that I'm not being truly faithful to the GNU doc.s, in particular
# I avoid the $(archdir) suffix, for most of the installation directories.
# I'm sure this will come back to bite me later...
#
SUBDIRS := $(shell find . -maxdepth 1 -type d -name '[^.]*' | cut -d/ -f2)
ECHO = :				# enable by: make ECHO=echo
SHELL	= /bin/sh
archdir	= $(OS)-$(ARCH)

.SUFFIXES:			# remove default suffix rules

#
# build: --The default target
#
build:	; 	@$(ECHO) "++ make[$@]@$$PWD"
all:	build
#
# Standard directories
#
# Remarks:
# These directories are set according to a blend of the following variables:
# * DESTDIR	-- an alternative root (e.g. chroot jail, pkg-building root)
# * prefix	-- the application's idea of its root installation directory
# * opt		-- FSHS "opt" component (undefined if not FSHS)
# * usr		-- bindir modfier: either undefined or "usr"
# * archdir	-- system+architecture-specific bindir modifier (unused)
#
# In typical usage, DESTDIR should be undefined (it's explicitly set
# as needed by some of the packaging targets), and prefix should be
# set to either "/usr/local" or $HOME (or a subdirectory).  Note that
# GNU make will search for include files in /usr/local/include, so
# installing devkit itself into /usr/local is a win.  However if you
# install devkit into $HOME, you must use/alias make as
# "make -I$HOME/include".
#
rootdir 	= $(DESTDIR)/$(prefix)
rootdir_opt 	= $(DESTDIR)/$(prefix)/$(opt)
#exec_prefix = $(rootdir)/$(archdir)	# (GNU std)
exec_prefix	= $(rootdir_opt)/$(usr)

bindir		= $(exec_prefix)/bin
sbindir 	= $(exec_prefix)/sbin
#libexecdir	= $(exec_prefix)/libexec/$(archdir)	# (GNU std)
libexecdir	= $(exec_prefix)/libexec/$(subdir)
datadir		= $(exec_prefix)/share/$(subdir)

sysconfdir	= $(rootdir)/etc/$(opt)/$(subdir)
divertdir	= $(rootdir)/var/lib/divert/$(subdir)
sharedstatedir	= $(rootdir_opt)/com/$(subdir)
localstatedir	= $(rootdir)/var/$(opt)/$(subdir)
srvdir 		= $(rootdir)/srv/$(subdir)
wwwdir 		= $(rootdir)/srv/www/$(subdir)

#libdir		= $(exec_prefix)/lib/$(archdir)	# (GNU std)
libdir		= $(exec_prefix)/lib/$(subdir)
perllibdir	= $(exec_prefix)/lib/perl5/$(subdir)
infodir		= $(rootdir_opt)/info
lispdir		= $(rootdir_opt)/share/emacs/site-lisp

includedir	= $(rootdir_opt)/include/$(subdir)
mandir		= $(datadir)/man
man1dir		= $(mandir)/man1
man3dir		= $(mandir)/man3
man4dir		= $(mandir)/man4

#
# STD_DIR: --The standard target directories are built as needed.
#
# Remarks:
# Note that we avoid using "mkdir -p", but use "install -d" instead,
# mainly because the GNU Make doc.s deprecate "mkdir -p".
#
# This target obviates the need for installdirs (mostly), provided
# the install targets themselves declare a dependency on the directory.
#
$(archdir) $(bindir) $(sbindir) $(libexecdir) \
    $(sysconfdir) $(divertdir) \
    $(sharedstatedir) $(localstatedir) \
    $(datadir) $(srvdir) $(wwwdir) \
    $(libdir) $(perllibdir) $(infodir) $(lispdir) \
    $(includedir) $(mandir) $(man1dir) $(man3dir) $(man4dir):
	test -d '$@' || $(INSTALL_DIRECTORY) $@

#
# INSTALL_*: --Specialised install commands.
#
# Remarks:
# Script installation is a little messy because I'm re-writing the
# first-line '#!' magic to the target host's script-path.
# REVISIT: consider using "#!/env", instead of this silliness.
#
INSTALL 	  = install
INSTALL_PROGRAM   = $(INSTALL) -m 755
INSTALL_DATA      = $(INSTALL) -m 644
INSTALL_DIRECTORY = $(INSTALL) -d
INSTALL_SCRIPT = install_script() { \
    echo "$(INSTALL_PROGRAM) $$2 $$3"; \
    <$$2 sed -e "1s|!.*|!$$1|" > $$$$.tmp \
    && $(INSTALL_PROGRAM) $$$$.tmp $$3 \
    && $(RM) $$$$.tmp; }; install_script

#
# src: --Make sure the src target can write to the Makefile
#
src:			file-writable[Makefile]

#
# bindir/archdir: --rules for installing any executable in archdir.
#
$(bindir)/%:		$(archdir)/%;	$(INSTALL_PROGRAM) $? $@
$(libexecdir)/%:	$(archdir)/%;	$(INSTALL_PROGRAM) $? $@

#
# %.gz: --Rules for building compressed/summarised data.
#
%.gz:			%;		gzip -9 <$* >$@
%.gpg:			%;		gpg -b -o $* $@
%.sum:			%;		sum $* | sed -e 's/ .*//' >$@

#
# clean: --Devkit-specific customisations for the "clean" target.
#
clean:	devkit-clean
.PHONY:	devkit-clean
devkit-clean:
	@$(ECHO) "++ make[$@]@$$PWD"
	$(RM) core *~ *.bak *.tmp *.out

#
# distclean: --devkit-specific customisations for the "distclean" target.
#
distclean:	devkit-clean devkit-distclean
.PHONY:	devkit-distclean
devkit-distclean:
	@$(ECHO) "++ make[$@]@$$PWD"
	$(RM) tags TAGS
	$(RM) -r $(OS) $(ARCH) $(archdir)

include targets.mk valid.mk
include lang/mk.mk $(LANG:%=lang/%.mk)
include os/$(OS).mk
include arch/$(ARCH).mk
include vcs/$(VCS).mk

#
# print-%:	pattern rule to print a make variable.
#
print-%:
	@echo "# in $(origin $*):"
	@echo "# $* = $(value $*)"
	@echo "$* = $($*)"
