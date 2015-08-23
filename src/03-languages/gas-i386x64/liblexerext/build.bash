#!/bin/bash

#   ############################################################################
#   src/03-languages/gas-i386x64/liblexerext/build.bash
#
#   Build shared library for lexing gas-i386x64 files
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
flexsrcdir="${SlePLDir}/gas-i386x64/liblexerext/flex"
libsrcdir="${SlePLDir}/gas-i386x64/liblexerext"

libname="lib-scintilla-lexer-ext__gas_i386x64.so"
libobjdir="${SlePLDir}/gas-i386x64/liblexerext/obj"
libdstdir="${SlePLDir}/gas-i386x64/liblexerext/lib"
#   ############################################################################
#   FUNCTIONS
#   ############################################################################
#   ############################################################################
#   MAIN
#   ############################################################################
#   ============================================================================
#   assemble flex file
#   ============================================================================
cbh_func__log   "> building flex file for [gas-i386x64]"

#   go in flex directory
cbh_func__cd            "" "${flexsrcdir}"
cbh_func__check_errors  $?

# assemble file
echo -n "" > "gas-i386x64.flex"

parts=$( ls gas-i386x64-*.flex )
for f in ${parts} ; do
    cbh_func__log   "..adding [${f}]"
    cat             ${f} >> "gas-i386x64.flex"
done
#   ============================================================================
#   compile flex file
#   ============================================================================
#   go in library src directory
cbh_func__log           "> compiling flex file [gas-i386x64.flex]"
cbh_func__cd            "" "${libsrcdir}"
cbh_func__check_errors  $?

#   compiling flex file ...
flex -o "liblexerext-flex.cc" "flex/gas-i386x64.flex"

#   eliminating wsign compare flex pb
cbh_func__log   "> getting rid of 'wsign compare' flex bug"
cat             "liblexerext-flex.cc" | sed -e 's/                int yyl;\\/             size_t yyl;\\/' > "liblexerext-flex.cc.temp"
mv -f           "liblexerext-flex.cc.temp" "liblexerext-flex.cc"
#   ============================================================================
#   build shared library
#   ============================================================================
#   removing old objects
cbh_func__log   "> building [${libname}]"

rm -f   "${libobjdir}/*.o"
rm -f   "${libdstdir}/${libname}"

g++ --std=c++0x -g -ggdb -fPIC -Wall -pedantic -c liblexerext.cc                -o "${libobjdir}/liblexerext.o"
g++ --std=c++0x -g -ggdb -fPIC -Wall -pedantic -c liblexerext-lexer.cc          -o "${libobjdir}/liblexerext-lexer.o"
g++ --std=c++0x -g -ggdb -fPIC -Wall -pedantic -c liblexerext-flex.cc           -o "${libobjdir}/liblexerext-flex.o"
g++ --std=c++0x -g -ggdb -fPIC -Wall -pedantic -c liblexerext-dico-tree.cc      -o "${libobjdir}/liblexerext-dico-tree.o"

g++ -shared -Wl,--export-dynamic -o "${libdstdir}/${libname}" "${libobjdir}/liblexerext-lexer.o"  "${libobjdir}/liblexerext-flex.o" "${libobjdir}/liblexerext.o" "${libobjdir}/liblexerext-dico-tree.o"

cbh_func__copy_file     "> installing library..." "${libdstdir}/${libname}"    "/usr/lib/codeblocks/lexers"
cbh_func__check_errors  $?

cbh_func__log_script_end
exit 0
