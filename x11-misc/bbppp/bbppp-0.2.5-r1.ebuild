# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools

DESCRIPTION="blackbox ppp frontend/monitor"
HOMEPAGE="https://sourceforge.net/projects/bbtools/"
SRC_URI="https://downloads.sourceforge.net/bbtools/${PN}/${P}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ppc x86"

COMMON_DEPEND="x11-libs/libX11"
DEPEND="${COMMON_DEPEND}
	elibc_musl? ( net-libs/ppp-defs )"
RDEPEND="${COMMON_DEPEND}
	media-fonts/font-adobe-100dpi"

PATCHES=(
	"${FILESDIR}"/${P}-gcc3-multiline.patch
	"${FILESDIR}"/${PN}-asneeded.patch
	"${FILESDIR}"/${P}-overflows.patch
)

src_prepare() {
	default
	mv configure.{in,ac} || die
	sed -i \
		-e 's|register ||' \
		Image.cc LinkedList.cc || die
	eautoreconf
}

src_install() {
	default
	dodoc BUGS data/README.bbppp

	rm "${ED}"/usr/share/bbtools/README.bbppp || die
}

pkg_postinst() {
	# don't assume blackbox exists because virtual/blackbox is installed
	if [[ -x ${EROOT}/usr/bin/blackbox ]] ; then
		if ! grep bbppp "${EROOT}"/usr/bin/blackbox &>/dev/null ; then
			sed -e "s/.*blackbox/exec \/usr\/bin\/bbppp \&\n&/" blackbox | cat > blackbox
		fi
	fi
}
