#!/bin/bash

#   ############################################################################
#   src/01-lexerext/build.bash
#
#   Build LexExt.cxx
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
cbh_func__log    "> Building LexerExt.cxx"

Snippets="00 01 02 03 04 05 06 07"

cbh_func__log    "..emptying LexExt.cxx"
echo -n ""  >   LexExt.cxx

cbh_func__log    "..adding files"
for SnippetId in ${Snippets} ; do

    SnippetPattern="LexExt-${SnippetId}.*.hhi"
    SnippetFilesUnsorted=$( find ./ -name "${SnippetPattern}" )
    SnippetFilesSorted=$( echo "${SnippetFilesUnsorted}" | sort )

    #echo "> Pattern :[${SnippetPattern}]"
    #echo "  Files   :${SnippetFilesUnsorted}"
    #echo "  Files   :${SnippetFilesSorted}"

    for f in ${SnippetFilesSorted} ; do

        if [[ -n "${f}" ]] ; then
            cbh_func__log "..Pattern [${SnippetPattern}] : File ${f}"
            cat "${f}"  2>/dev/null >>  LexExt.cxx
        else
            cbh_func__log "..Pattern [${SnippetPattern}] : !!!! ${f}"
        fi

    done

done

cbh_func__log_script_end
exit 0
