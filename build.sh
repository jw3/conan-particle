#!/usr/bin/env bash

readonly sourcedir="${SOURCE_DIR:-${PWD}}"
readonly builddir="${BUILD_DIR:-${sourcedir}/build}"

readonly conanpath="${CONAN_PATH:-${sourcedir}}"
readonly conanuser="${CONAN_USER:-jw3}"
readonly conanchannel="${CONAN_CHANNEL:-stable}"

readonly cross_compiler_root=${CROSS_COMPILER_ROOT:-/usr/local/gcc-arm}
readonly compiler_major_version=$("${cross_compiler_root}/bin/arm-none-eabi-gcc" -dumpspecs | grep *version -A1 | tail -n1 | cut -d. -f1)

_echoerr() { if [[ ${QUIET} -ne 1 ]]; then echo "[debug]: $@" 1>&2; fi }
_checkerr() { ec=${1}; if [[ ${ec} -ne 0 ]]; then _echoerr "$2 failed with error code $ec"; exit ${ec}; fi }
_checkec() { ec=${?}; _checkerr ${ec} "$1"; }

build() {
  IFS=' ' read -r -a ext_cmake_args <<< "$CMAKE_ARGS"

  if [ ! -d ${builddir} ]; then mkdir -p "$builddir"; fi
  cd ${builddir}
  cmake ${ext_cmake_args[@]} ${sourcedir}
  _checkec "cmake"

  cd ${sourcedir}/packages

  # export the version generated by cmake
  export BUILD_DIR=${builddir}

  # export each conan package
  conan export-pkg common "$conanuser/$conanchannel" -s compiler.version="$compiler_major_version" -f
  conan export-pkg OneWire "$conanuser/$conanchannel" -s compiler.version="$compiler_major_version" -f
  conan export-pkg DS18B20 "$conanuser/$conanchannel" -s compiler.version="$compiler_major_version" -f
  conan export-pkg TinyGpsPlus "$conanuser/$conanchannel" -s compiler.version="$compiler_major_version" -f
  conan export-pkg LiquidCrystalI2C "$conanuser/$conanchannel" -s compiler.version="$compiler_major_version" -f
  conan export-pkg AssetTrackerRK "$conanuser/$conanchannel" -s compiler.version="$compiler_major_version" -f
  conan export-pkg LIS3DH "$conanuser/$conanchannel" -s compiler.version="$compiler_major_version" -f
  conan export-pkg NeoGPS "$conanuser/$conanchannel" -s compiler.version="$compiler_major_version" -f
}


publish() {
  if [ ! -d ${builddir} ]; then mkdir -p "$builddir"; fi
  cd ${builddir}
  cmake ${sourcedir}

  version="${CONAN_VERSION:-$(cat ${builddir}/VERSION)}"
  remote="${CONAN_REMOTE:-particle-bintray}"

  _echoerr "conan upload $conanuser/$conanchannel"
  conan upload "particle-common/$version@$conanuser/$conanchannel" -c -r "$remote" --all
  conan upload "OneWire/$version@$conanuser/$conanchannel" -c -r "$remote" --all
  conan upload "DS18B20/$version@$conanuser/$conanchannel" -c -r "$remote" --all
  conan upload "TinyGpsPlus/$version@$conanuser/$conanchannel" -c -r "$remote" --all
  conan upload "LiquidCrystalI2C/$version@$conanuser/$conanchannel" -c -r "$remote" --all
  conan upload "AssetTrackerRK/$version@$conanuser/$conanchannel" -c -r "$remote" --all
  conan upload "LIS3DH/$version@$conanuser/$conanchannel" -c -r "$remote" --all
  conan upload "NeoGPS/$version@$conanuser/$conanchannel" -c -r "$remote" --all
}


case "${1,,}" in
  ("publish") publish ;;
          (*) build "$@" ;;
esac
