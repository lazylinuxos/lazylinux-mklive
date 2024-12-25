#!/bin/sh

set -eu

. ./lib.sh

PROGNAME=$(basename "$0")
ARCH=$(uname -m)
IMAGES="base"
TRIPLET=
REPO=
DATE=$(date -u +%Y%m%d)

usage() {
	cat <<-EOH
	Usage: $PROGNAME [options ...] [-- mklive options ...]

	Wrapper script around mklive.sh for several standard flavors of live images.
	Adds lazy-installer and other helpful utilities to the generated images.

	OPTIONS
	 -a <arch>     Set XBPS_ARCH in the image
	 -b <variant>  One of base, enlightenment, xfce, mate, cinnamon, gnome, kde,
	               lxde, or lxqt (default: base). May be specified multiple times
	               to build multiple variants
	 -d <date>     Override the datestamp on the generated image (YYYYMMDD format)
	 -t <arch-date-variant>
	               Equivalent to setting -a, -b, and -d
	 -r <repo>     Use this XBPS repository. May be specified multiple times
	 -h            Show this help and exit
	 -V            Show version and exit

	Other options can be passed directly to mklive.sh by specifying them after the --.
	See mklive.sh -h for more details.
	EOH
}

while getopts "a:b:d:t:hr:V" opt; do
case $opt in
    a) ARCH="$OPTARG";;
    b) IMAGES="$OPTARG";;
    d) DATE="$OPTARG";;
    r) REPO="-r $OPTARG $REPO";;
    t) TRIPLET="$OPTARG";;
    V) version; exit 0;;
    h) usage; exit 0;;
    *) usage >&2; exit 1;;
esac
done
shift $((OPTIND - 1))

INCLUDEDIR=$(mktemp -d)
trap "cleanup" INT TERM

cleanup() {
    rm -rf "$INCLUDEDIR"
}

setup_pipewire() {
    PKGS="$PKGS pipewire alsa-pipewire"
    mkdir -p "$INCLUDEDIR"/etc/xdg/autostart
    ln -sf /usr/share/applications/pipewire.desktop "$INCLUDEDIR"/etc/xdg/autostart/
    mkdir -p "$INCLUDEDIR"/etc/pipewire/pipewire.conf.d
    ln -sf /usr/share/examples/wireplumber/10-wireplumber.conf "$INCLUDEDIR"/etc/pipewire/pipewire.conf.d/
    ln -sf /usr/share/examples/pipewire/20-pipewire-pulse.conf "$INCLUDEDIR"/etc/pipewire/pipewire.conf.d/
    mkdir -p "$INCLUDEDIR"/etc/alsa/conf.d
    ln -sf /usr/share/alsa/alsa.conf.d/50-pipewire.conf "$INCLUDEDIR"/etc/alsa/conf.d
    ln -sf /usr/share/alsa/alsa.conf.d/99-pipewire-default.conf "$INCLUDEDIR"/etc/alsa/conf.d
}

