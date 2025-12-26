inherit dpkg-raw
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += " file://sw-versions"
SRC_URI:append:swupdate = " file://swupdate.cfg"


do_install:append() {
    install -d ${D}/etc/
    install -m 0644 ${WORKDIR}/sw-versions ${D}/etc/
    sed -i -e "s@SWU_VERSION@${SWU_VERSION}@g" ${D}/etc/sw-versions
}
