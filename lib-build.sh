#!/bin/sh

VERSION="0.91"
SDKVERSION="6.1"
LIB="freetds"

DEVELOPER=`xcode-select -print-path`
ARCHS="i386 armv7 armv7s"
CURRENTPATH=`pwd`
BUILD="x86_64-apple-darwin11"
OLD_PATH=$PATH
TDS_VER=7.1

cd ${LIB}-${VERSION}

for ARCH in ${ARCHS}
do
    if [ "${ARCH}" == "i386" ];
    then
        PLATFORM="iPhoneSimulator"
        HOST="i386-apple-darwin11"
    else
        PLATFORM="iPhoneOS"
        HOST="${ARCH}-apple-darwin11"
    fi

    SDK="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/SDKs/${PLATFORM}${SDKVERSION}.sdk"

    export CC="clang"
    export CFLAGS="-arch ${ARCH} -isysroot ${SDK}"
    export CXXFLAGS="$CFLAGS"
    export LDFLAGS="$CFLAGS"
    export LD=$CC
    

    PREFIX="${CURRENTPATH}/build/${LIB}/${ARCH}"

    mkdir -p ${PREFIX}

    echo "Please stand by..."

    ./configure --prefix=$PREFIX --host=${HOST} -build=${BUILD} -with-tdsver=${TDS_VER}
    make clean
    make && make install

    echo "======== CHECK ARCH ========"
    lipo -info ${PREFIX}/lib/libsybdb.a
    echo "======== CHECK DONE ========"

done

echo "== We just need static library == "
echo " == Copy headers to fat folder from i386 folder AND clean files in lib =="
cp -r ${CURRENTPATH}/build/${LIB}/i386/ ${CURRENTPATH}/build/${LIB}/Fat
rm -rf ${CURRENTPATH}/build/${LIB}/Fat/lib/*

echo "Build library - freetds.a"
lipo -create ${CURRENTPATH}/build/${LIB}/i386/lib/libsybdb.a  ${CURRENTPATH}/build/${LIB}/armv7/lib/libsybdb.a  ${CURRENTPATH}/build/${LIB}/armv7s/lib/libsybdb.a -output ${CURRENTPATH}/build/${LIB}/Fat/lib/libsybdb.a


echo "======== CHECK FAT ARCH ========"
lipo -info ${CURRENTPATH}/build/${LIB}/Fat/lib/libsybdb.a
echo "======== CHECK DONE ========"

echo "== Done =="
