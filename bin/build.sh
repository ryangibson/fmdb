#!/bin/sh

PROJECT=fmdb.xcodeproj

MAC_SCHEME=FMDB
MAC_SDK=macosx10.14

IOS_SCHEME=FMDB-IOS
IOS_SDK=iphoneos12.1
IOSSIM_SDK=iphonesimulator12.1

function usage {
    echo "`basename $0` ios|iossim|macos debug|release"
    echo "$#"
    exit -1
}

if [ "$#" != "2" ]; then
    usage
fi

case $1 in
    ios)
        SDK=${IOS_SDK}
        SCHEME=${IOS_SCHEME}
        ;;
    iossim)
        SDK=${IOSSIM_SDK}
        SCHEME=${IOS_SCHEME}
        ;;
    macos)
        SDK=${MAC_SDK}
        SCHEME=${MAC_SCHEME}
        ;;
    *)
        usage
        ;;
esac

case $2 in
    debug)
        CONFIGURATION=Debug
        ;;
    *)
        CONFIGURATION=Release
        ;;
esac

CWD=`pwd`
OUTPUT_DIR=${CWD}/output
DERIVED_DATA_DIR=${OUTPUT_DIR}/derivedData-${SCHEME}-${CONFIGURATION}-${SDK}

BUILD_DIR=${OUTPUT_DIR}/build-${SCHEME}-${CONFIGURATION}-${SDK}
LOG=${OUTPUT_DIR}/output-${SCHEME}-${CONFIGURATION}-${SDK}.log

mkdir -p "${OUTPUT_DIR}"

echo "PROJECT:       ${PROJECT}" >> "${LOG}"
echo "SCHEME:        ${SCHEME}" >> "${LOG}"
echo "SDK:           ${SDK}" >> "${LOG}"
echo "CONFIGURATION: ${CONFIGURATION}" >> "${LOG}"

xcodebuild \
    -project ${PROJECT} \
    -scheme ${SCHEME} \
    -configuration ${CONFIGURATION} \
    -sdk ${SDK} \
    -derivedDataPath "${DERIVED_DATA_DIR}" \
    DSTROOT="${BUILD_DIR}" \
    ONLY_ACTIVE_ARCH=NO \
    SKIP_INSTALL=NO \
    clean build install \
    2>&1 >> "${LOG}"
RESULT=$?

echo ${BUILD_DIR}
exit ${RESULT}
