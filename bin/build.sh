#!/bin/sh

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
        SDK=iphoneos12.1
        SCHEME=FMDB-IOS
        ;;
    iossim)
        SDK=iphonesimulator12.1
        SCHEME=FMDB-IOS
        ;;
    macos)
        SDK=macosx10.14
        SCHEME=FMDB
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

PROJECT=fmdb.xcodeproj


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
