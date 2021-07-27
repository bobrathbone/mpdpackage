#!/bin/bash
# $Id: build.sh,v 1.14 2021/05/31 20:00:07 bob Exp $
# Build script for packaging latest build of Music Player Daemon (MPD)
# Run this script as user pi and not root

PKG=mpd
PKGDEF=mpdpkg
VERSION=$(grep ^Version: ${PKGDEF} | awk '{print $2}')
ARCH=$(grep ^Architecture: ${PKGDEF} | awk '{print $2}')
DEBPKG=${PKG}_${VERSION}_${ARCH}.deb
OS_RELEASE=/etc/os-release
DIR=~/mpd-${VERSION}

# Amend this to point to the actual MPD build directory
BUILD_DIR=/home/pi/mpd-0.22.8

# Modify package definition with version number
SAVEIFS=${IFS}; IFS='-'
MPD_VERSION=$(echo ${BUILD_DIR} | awk '{print $2}' | sed 's/"//g')
IFS=${SAVEIFS}
echo "Building MPD version ${MPD_VERSION}"
sed -i "s/^Version:.*/Version: ${MPD_VERSION}/" ${PKGDEF} 

# Check we are not running as sudo
if [[ "$EUID" -eq 0 ]];then
        echo "Run this script as user pi and not sudo/root"
        exit 1
fi

# Tar build for Rasbian Buster (Release 10) or later
VERSION_ID=$(grep VERSION_ID ${OS_RELEASE})
SAVEIFS=${IFS}; IFS='='
ID=$(echo ${VERSION_ID} | awk '{print $2}' | sed 's/"//g')
if [[ ${ID} -lt 10 ]]; then
        VERSION=$(grep VERSION= ${OS_RELEASE})
        echo "Raspbian Buster (Release 10) or later is required to run this build"
        RELEASE=$(echo ${VERSION} | awk '{print $2 $3}' | sed 's/"//g')
        echo "This is Raspbian ${RELEASE}"
        exit 1
fi
IFS=${SAVEIFS}

if [[ -d ${BUILD_DIR}/output ]]; then
	# Link the build directory 
	echo "Linking output directory to MPD build directory ${BUILD_DIR}/output"
	cmd="rm -rf output"
	echo ${cmd}; ${cmd}
	cmd="ln -s ${BUILD_DIR}/output"
	echo ${cmd}; ${cmd}
else
	echo "ERROR: ${BUILD_DIR}/output not found"
	echo "Check that BUILD_DIR is correctly specified in this script"
	echo "Aborting"
	exit 1
fi

# Copy compiled MPD binary and configurations files from the build directory
RELEASE=output/release

# Copy compiled files 
pwd
echo
echo "Copying MPD files from ${BUILD_DIR}"
cmd="cp ${BUILD_DIR}/${RELEASE}/mpd ."
echo ${cmd}; ${cmd}
cmd="cp ${BUILD_DIR}/mpd.svg  ."
echo ${cmd}; ${cmd}
cmd="cp ${BUILD_DIR}/AUTHORS ."
echo ${cmd}; ${cmd}
cmd="cp ${BUILD_DIR}/COPYING ."
echo ${cmd}; ${cmd}
cmd="cp ${BUILD_DIR}/NEWS ."
echo ${cmd}; ${cmd}
cmd="cp ${BUILD_DIR}/README.md ."
echo ${cmd}; ${cmd}

# Correct mpd.service with by adding config file (/etc/mpd.conf)
EXEC="ExecStart=\/usr\/local\/bin\/mpd --no-daemon \/etc\/mpd.conf"
sed -i -e "0,/^ExecStart=/{s/ExecStart=.*/${EXEC}/}" mpd.service 

echo "Corrected mpd.service ExecStart statement"
grep "ExecStart=" mpd.service 

echo "Set permissions for mpd.conf"
cmd="sudo chown mpd:audio mpd.conf"
echo ${cmd}; ${cmd}

echo
echo "Building package ${PKG} version ${VERSION}"
echo "from input file ${PKGDEF}"

equivs-build ${PKGDEF}

echo -n "Check using Lintian y/n: "
read ans
if [[ ${ans} == 'y' ]]; then
	echo "Checking package ${DEBPKG} with lintian"
	lintian ${DEBPKG}
	if [[ $? = 0 ]]
	then
	    dpkg -c ${DEBPKG}
	    echo "Package ${DEBPKG} OK"
	else
	    echo "Package ${DEBPKG} has errors"
	fi
fi

# End of build script
