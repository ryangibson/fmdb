#!/bin/sh

function usage {
    echo "`basename $0`"
    exit -1
}

if [ "$#" != "0" ]; then
    echo $#
    usage
fi


function build {
    _PLATFORM=$1
    _CONFIGURATION=$2
    echo "--> Build ${_PLATFORM} ${_CONFIGURATION}"
    OUTPUT_DIR=`./bin/build.sh ${_PLATFORM} ${_CONFIGURATION}`
    RETVAL=$?
    if [ "${RETVAL}" != "0" ]; then
        echo "ERROR: Building ${_PLATFORM} ${_CONFIGURATION} (${RETVAL})"
        echo ${OUTPUT_DIR}
        exit -1
    fi
}

function exitOnFailure {
    if [ "$?" != "0" ]; then
        echo "ERROR: ${1}"
        exit -1
    fi
}

SHARED_OUTPUT_DIR=output/shared
CONFIGURATIONS="Debug Release"

rm -fR "${SHARED_OUTPUT_DIR}"
exitOnFailure "Removing current output directory"
for CONFIGURATION in ${CONFIGURATIONS}; do
    CONF=`echo ${CONFIGURATION} | tr '[:upper:]' '[:lower:]'`
    build ios ${CONF}
    IOS_DIR=${OUTPUT_DIR}
    build iossim ${CONF}
    IOSSIM_DIR=${OUTPUT_DIR}
    build macos ${CONF}
    MACOS_DIR=${OUTPUT_DIR}

    mkdir -p "${SHARED_OUTPUT_DIR}"
    exitOnFailure "Making new output directory"

    echo "--> Copy headers"
    mkdir -p "${SHARED_OUTPUT_DIR}/inc"
    exitOnFailure "Making new output includes directory"
    cp -r "${MACOS_DIR}/usr/local/include/FMDB/" "${SHARED_OUTPUT_DIR}/inc/FMDB/"
    exitOnFailure "Making new output includes directory"

    echo "--> Create iOS fat binary"
    mkdir -p "${SHARED_OUTPUT_DIR}/lib/${CONFIGURATION}/iOS/"
    exitOnFailure "Making new output iOS ${CONFIGURATION} directory"
    DEVICE="${IOS_DIR}/usr/local/lib/libFMDB.a"
    SIM="${IOSSIM_DIR}/usr/local/lib/libFMDB.a"
    lipo -create "${DEVICE}" "${SIM}" -output "${SHARED_OUTPUT_DIR}/lib/${CONFIGURATION}/iOS/libFMDB.a"
    exitOnFailure "Making iOS ${CONFIGURATION} fat binary"
    echo "--> Copy macOS binary"
    mkdir -p "${SHARED_OUTPUT_DIR}/lib/${CONFIGURATION}/macOS/"
    exitOnFailure "Making new output macOS ${CONFIGURATION} directory"
    cp -r "${MACOS_DIR}/usr/local/lib/libFMDB.a" "${SHARED_OUTPUT_DIR}/lib/${CONFIGURATION}/macOS/libFMDB.a"
    exitOnFailure "Copying macOS ${CONFIGURATION} library"
done

DATE=`date +%Y-%m-%d_%H-%M-%S`
tar cvf fmdb-libraries-${DATE}.tbz --bzip2 -C output shared
exitOnFailure "Making archive"
echo "==> Done fmdb-libraries-${DATE}.tbz"



