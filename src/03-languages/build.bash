#!/bin/bash

#   ############################################################################
#   src/03-languages/build.bash
#
#   Build flex file & properties for all languages
#   ----------------------------------------------------------------------------
#   properties for scintilla-scite :
#   ----------------------------------------------------------------------------
#
#   ext_common.properties  -+
#       +                   |
#   language_1.properties   |-> = one global file ext.properties
#       +                   |
#   language_n.properties  -+
#
#   ----------------------------------------------------------------------------
#   properties for codeblocks :
#   ----------------------------------------------------------------------------
#   One file per language
#   ############################################################################
#   ############################################################################
#   INCLUDES
#   ############################################################################
source  /usr/local/bin/gwr.cb-build-helper.include.bash
#   ############################################################################
#   VARIABLES
#   ############################################################################
#   ############################################################################
#   FUNCTIONS
#   ############################################################################
#   ############################################################################
#   MAIN
#   ############################################################################
#   ============================================================================
cbh_func__log   "> building all shared libraries"
for language in ${SlePLs} ; do

    cbh_func__cd_and_build  "" "${SlePLDir}/${language}/liblexerext"
    cbh_func__check_errors  $?

done
#   ============================================================================
cbh_func__log   "> (scintilla-scite) building properties files"

for language in ${SlePLs} ; do

    cbh_func__try_cd_and_build  "" "${SlePLDir}/${language}/properties/scite"
    cbh_func__check_errors  $?

done
#   ============================================================================
cbh_func__log   "> (codeblocks) building properties files"

for language in ${SlePLs} ; do

    cbh_func__try_cd_and_build  "" "${SlePLDir}/${language}/properties/codeblocks"
    cbh_func__check_errors  $?

done


cbh_func__log_script_end
exit 0


