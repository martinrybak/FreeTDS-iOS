#!/bin/sh

VERSION="1.00.15"
SDKVERSION="9.3"
TARGETSDKVERSION="9.0"
LIB="freetds"

DEVELOPER=`xcode-select -print-path`
ARCHS="i386 x86_64 armv7 armv7s arm64"
CURRENTPATH=`pwd`
BUILD="x86_64-apple-darwin11"
OLD_PATH=$PATH
TDS_VER=7.4

cd ${LIB}-${VERSION}

for ARCH in ${ARCHS}
do
    case "${ARCH}" in
        "i386"|"x86_64")
            PLATFORM="iPhoneSimulator"
            HOST="${ARCH}-apple-darwin11"
            ;;
        "arm64")
            PLATFORM="iPhoneOS"
            HOST="aarch64-apple-darwin11"
            ;;
        *)
            PLATFORM="iPhoneOS"
            HOST="${ARCH}-apple-darwin11"
            ;;
    esac

    SDK="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/SDKs/${PLATFORM}${SDKVERSION}.sdk"
    export CC="clang"
    export CFLAGS="-arch ${ARCH} -isysroot ${SDK} -miphoneos-version-min=6.0"
    export CXXFLAGS="$CFLAGS"
    export LDFLAGS="$CFLAGS"
    export LD=$CC
    # export CFLAGS="-arch ${ARCH} -miphoneos-version-min=${TARGETSDKVERSION} -isysroot ${SDK}"
    
    PREFIX="${CURRENTPATH}/build/${LIB}/${ARCH}"

    mkdir -p ${PREFIX}

    echo "Please stand by..."

    ./configure --prefix=$PREFIX --host=${HOST} -build=${BUILD} -with-tdsver=${TDS_VER} CFLAGS="${CFLAGS}"

    make clean
    make && make install

    echo "======== CHECK ARCH ========"
    xcrun -sdk iphoneos lipo -info ${PREFIX}/lib/libsybdb.a
    echo "======== CHECK DONE ========"

done

echo "== We just need static library == "
echo "== Copy headers to fat folder from i386 folder AND clean files in lib =="
cp -r ${CURRENTPATH}/build/${LIB}/i386/ ${CURRENTPATH}/build/${LIB}/Fat
rm -rf ${CURRENTPATH}/build/${LIB}/Fat/lib/*

echo "Build library - libsybdb.a"
lipo -create ${CURRENTPATH}/build/${LIB}/i386/lib/libsybdb.a  ${CURRENTPATH}/build/${LIB}/armv7/lib/libsybdb.a  ${CURRENTPATH}/build/${LIB}/armv7s/lib/libsybdb.a  ${CURRENTPATH}/build/${LIB}/arm64/lib/libsybdb.a  ${CURRENTPATH}/build/${LIB}/x86_64/lib/libsybdb.a  -output ${CURRENTPATH}/build/${LIB}/Fat/lib/libsybdb.a

echo "======== CHECK FAT ARCH ========"
xcrun -sdk iphoneos lipo -info ${CURRENTPATH}/build/${LIB}/Fat/lib/libsybdb.a
echo "======== CHECK DONE ========"

echo "== Done =="
