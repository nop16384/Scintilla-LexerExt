#!/bin/bash

#   ############################################################################
#   src/03-languages/gas-i386x64/properties/codeblocks/build.bash
#
#   Build property files for scintilla-scite & codeblocks
#   ############################################################################

#   ############################################################################
#   DOC
#   ############################################################################

#   gcc -c -Wall -Werror -fPIC shared.c
#   gcc -shared -o libshared.so shared.o

#   ############################################################################
#   INCLUDES
#   ############################################################################
source  /usr/local/bin/gwr.cb-build-helper.include.bash
#   ############################################################################
#   VARIABLES
#   ############################################################################
cmpropdir="${SleLEDir}/languages/properties"
cbpropdir="${SlePLDir}/gas-i386x64/properties/codeblocks"
#   ############################################################################
#   FUNCTIONS
#   ############################################################################
#   ############################################################################
#   MAIN
#   ############################################################################
#   ============================================================================
#   import parameters
#   ============================================================================
source  "../gas-i386x64-properties-colors-N.include.bash"

if [[ "${BUILD_DEBUG}" = "1" ]] ; then
    source  "../gas-i386x64-properties-colors-D.include.bash"
else
    source  "../gas-i386x64-properties-colors-R.include.bash"
fi
#   ========================================================================
#   assemble language properties file for codeblocks
#   ========================================================================
cbh_func__log   "> Building properties file for codeblocks"

cbh_func__cd            "> " "${cbpropdir}"
cbh_func__check_errors  $?
#   ------------------------------------------------------------------------
#   build part file "${language}-02-styles.xml"
#   ( other part files remain unchanged )
#   ------------------------------------------------------------------------
echo -n "" > "gas-i386x64-02-styles.xml"

#   <Style name="Default"                           index="0"       fg="0,0,0"      bg="255,255,255"        bold="0"        italics="0"     underlined="0"  />

i=0 ; while [[ $((i)) -le 31 ]] ; do

    cn="${extn[$((i))]}"    # color name
    ch="${extc[$((i))]}"    # color details + bold, italic, underlined

    if [[ -z "${cn}" ]] ; then
        i=$((i+1))
        continue
    fi

    #   ${string:position:length}
    fr=$((16#${ch:0:2})) ; fg=$((16#${ch:2:2})) ; fb=$((16#${ch:4:2}))
    br=$((16#${ch:7:2})) ; bg=$((16#${ch:9:2})) ; bb=$((16#${ch:11:2}))
    bo=${ch:14:1}
    it=${ch:16:1}
    un=${ch:18:1}

    l1="${line}<Style name=\"${cn}\""
    l2="index=\"$((i))\""
    l3="fg=\"${fr},${fg},${fb}\""
    l4="bg=\"${br},${bg},${bb}\""
    l5="bold=\"${bo}\""
    l6="italics=\"${it}\""
    l7="underlined=\"${un}\""
    echo -e "${l1}\t\t\t\t\t\t${l2}\t\t${l3}\t\t${l4}\t\t${l5}\t\t${l6}\t\t${l7}\t/>" >> "gas-i386x64-02-styles.xml"

    i=$((i+1))

done
#   ------------------------------------------------------------------------
#   language properties file
#   ------------------------------------------------------------------------
echo -n "" > "lexer_ext__gas_i386x64.xml"

parts=$( ls gas-i386x64-*.xml )
for f in ${parts} ; do
    cbh_func__log   "..adding [${f}]"
    cat             ${f} >> "lexer_ext__gas_i386x64.xml"
done

cbh_func__log   "(!) Remember to set the lexer index in xml file ( index=\"_?_index_?_\" )"

cbh_func__log_script_end
exit 0
