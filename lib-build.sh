#!/bin/sh

VERSION="1.00.15"
IOS_SDKVERSION="10.1"
OSX_SDKVERSION="10.12"
LIB="freetds"

DEVELOPER=`xcode-select -print-path`
IOS_ARCHS="i386 armv7 armv7s arm64"
OSX_ARCHS="i386 x86_64"
CURRENTPATH=`pwd`
BUILD="x86_64-apple-darwin11"
OLD_PATH=$PATH
TDS_VER=7.4


cd ${LIB}-${VERSION}

for ARCH in ${IOS_ARCHS}
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

    SDK="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/SDKs/${PLATFORM}${IOS_SDKVERSION}.sdk"
    export CC="clang"
    export CFLAGS="-arch ${ARCH} -isysroot ${SDK} -miphoneos-version-min=7.0"
    export CXXFLAGS="$CFLAGS"
    export LDFLAGS="$CFLAGS"
    export LD=$CC
    
    PREFIX="${CURRENTPATH}/build_ios/${LIB}/${ARCH}"

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
cp -r ${CURRENTPATH}/build_ios/${LIB}/i386/ ${CURRENTPATH}/build_ios/${LIB}/Fat
rm -rf ${CURRENTPATH}/build_ios/${LIB}/Fat/lib/*

echo "Build library - libsybdb.a"
lipo -create ${CURRENTPATH}/build_ios/${LIB}/i386/lib/libsybdb.a  ${CURRENTPATH}/build_ios/${LIB}/armv7/lib/libsybdb.a  ${CURRENTPATH}/build_ios/${LIB}/armv7s/lib/libsybdb.a  ${CURRENTPATH}/build_ios/${LIB}/arm64/lib/libsybdb.a  -output ${CURRENTPATH}/build_ios/${LIB}/Fat/lib/libsybdb.a

echo "======== CHECK FAT ARCH ========"
xcrun -sdk iphoneos lipo -info ${CURRENTPATH}/build_ios/${LIB}/Fat/lib/libsybdb.a
echo "======== CHECK DONE ========"

echo "== Done =="


echo "======== BUILDING FOR OSX ========"

for ARCH in ${OSX_ARCHS}
do
    PLATFORM="MacOSX"
    HOST="${ARCH}-apple-darwin11"

    SDK="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer/SDKs/${PLATFORM}${OSX_SDKVERSION}.sdk"
    export CC="clang"
    export CFLAGS="-arch ${ARCH} -isysroot ${SDK}"
    export CXXFLAGS="$CFLAGS"
    export LDFLAGS="$CFLAGS"
    export LD=$CC
    
    PREFIX="${CURRENTPATH}/build_osx/${LIB}/${ARCH}"

    mkdir -p ${PREFIX}

    echo "Please stand by..."

    ./configure --prefix=$PREFIX --host=${HOST} -build=${BUILD} -with-tdsver=${TDS_VER} CFLAGS="${CFLAGS}"

    make clean
    make && make install
done

echo "== We just need static library == "
echo "== Copy headers to fat folder from i386 folder AND clean files in lib =="
cp -r ${CURRENTPATH}/build_osx/${LIB}/i386/ ${CURRENTPATH}/build_osx/${LIB}/Fat
rm -rf ${CURRENTPATH}/build_osx/${LIB}/Fat/lib/*

echo "Build library - libsybdb.a"
lipo -create ${CURRENTPATH}/build_osx/${LIB}/i386/lib/libsybdb.a ${CURRENTPATH}/build_osx/${LIB}/x86_64/lib/libsybdb.a  -output ${CURRENTPATH}/build_osx/${LIB}/Fat/lib/libsybdb.a

echo "======== CHECK FAT ARCH ========"
xcrun -sdk macosx lipo -info ${CURRENTPATH}/build_osx/${LIB}/Fat/lib/libsybdb.a
echo "======== CHECK DONE ========"

echo "== Done =="
