# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=8
inherit 
#eutils

if [ "${PV}" == "9999" ]; then
    inherit git-r3
    SRC_URI=""
    EGIT_REPO_URI="https://github.com/alexdux/async-emerge/"
    EGIT_BRANCH="master"
    KEYWORDS=""
else
    SRC_URI="https://raw.github.com/alexdux/async-emerge/master/distfiles/${P}.tar.bz2"
    KEYWORDS="amd64 x86"
fi

HOMEPAGE="https://github.com/alexdux/async-emerge"
DESCRIPTION="Periodically sync portage and build binary packages for Gentoo updates."
LICENSE="GPL-2"
SLOT="0"

IUSE="logrotate noemail notmpfs" # "eix layman"

# A space delimited list of portage features to restrict. man 5 ebuild for details.  Usually not needed.
#RESTRICT="strip"
RESTRICT="mirror"
#RESTRICT="fetch"

RDEPEND="app-portage/gentoolkit
	app-shells/bash
	app-portage/eix
	sys-process/lsof
	sys-apps/util-linux
	!noemail? ( net-mail/email )"
#DEPEND="${RDEPEND}"

src_configure() {
	# a hack
	if [[ "${PV}" == "9999" ]]; then
		S="${S}/trunk/"
	fi
	AE_CONF="${S}/etc/async.emerge.conf"
	# to-do: add checking FEATURES & EMERGE_DEFAULT_OPTS
	# configure USE
	if use notmpfs ; then
		sed -i -e 's/\([[] \"$AE_NOTMPFS\" []]\)/#\1/' "${AE_CONF}" || \
			die "Can't adjust AE_NOTMPFS! Stop."
		sed -i -e 's/#\([[] \"$AE_USETMPFS\" []]\)/\1/' "${AE_CONF}" || \
			die "Can't adjust AE_USETMPFS! Stop."
	fi
	# portage version adjust
	P_VER=$(emerge --info | grep 'portage ' -i | cut -f2 -d' ')
	if [[ "${P_VER}" > "2.2" ]]; then # new portage-2.2 +
		sed -i -e "s/^\(AE_REBUILD\[DO_OBSOLETED_LIBS\]='\)y/\1n/" "${AE_CONF}" || \
			die "Can't adjust AE_REBUILD[DO_OBSOLETED_LIBS]! Stop."
		sed -i -e "s/^\(AE_REBUILD\[DO_REVDEP_REBUILD\]='\)y/\1n/" "${AE_CONF}" || \
			die "Can't adjust AE_REBUILD[DO_REVDEP_REBUILD]! Stop."
		# $(qlist -I -C x11-drivers/) -> @x11-module-rebuild
#		sed -i -e "s/\$\(qlist -I -C x11-drivers\/\)/\@x11-module-rebuild/" "${AE_CONF}" || \
#			die "Can't adjust add_subset_update 'X server'! Stop."
		if [[ "${P_VER}" > "2.2.16" ]]; then # since some about 2.2.16 we don't need use perl-cleaner,
												# it's build-in in portage
			sed -i -e "s/\(add_subset_update 'eixc' 'dev-lang\/perl'\)/# \1/" "${AE_CONF}" || \
			die "Can't adjust PERL subset! Stop."
		fi
	else # old portage-2.2 -
		sed -i -e "s/^\(AE_REBUILD\[DO_PRESERVED_REBUILD\]='\)y/\1n/" "${AE_CONF}" || \
			die "Can't adjust AE_REBUILD[DO_PRESERVED_REBUILD]! Stop."
	fi
	# get some portage vars
	#grep -o '`portageq .*`' "${AE_CONF}" | cut -f2 -d'`' | \
	#	while read str_todo; do 
	#		sed -i -e "s@\`${str_todo}\`@`${str_todo}`@" "${AE_CONF}" || \
	#			die "Can't exec '${str_todo}'! Stop." # '
	#	done
	sed -i -e "s/^\(AE_DIR\[PKGDIR\]=\)\"`portageq pkgdir`\"/\1$(emerge --info | grep PKGDIR | cut -f2 -d'=')/" "${AE_CONF}" || \
		die "Can't adjust AE_DIR[PKGDIR]! Stop."

	# disable ccache if not installed (not tested)
	[ "$CCACHE_DIR" ] || \
		sed -i -e "s/^\(AE_DIR\[TRANSPARENT\]+=\" $CCACHE_DIR\"\)/#\1/" "${AE_CONF}" || \
			die "Can't adjust AE_DIR[TRANSPARENT]! Stop."
}

src_install() {
	# bin
	dodir /usr/bin
	cp -R ${S}/bin/* ${D}/usr/bin/ || die
	# conf
	insinto /etc
	doins ${S}/etc/* || die
	# log
	keepdir /var/log/async.emerge
	# logrotate config for AE
	#if has_version "app-admin/logrotate"; then
	if use logrotate ; then
		dodir /etc/logrotate.d/
		cp -R ${S}/etc/logrotate.d/* ${D}/etc/logrotate.d/ || die                                  
		keepdir /var/log/async.emerge/archive
	fi
	# make_linux
	dodir /usr/src
	cp -R ${S}/src/* ${D}/usr/src/ || die
}

