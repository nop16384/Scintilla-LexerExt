#!/bin/bash

#   ############################################################################
#   src/03-languages/gas-i386x64/properties/scite/build.bash
#
#   Build property files for scintilla-scite
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
sspropfile="ext__gas_i386x64.properties"
#   ############################################################################
#   FUNCTIONS
#   ############################################################################

#   ############################################################################
#   MAIN
#   ############################################################################
#   ========================================================================
#   assemble language properties file for scintilla-scite
#   ========================================================================
cbh_func__log   "> (scintilla-scite) building properties files"
#   ----------------------------------------------------------------------------
#   raz
#   ----------------------------------------------------------------------------
cbh_func__log   "..raz"

echo -n "" > "${sspropfile}"
#   ----------------------------------------------------------------------------
#   header
#   ----------------------------------------------------------------------------
cbh_func__log   "..adding header"

cat     "gas-i386x64-header.properties"  >>  "${sspropfile}"
#   ----------------------------------------------------------------------------
#   colors
#   style.ext.29=fore:#000000,back:#f05a14,bold,underlined
#   ----------------------------------------------------------------------------
cbh_func__log   "..adding colors"

source  "../gas-i386x64-properties-colors-N.include.bash"

if [[ "${BUILD_DEBUG}" = "1" ]] ; then
    source  "../gas-i386x64-properties-colors-D.include.bash"
else
    source  "../gas-i386x64-properties-colors-R.include.bash"
fi

i=0 ; while [[ $((i)) -le 31 ]] ; do

    cn="${extn[$((i))]}"    # color name
    ch="${extc[$((i))]}"    # color details + bold, italic, underlined

    if [[ -z "${cn}" ]] ; then
        i=$((i+1))
        continue
    fi

    #   ${string:position:length}
    fr=${ch:0:2} ; fg=${ch:2:2} ; fb=${ch:4:2}
    br=${ch:7:2} ; bg=${ch:9:2} ; bb=${ch:11:2}
    bo=${ch:14:1}
    it=${ch:16:1}
    un=${ch:18:1}

    l1="style.ext.${i}="
    l2="fore:#${fr}${fg}${fb},"
    l3="back:#${br}${bg}${bb}"
    l4="" ; if (( $bo == 1 )) ; then l4=",bold"        ; fi
    l5="" ; if (( $it == 1 )) ; then l5=",italic"      ; fi
    l6="" ; if (( $un == 1 )) ; then l6=",underlined"  ; fi

    echo -e "${l1}${l2}${l3}${l4}${l5}${l6}" >> "${sspropfile}"

    i=$((i+1))

done
#   ----------------------------------------------------------------------------
#   directives
#   ----------------------------------------------------------------------------
cbh_func__log   "..adding directives"

cat     "gas-i386x64-directives.properties" >> "${sspropfile}"
#   ----------------------------------------------------------------------------
#   keywords
#   ----------------------------------------------------------------------------
cbh_func__log   "..adding keywords, options, etc..."

cat     "gas-i386x64-keywords.properties" >> "${sspropfile}"
#   ----------------------------------------------------------------------------
#   keywords - patterns - options
#   ----------------------------------------------------------------------------
cbh_func__log   "..adding keywords, patterns options, etc..."

cat     "gas-i386x64-kpa.properties" >> "${sspropfile}"


cbh_func__log_script_end
exit 0

