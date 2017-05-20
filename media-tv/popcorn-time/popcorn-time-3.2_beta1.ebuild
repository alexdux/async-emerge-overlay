# async-emerge 2017 alexdu

EAPI="5"

inherit eutils
DESCRIPTION="Watch torrent movies instantly"
HOMEPAGE="https://www.popcorn-time.to/"
SRC_URI="https://dl.popcorn-time.to/Popcorn-Time-linux64.tar.gz"

SLOT="0"
KEYWORDS="amd64"
IUSE="apulse pulseaudio"
REQUIRED_USE="apulse? ( !pulseaudio )"
RESTRICT="strip"
S="${WORKDIR}"

RDEPEND="
    sys-libs/libudev-compat
    apulse? ( media-sound/apulse[abi_x86_32(-)] )
    pulseaudio? ( media-sound/pulseaudio[abi_x86_32(-)] )"

src_unpack() {
	default_src_unpack
#	unpack ./data.tar.xz
#	epatch "${FILESDIR}/viber-9999-desktop.patch"
#	if use apulse; then
#	    epatch "${FILESDIR}/viber-9999-desktop-apulse.patch"
#	fi
}

src_install(){
	dodir /opt/popcorn-time/
	cp -R ${S}/* "${D}/opt/popcorn-time/"
#	doins -r opt usr
#	fperms 111 /opt/popcorn-time/*
	fperms 755 /opt/popcorn-time/Popcorn-Time
}
