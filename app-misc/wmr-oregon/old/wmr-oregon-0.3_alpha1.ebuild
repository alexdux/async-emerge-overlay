# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

DESCRIPTION="Oregon Scientific WMRxxx, RMSxxx and Ixxx USB stations reader and logger."
HOMEPAGE="http://code.google.com/p/wmr/"
KEYWORDS="~amd64 ~x86" # others archs nor restricted neither tested, feel free to test and submit/feedback them
LICENSE="LGPL-2"
SLOT="0"
SRC_URI="http://wmr.googlecode.com/files/wmr-oregon-2012-12-26.tar.gz"

IUSE="doc logrotate rrdtool"

# A space delimited list of portage features to restrict. man 5 ebuild for details.  Usually not needed.
RESTRICT="mirror"

RDEPEND="	rrdtool? ( net-analyzer/rrdtool )"
DEPEND="	logrotate? ( app-admin/logrotate )
			dev-db/sqlite:3
			dev-libs/libhid
			virtual/libusb:0"
			
src_unpack() {
	default_src_unpack
	mv Oregon_Scientific_WMR ${P}
	sed -i -e 's:<libhid/hid.h>:<hid.h>:' ${S}/*.{c,h}
}

src_compile() {
		emake all
}

src_install() {
	# sbin
	dosbin ${S}/wmr-oregon ${S}/script/wmr_alarm_advanced/wmr_alarm.sh
	# conf
	insinto /etc/wmr
	doins ${S}/contrib/wmr.conf || die
	# daemon
	doinitd ${FILESDIR}/wmrd
	# udev rules
	if has_version "sys-fs/udev" || has_version "virtual/udev"; then
		dodir /lib/udev/rules.d/
		cp ${S}/udev/10-wmr.rules ${D}/lib/udev/rules.d/
	fi
	# scripts
	keepdir /etc/wmr/scripts
	cp -R ${S}/script/wmr_alarm_advanced/etc/wmr/script/* ${D}/etc/wmr/scripts || die
	dodir /etc/wmr/sqlite
	cp ${S}/script/wmr_create_db_sqlite3.sh ${D}/etc/wmr/sqlite || die
	# logrotate
	if use logrotate ; then
		dodir /etc/logrotate.d/
		cp ${FILESDIR}/wmr-oregon ${D}/etc/logrotate.d/ || die
		#keepdir /var/log/async.emerge/archive
	fi
	# docs
	if use doc ; then 
		dodoc ${S}/doc/* 
		newdoc ${S}/README.ru.txt README.rus.txt
		newdoc ${S}/README.eng.txt README.eng.txt
		dodoc -r ${S}/script/controlling ${S}/script/samples ${S}/script/update_weather 
		newdoc ${S}/script/wmr_alarm_advanced/README wmr_alarm_advanced.README
	fi
}

pkg_postinst() {
    elog "Now it is needed to create the database..."
    elog "Run '/etc/wmr/sqlite/create_db_sqlite3.sh'."
}

