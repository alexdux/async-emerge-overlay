# Copyright open-overlay 2015 by Alex
# async-emerge 2016 alexdu

EAPI="5"

inherit eutils
DESCRIPTION="Free calls, text and picture sharing with anyone, anywhere!"
HOMEPAGE="http://www.viber.com"
SRC_URI="http://download.cdn.viber.com/cdn/desktop/Linux/viber.deb"

SLOT="0"
KEYWORDS="amd64"
IUSE="apulse pulseaudio"
REQUIRED_USE="apulse? ( !pulseaudio )"
RESTRICT="strip"
S="${WORKDIR}"

RDEPEND="
    apulse? ( media-sound/apulse[abi_x86_32(-)] )
    pulseaudio? ( media-sound/pulseaudio[abi_x86_32(-)] )"

src_unpack() {
	default_src_unpack
	unpack ./data.tar.xz
#	epatch "${FILESDIR}/viber-9999-desktop.patch"
	if use apulse; then
	    epatch "${FILESDIR}/viber-9999-desktop-apulse.patch"
	fi
}

src_install(){
	doins -r opt usr
	fperms 755 /opt/viber/Viber
}