build_variant() {
    variant="$1"
    shift
    IMG=lazylinux-live-${ARCH}-${DATE}-${variant}.iso
    GRUB_PKGS="grub-i386-efi grub-x86_64-efi"
    A11Y_PKGS="espeakup void-live-audio brltty"
    PKGS="dialog cryptsetup lvm2 mdadm void-docs-browse xtools-minimal xmirror chrony $A11Y_PKGS $GRUB_PKGS"
    XORG_PKGS="xorg-minimal xorg-input-drivers xorg-video-drivers setxkbmap xauth font-misc-misc terminus-font dejavu-fonts-ttf noto-fonts-emoji noto-fonts-ttf noto-fonts-ttf-extra alsa-plugins-pulseaudio alsa-utils apulse alsa-ucm-conf sof-firmware orca"
    REC_PKGS="void-repo-nonfree void-repo-multilib void-repo-multilib-nonfree smbclient samba superd binutils xcolor xclip xsel xarchiver xreader xz zip unzip 7zip-unrar zstd xkill xdg-user-dirs xdg-user-dirs-gtk socklog-void preload xkblayout-state curl wget git gptfdisk mtools mlocate ntfs-3g fuse-exfat bash-completion linux-headers ffmpeg mesa-vdpau mesa-vaapi webkit2gtk hostapd cronie snooze bluez blueman cups cups-pk-helper cups-filters foomatic-db foomatic-db-engine system-config-printer tlp tlp-rdw powertop NetworkManager-openvpn NetworkManager-openconnect NetworkManager-strongswan NetworkManager-l2tp NetworkManager-pptp flatpak"
    DEV_PKGS="base-devel docker docker-buildx nix cargo go nodejs autoconf automake bison m4 make libtool flex meson ninja optipng sassc sqlite-devel gtk+3-devel glib-devel gcc pkg-config make qrencode-devel libpng-devel libX11-devel libXft-devel libXcursor-devel libXrandr-devel libXinerama-devel libXi-devel python3-pip qt5 python3-PyQt5-dbus python3-setproctitle python3-devel"
    GUI_PKGS="thunar-media-tags-plugin kitty barrier barrier-gui redshift-gtk wireshark imhex virt-manager qemu libvirt bridge-utils onboard gufw mugshot octoxbps hardinfo ghostwriter gparted obs keepassxc syncthing syncthingtray deadbeef gpodder liferea cherrytree plymouth thunderbird simple-scan bleachbit dbeaver fsearch qdirstat imagewriter qbittorrent handbrake inkscape flameshot telegram-desktop remmina gimp vlc timeshift vscode halloy dino dconf-editor libreoffice-writer libreoffice-calc libreoffice-impress libreoffice-draw libreoffice-math libreoffice-base libreoffice-gnome"
    TUI_PKGS="podman hddtemp lm_sensors zellij xmirror nano vim btop vsv topgrade yazi hblock fish-shell fastfetch fzf zoxide bat ripgrep exa dust Clipboard lazygit lazydocker helix rofi openfortivpn zbar tesseract-ocr tesseract-ocr-eng tesseract-ocr-hye tesseract-ocr-rus tesseract-ocr-script-Armenian"
    LANG_PKGS="libreoffice-i18n-en-US libreoffice-i18n-ru thunderbird-i18n-en-US thunderbird-i18n-hy-AM thunderbird-i18n-ru"
    CUSTOM_PKGS="distrobox zen-browser brave-browser cortile neohtop webapp-manager yaak thunar-shares-plugin podman-desktop muCommander"
    PKGS_TO_REMOVE="parole"
    SERVICES="sshd chronyd libvirtd virtlockd virtlogd"

    LIGHTDM_SESSION=''

    case $variant in
        base)
            SERVICES="$SERVICES dhcpcd wpa_supplicant acpid"
        ;;
        enlightenment)
            PKGS="$PKGS $XORG_PKGS lightdm lightdm-gtk3-greeter enlightenment terminology udisks2 firefox"
            SERVICES="$SERVICES acpid dhcpcd wpa_supplicant lightdm dbus polkitd"
            LIGHTDM_SESSION=enlightenment
        ;;
        xfce)
            PKGS="$PKGS $XORG_PKGS $REC_PKGS $DEV_PKGS $GUI_PKGS $TUI_PKGS $LANG_PKGS $CUSTOM_PKGS lightdm lightdm-gtk3-greeter lightdm-gtk-greeter-settings xfce4 xfce4-plugins xfce4-docklike-plugin thunar-archive-plugin galculator-gtk3 gnome-themes-standard gnome-keyring network-manager-applet gvfs-afc gvfs-mtp gvfs-smb udisks2"
            SERVICES="$SERVICES dbus elogind lightdm NetworkManager polkitd podman docker containerd tlp cupsd bluetoothd cronie snooze-daily socklog-unix nanoklogd preload nix-daemon smbd"
            LIGHTDM_SESSION=xfce
        ;;
        mate)
            PKGS="$PKGS $XORG_PKGS lightdm lightdm-gtk3-greeter mate mate-extra gnome-keyring network-manager-applet gvfs-afc gvfs-mtp gvfs-smb udisks2 firefox"
            SERVICES="$SERVICES dbus lightdm NetworkManager polkitd"
            LIGHTDM_SESSION=mate
        ;;
        cinnamon)
            PKGS="$PKGS $XORG_PKGS lightdm lightdm-gtk3-greeter cinnamon gnome-keyring colord gnome-terminal gvfs-afc gvfs-mtp gvfs-smb udisks2 firefox"
            SERVICES="$SERVICES dbus lightdm NetworkManager polkitd"
            LIGHTDM_SESSION=cinnamon
        ;;
        gnome)
            PKGS="$PKGS $XORG_PKGS gnome firefox"
            SERVICES="$SERVICES dbus gdm NetworkManager polkitd"
        ;;
        kde)
            PKGS="$PKGS $XORG_PKGS kde5 konsole firefox dolphin NetworkManager"
            SERVICES="$SERVICES dbus NetworkManager sddm"
        ;;
        lxde)
            PKGS="$PKGS $XORG_PKGS lxde lightdm lightdm-gtk3-greeter gvfs-afc gvfs-mtp gvfs-smb udisks2 firefox"
            SERVICES="$SERVICES acpid dbus dhcpcd wpa_supplicant lightdm polkitd"
            LIGHTDM_SESSION=LXDE
        ;;
        lxqt)
            PKGS="$PKGS $XORG_PKGS lxqt sddm gvfs-afc gvfs-mtp gvfs-smb udisks2 firefox"
            SERVICES="$SERVICES dbus dhcpcd wpa_supplicant sddm polkitd"
        ;;
        *)
            >&2 echo "Unknown variant $variant"
            exit 1
        ;;
    esac

    if [ -n "$LIGHTDM_SESSION" ]; then
        mkdir -p "$INCLUDEDIR"/etc/lightdm
        echo "$LIGHTDM_SESSION" > "$INCLUDEDIR"/etc/lightdm/.session
        # needed to show the keyboard layout menu on the login screen
        cat <<- EOF > "$INCLUDEDIR"/etc/lightdm/lightdm-gtk-greeter.conf
[greeter]
indicators = ~host;~spacer;~clock;~spacer;~layout;~session;~a11y;~power
EOF
    fi

    if [ "$variant" != base ]; then
        setup_pipewire
    fi

    ./mklive.sh -a "$ARCH" -o "$IMG" -v "linux6.6" -T "LazyLinux" -p "$PKGS" -S "$SERVICES" -I "$INCLUDEDIR" -I ./includedir/ -g "$PKGS_TO_REMOVE" ${REPO} "$@"

	cleanup
}

if [ ! -x mklive.sh ]; then
    echo mklive.sh not found >&2
    exit 1
fi

if [ -x installer.sh ]; then
    MKLIVE_VERSION="$(PROGNAME='' version)"
    installer=$(mktemp)
    sed "s/@@MKLIVE_VERSION@@/${MKLIVE_VERSION}/" installer.sh > "$installer"
    install -Dm755 "$installer" "$INCLUDEDIR"/usr/bin/lazy-installer
    rm "$installer"
else
    echo installer.sh not found >&2
    exit 1
fi

if [ -n "$TRIPLET" ]; then
    VARIANT="${TRIPLET##*-}"
    REST="${TRIPLET%-*}"
    DATE="${REST##*-}"
    ARCH="${REST%-*}"
    build_variant "$VARIANT" "$@"
else
    for image in $IMAGES; do
        build_variant "$image" "$@"
    done
fi
