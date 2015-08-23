#!/bin/bash

################################################################################
#                                                                              #
#       THIS SCRIPT _MUST_ BE RUN FROM THE DIRECTORY IT RESIDES IN             #
#                                                                              #
################################################################################

#   ############################################################################
#   build.bash
#
#   Main build script
#
#   Options :
#   -l  : build LexExt.cxx
#   -p  : build Programming languages properties files & shared libraries
#   ############################################################################

#   ############################################################################
#   NOTES
#   ############################################################################
#   Check an error : call cbh_func__check_errors $?


#   ############################################################################
#   INCLUDES
#   ############################################################################
source  /usr/local/bin/gwr.cb-build-helper.include.bash
#   ############################################################################
#   VARIABLES
#   ############################################################################
BuildLE="no"                                                                    # build lexerext ?
BuildPL="no"                                                                    # build languages ?

GError=""
GSpaces="    "
GSpacesStep="    "
#   ############################################################################
#   FUNCTIONS
#   ############################################################################

#   ############################################################################
#   MAIN
#   ############################################################################
reset

cbh_func__log   "############################################################################"
cbh_func__log   "script : [build.bash]"
cbh_func__log   "############################################################################"

#   verify we are run from the directory we reside in
cbh_func__log   "> verifying pwd ..."
cd  $( pwd )
if [[ ! -f "root-directory.txt" ]] ; then
    cbh_func__log   "  some files were not found. Ensure running this script from the directory it resides in."
    exit 1
fi

#   get programs versions, programmation languages list
SlePLs=$( cat "languages.txt" )
SlePLCard=0 ; for l in ${SlePLs} ; do
    SlePLCard=$(( SlePLCard + 1 ))
done

#   build directories names
SleRootDir=$( pwd )
SleLEDir="${SleRootDir}/src/01-lexerext"
SleLLDir="${SleRootDir}/src/02-liblexerext"
SlePLDir="${SleRootDir}/src/03-languages"

#   some options
SleColType="D"                                                                  #   R=release, D=debug

#   export some vars for sub-scripts
export GError
export GSpaces
export GSpacesStep

export SleRootDir;
export SleLEDir;
export SleLLDir;
export SlePLDir
export SlePLs;
export SlePLCard;
export SleColType;

cbh_func__log   "> directory for SLE root            :[${SleRootDir}]"
cbh_func__log   "> directory for SLE lexerext        :[${SleLEDir}]"
cbh_func__log   "> directory for SLE liblexerext     :[${SleLLDir}]"
cbh_func__log   "> directory for SLE languages       :[${SlePLDir}]"

#   get options
while getopts ":lp" opt; do
    case ${opt} in
        l)
        BuildLE="yes"
        ;;
        p)
        BuildPL="yes"
        ;;
        \?)
        cbh_func__log   "> Invalid option: -${OPTARG}"
        ;;
    esac
done

#   build lexerext target
if [[ "${BuildLE}" == "yes" ]] ; then
    cbh_func__cd_and_build "" "${SleLEDir}"
    cbh_func__check_errors $?
fi

#   build languages target
if [[ "${BuildPL}" == "yes" ]] ; then
    cbh_func__cd_and_build "" "${SlePLDir}"
    cbh_func__check_errors $?
fi

exit 0
