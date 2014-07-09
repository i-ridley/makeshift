#
# LIBRARY.MK: rules to build and install a library composed of a set of objects.
#
# Contents:
# libdir/%.a:          --Install a static (.a)library
# pre-build:           --Install the include files
# %/lib.a:             --Build the sub-librar(ies) in its subdirectory.
# build:               --Build this directory's library.
# lib-install-lib:     --Install the library (and include files).
# lib-install-include: --Install the library include files.
# lib-install-man:     --Install manual pages for the library.
# archdir/%.a:         --(re)build a library.
# clean:               --Remove the library file.
# distclean:           --Remove the include files installed at $LIB_ROOT/include.
# src:                 --Get a list of sub-directories that are libraries.
#
# Remarks:
# This is an attempt to manage a collection of object files (i.e. ".o" files)
# as an object library (i.e. ".a").  The library can be structured
# as a collection of "sub" libraries built from code in sub-directories.
# The top-level directory delegates building of the sub-libraries to
# recursive make targets, and then assembles them all into one
# master library.
#
# These rules require that following variables are defined:
#
#  * LIB_ROOT --the root location of the main top-level library
#  * LIB      --the name of the library to build
#  * LIB_OBJ  --the objects to put into the library.
#
LIB_INCLUDEDIR=$(LIB_ROOT)/include/$(subdir)
LIB_INCLUDE_SRC = $(H_SRC:%.h=$(LIB_INCLUDEDIR)/%.h) \
    $(HXX_SRC:%.hpp=$(LIB_INCLUDEDIR)/%.hpp)

$(LIB_INCLUDEDIR)/%.h:		%.h;		$(INSTALL_FILE) $*.h $@
$(LIB_INCLUDEDIR)/%.hpp:	%.hpp;		$(INSTALL_FILE) $*.hpp $@

#
# libdir/%.a: --Install a static (.a)library
#
$(libdir)/%.a:	$(archdir)/%.a
	$(ECHO_TARGET)
	$(INSTALL_FILE) $? $@
	$(RANLIB) $@

#
# pre-build: --Install the include files
#
pre-build:      $(LIB_INCLUDE_SRC)

#
# %/lib.a: --Build the sub-librar(ies) in its subdirectory.
#
%/$(archdir)/lib.a:     build@%;     $(ECHO_TARGET)

#
# build: --Build this directory's library.
#
build:	var-defined[LIB_ROOT] var-defined[LIB] var-defined[LIB_OBJ] \
	$(archdir)/lib$(LIB).a

#
# lib-install-lib: --Install the library (and include files).
# lib-install-include: --Install the library include files.
# lib-install-man: --Install manual pages for the library.
#
lib-install-lib:	$(libdir)/lib$(LIB).a lib-install-include
lib-install-include:	$(H_SRC:%.h=$(includedir)/%.h)
lib-install-include:	$(HXX_SRC:%.hpp=$(includedir)/%.hpp)
lib-install-man:	$(MAN3_SRC:%.3=$(man3dir)/%.3)

$(libdir)/lib$(LIB).a:	$(archdir)/lib$(LIB).a

#
# archdir/%.a: --(re)build a library.
#
$(archdir)/lib.a:	$(LIB_OBJ) $(SUBLIB_SRC)
	$(ECHO_TARGET)
	$(AR) $(ARFLAGS) $@ $(LIB_OBJ)
	ar-merge -v $@ $(SUBLIB_SRC)
	$(RANLIB) $@

$(archdir)/lib$(LIB).a:	$(archdir)/lib.a
	$(ECHO_TARGET)
	cp $< $@
	$(RANLIB) $@

#
# clean: --Remove the library file.
#
clean:	lib-clean
lib-clean:
	$(ECHO_TARGET)
	$(RM) $(archdir)/lib$(LIB).a $(archdir)/lib.a

#
# distclean: --Remove the include files installed at $LIB_ROOT/include.
#
distclean: lib-clean lib-distclean
lib-distclean:
	$(ECHO_TARGET)
	$(RM) $(LIB_INCLUDE_SRC)

#
# src: --Get a list of sub-directories that are libraries.
#
src:	lib-src
lib-src:
	$(ECHO_TARGET)
	@mk-filelist -qpn SUBLIB_SRC $$( \
	    grep -l '^include.* library.mk' */Makefile 2>/dev/null | \
	    sed -e 's|Makefile|$$(archdir)/lib.a|g')

+help:  +help-library
