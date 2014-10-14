#!/bin/sh

VERSION="0.91"
SDKVERSION="8.0"
TARGETSDKVERSION="7.1"
LIB="freetds"

DEVELOPER=`xcode-select -print-path`
ARCHS="i386 armv7 armv7s arm64 x86_64"
CURRENTPATH=`pwd`
BUILD="x86_64-apple-darwin11"
HOST="arm-apple-darwin"
OLD_PATH=$PATH
TDS_VER=7.1

cd ${LIB}-${VERSION}

for ARCH in ${ARCHS}
do
    if [ "${ARCH}" == "i386" ];
    then
        PLATFORM="iPhoneSimulator"
    else
        PLATFORM="iPhoneOS"
    fi

    SDK="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/SDKs/${PLATFORM}${SDKVERSION}.sdk"
    CFLAGS="-arch ${ARCH} -miphoneos-version-min=${TARGETSDKVERSION} -isysroot ${SDK}"
    PREFIX="${CURRENTPATH}/build/${LIB}/${ARCH}"

    mkdir -p ${PREFIX}

    echo "Please stand by..."

    if [ "${ARCH}" == "x86_64" ];
    then
        ./configure --prefix=$PREFIX -build=${BUILD} -with-tdsver=${TDS_VER}
    else
        ./configure --prefix=$PREFIX --host=${HOST} -build=${BUILD} -with-tdsver=${TDS_VER} CFLAGS="${CFLAGS}"
    fi

    make clean
    make && make install

    echo "======== CHECK ARCH ========"
    xcrun -sdk iphoneos lipo -info ${PREFIX}/lib/libsybdb.a
    echo "======== CHECK DONE ========"

done

echo "== We just need static library == "
echo " == Copy headers to fat folder from i386 folder AND clean files in lib =="
cp -r ${CURRENTPATH}/build/${LIB}/i386/ ${CURRENTPATH}/build/${LIB}/Fat
rm -rf ${CURRENTPATH}/build/${LIB}/Fat/lib/*

echo "Build library - freetds.a"
lipo -create ${CURRENTPATH}/build/${LIB}/i386/lib/libsybdb.a  ${CURRENTPATH}/build/${LIB}/armv7/lib/libsybdb.a  ${CURRENTPATH}/build/${LIB}/armv7s/lib/libsybdb.a  ${CURRENTPATH}/build/${LIB}/arm64/lib/libsybdb.a  ${CURRENTPATH}/build/${LIB}/x86_64/lib/libsybdb.a  -output ${CURRENTPATH}/build/${LIB}/Fat/lib/libsybdb.a


echo "======== CHECK FAT ARCH ========"
xcrun -sdk iphoneos lipo -info ${CURRENTPATH}/build/${LIB}/Fat/lib/libsybdb.a
echo "======== CHECK DONE ========"

echo "== Done =="
