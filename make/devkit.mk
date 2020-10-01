#
# DEVKIT.MK --Support for build systems written for devkit.
#
# Privide some level of backwards compatibility with build systems that
# were writen prior to the change of name to makeshift.
#

ifneq (${DEVKIT_HOME},)
MAKESHIFT_HOME = ${DEVKIT_HOME}
endif

include makeshift.mk
