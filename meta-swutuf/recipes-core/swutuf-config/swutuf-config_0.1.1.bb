inherit dpkg-raw

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += " \
    file://root.json \
    file://swutuf.json.tmpl \
"

TEMPLATE_FILES += "swutuf.json.tmpl"
TEMPLATE_VARS += "METADATA_URL ARTIFACTS_URL"

do_install() {
    install -d ${D}/root/metadata
    install -m 0644 ${WORKDIR}/root.json \
        ${D}/root/metadata/root.json
  
    install -d ${D}/etc/
    install -m 0644 ${WORKDIR}/swutuf.json ${D}/etc/
}
