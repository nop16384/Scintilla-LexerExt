#   ############################################################################
#   build-includes.bash
#   ############################################################################
#   ----------------------------------------------------------------------------
#   sle_func__spc_inc, dec
#
#   Add, Dec spaces to GSpaces
#   ----------------------------------------------------------------------------
function    sle_func__spc_inc
{
    #echo "${GSpaces}(inc1)"
    GSpaces="${GSpaces}${GSpacesStep}"
    #echo "${GSpaces}(inc2)"
}
function    sle_func__spc_dec
{
    #echo "${GSpaces}(dec1)"
    GSpaces="${GSpaces#${GSpacesStep}}"
    #echo "${GSpaces}(dec2)"
}
#   ----------------------------------------------------------------------------
#   sle_func__log
#
#   $1  text
#   ----------------------------------------------------------------------------
function    sle_func__log
{
    echo    "${GSpaces}$1"
}
#   ----------------------------------------------------------------------------
#   sle_func__log_script_start
#   ----------------------------------------------------------------------------
function    sle_func__log_script_start
{
    local   an rn
    #   ........................................................................
    an="$(pwd)"
    rn=${an//${SleRootDir}/}
    rn=${rn/"/"/}

    sle_func__log   "############################################################################"
    sle_func__log   "script : [${rn}/build.bash]"
    sle_func__log   "############################################################################"
}
#   ----------------------------------------------------------------------------
#   sle_func__log_script_end
#   ----------------------------------------------------------------------------
function    sle_func__log_script_end
{
    sle_func__log   "( end of script )"
}
#   ----------------------------------------------------------------------------
#   sle_func__check_errors
#
#   Check for errors
#
#   $1  $?
#   ----------------------------------------------------------------------------
function    sle_func__check_errors
{
    if [[ $(($1)) -ne 0  ]] ; then
        echo "*** ERROR ***"
        sle_func__spc_dec
        exit 1
    fi
}
#   ############################################################################
#   ----------------------------------------------------------------------------
#   sle_func__extract_tgz
#
#   Extract a tar-ed & gzip-ed file
#
#   $1  string to prepend to output
#   $2  Archive name
#   ----------------------------------------------------------------------------
function    sle_func__extract_tgz
{
    echo    "${GSpaces}$1"
    cat     "$2" | gunzip | tar -x
    return $?
}
#   ############################################################################
#   ----------------------------------------------------------------------------
#   sle_func__cd
#
#   Change current directory
#
#   $1  string to prepend to output
#   $2  Directory to cd in.
#   ----------------------------------------------------------------------------
function    sle_func__cd
{
    echo    "${GSpaces}$1( cd [$2] )"
    cd      "$2"
    return $?
}
#   ----------------------------------------------------------------------------
#   sle_func__cd_and_build
#
#   Change current directory and run the build.bash script
#
#   $1  string to prepend to output
#   $2  Directory to cd in
#   ----------------------------------------------------------------------------
function    sle_func__cd_and_build
{
    echo        "${GSpaces}$1( Launching build script in [$2])"

    sle_func__cd            "$1" "$2"
    sle_func__check_errors  $?

    sle_func__spc_inc

    sle_func__log_script_start
    chmod u=rwx ./build.bash
    ./build.bash
    sle_func__check_errors  $?

    sle_func__spc_dec
}
#   ----------------------------------------------------------------------------
#   sle_func__try_cd_and_build
#
#   Change current directory and run the build.bash script. If buid.bash is not
#   present, just exit, no errors
#
#   $1  string to prepend to output
#   $2  Directory to cd in
#   ----------------------------------------------------------------------------
function    sle_func__try_cd_and_build
{
    echo        "${GSpaces}$1( Trying to launch build script in [$2])"

    if [[ ! -e "$2/build.bash" ]] ; then
        return
    fi

    sle_func__cd            "$1" "$2"
    sle_func__check_errors  $?

    sle_func__spc_inc

    sle_func__log_script_start
    chmod u=rwx ./build.bash
    ./build.bash
    sle_func__check_errors  $?

    sle_func__spc_dec
}
#   ############################################################################
#   ----------------------------------------------------------------------------
#   sle_func__copy_file
#
#   Copy a file.
#
#   $1  string to prepend to output
#   $2  src file
#   $3  dst file
#   ----------------------------------------------------------------------------
function    sle_func__copy_file
{
    echo    "${GSpaces}$1( cp [$2] -> [$3] )"
    cp -f   "$2" "$3"
}
#   ----------------------------------------------------------------------------
#   sle_func__copy_file_if_different
#
#   Copy a file if
#     - the target does not exist
#     or
#     - the target exist and is different from the source
#
#   $1  string to prepend to output
#   $2  src file
#   $3  dst file
#   ----------------------------------------------------------------------------
function    sle_func__copy_file_if_different
{
    echo    "${GSpaces}$1( cp [$2] -> [$3] )"

    if [[ -e "$3" ]] ; then

        diff "$2" "$3" >/dev/null 2>&1

        if [[ $? -eq 0 ]] ; then
            return;
        fi

    fi

    cp -f   "$2" "$3"
}
#   ----------------------------------------------------------------------------
#   sle_func__bulk_copy_files
#
#   Copy many files. Some vars have to be defined :
#     - MFilesCard, MFile[i], MRPath[i]
#     - NFilesCard, NFile[i], NRPath[i]
#
#   $1  string to prepend to output
#   $2  src base directory. Following sub-directories must exist :
#     - files-modified
#     - files-new
#   $3  dst base directory.
#   ----------------------------------------------------------------------------
function    sle_func__bulk_copy_files
{
    local   i
    local   srcbasedir dstbasedir
    #   ------------------------------------------------------------------------
    srcbasedir="$2"
    dstbasedir="$3"
    #   ------------------------------------------------------------------------
    #   modified files
    i=0 ; while [[ $((i)) -lt $((MFilesCard)) ]] ; do

        fn="${MFiles[$((i))]}"                                                  #   filename
        rp="${MRPaths[$((i))]}"                                                 #   relative dst path

        fs="${srcbasedir}/files-modified/${fn}"                                 #   abolute src filename
        fd="${dstbasedir}/${rp}/${fn}"                                          #   abolute dst filename

        sle_func__copy_file_if_different    "$1" "${fs}" "${fd}"
        sle_func__check_errors              $?

        i=$((i+1))

    done
    #   ------------------------------------------------------------------------
    #   new files
    i=0 ; while [[ $((i)) -lt $((NFilesCard)) ]] ; do

        fn="${NFiles[$((i))]}"
        rp="${NRPaths[$((i))]}"

        fs="${srcbasedir}/files-new/${fn}"
        fd="${dstbasedir}/${rp}/${fn}"

        sle_func__copy_file     "$1" "${fs}" "${fd}"
        sle_func__check_errors  $?

        i=$((i+1))

    done
}
#   ----------------------------------------------------------------------------
#   sle_func__replace_file_and_backup
#
#   Replace a file by another and make a backup.
#
#   $1  string to prepend to output
#   $2  src file
#   $3  dst file
#   ----------------------------------------------------------------------------
function    sle_func__replace_file_and_backup
{
    local   bf
    #   ........................................................................
    echo    "${GSpaces}$1( cp [$2] -> [$3] )"

    bf="$3.bak"

    if [[ -f "${bf}" ]] ; then
        echo "${GSpaces} - [${bf}] already exists, dont backuping file"
    else
        echo "${GSpaces} - creating backup file [${bf}]"
        cp  "$3" "${bf}"
    fi

    cp -f "$2" "$3"
}
