#!/bin/sh
#
# _MK.SH	--Create the fallback ".mk" file for the VCS directory
#
date=$(date)
vcs_list=$(echo *.mk| sed -e s/.mk//g)
cat <<EOF
#
# .MK --Fallback make definitions for VCS customisation.
#
# Remarks:
# Do not edit this file! 
# it was automatically generated on $date
#
\$(info "VCS" must have one of the following values:)
\$(info $vcs_list)
\$(error The variable "VCS" is not defined. )
EOF