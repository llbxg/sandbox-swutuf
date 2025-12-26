SUMMARY = "swutuf"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=7871c5cf47c0e3dbd1e194260e1c07b9"

inherit dpkg

SRC_URI = "git://gitlab.com/cip-playground/swutuf.git;branch=main;protocol=https;destsuffix=git"
SRC_URI += " \
    file://debian;subdir=git \
"

SRCREV = "33e12882ee4237701a2650a95d459a825d67d22b"
S = "${WORKDIR}/git"

do_prepare_build() {
    if [ ! -s debian/changelog ]; then
        deb_add_changelog
    fi
}

FILES:${PN} += "${bindir}/swutuf"
