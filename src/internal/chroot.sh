#!/bin/bash

if [[ "$1" == "-p" ]]; then
    if [[ ! -f /initrc ]]; then
        echo "No installed system, please install one." >&2
        exit 1
    fi

    /.chrootbin/chmod +x /initrd
    if [[ ! -f /.running ]]; then
        /.chrootbin/mkdir /.running
        trap rm -rf /.running
    else
        echo "VM already running." >&2
        exit 1
    fi
    exec /initrc
    exit $?
fi

P=$(realpath "$0")
P="${P%/*}"

if [[ ! -f "${P}/proot" ]]; then
    echo "No PRoot, please reinstall." >&2
    exit 1
fi

if [[ "$#" -lt 1 ]]; then 
    echo "No argument specified. If this is in the app, please reinstall." >&2; exit 1
fi

proot() 
{
	"${P}/proot" -r "${@: -1}" bash -c "$(cat "${P}"/chroot.sh)" -b /proc -b /dev -b /bin:./.chrootbin
}

if [[ $1 == "-r" ]]; then
    chmod +x "${P}/proot"
    cd "$2"
    if [[ "$?" -gt 0 ]]; then
        echo "Error entering chroot." >&2
        exit 1
    fi
    if [[ ! -d ./.chrootbin ]]; then
        mkdir ./.chrootbin
    fi
    if [[ ! -d ./.chrootbin ]]; then
        echo "Error assigning data." >&2
        exit 1
    fi
    local time="$(time proot)"
	local result="$?"
	if [[ result -gt 0 ]]; then
		if [[ time -ge 1.0 ]]; then
			exit "$(result)";
		fi
	fi
	exit 
fi

# Install tar.gz
if [[ "$1" == "-i" ]]; then
	if [[ "$#" -lt 3 ]]; then
		local path="${2##*/}"
		path="${path%.tar.*}"
		mkdir "${P}/chroots/$path"
		if [[ "$?" -gt 0 ]]; then
			local e="$?"
			echo "\nFailed creating chroot." >&2
			exit 1
		fi
		tar -xvzf "$2" -C "${P}/chroots/$path"
		if [[ "$?" -gt 0 ]]; then
			local e="$?"
			exit 1
		fi
		bash ${P}/chroot.sh -r "${P}/chroots/$path"
		if [[ "$?" -gt 0 ]]; then
			local e="$?"
			exit 1
		fi
		exit
	fi

	if (( "$3" != "-n" )); then
		echo "Invalid argument \"$3\". If this is in the app please reinstall." >&2
		exit 126
	fi

	mkdir "${P}/chroots/$4"
	if [[ "$?" -gt 0 ]]; then
		local e="$?"
		echo "\nFailed creating chroot." >&2
		exit 1
	fi
	tar -xvf "$2" -C "${P}/chroots/$4"
	if [[ "$?" -gt 0 ]]; then
		local e="$?"
		exit 1
	fi
	bash "${P}/chroot.sh" -r "${P}/chroots/$4"
	if [[ "$?" -gt 0 ]]; then
		local e="$?"
		exit 1
	fi
	exit
fi

LETTERS=abcdefghijklmnopqrstuvwxyz

if [[ "$1" == "-I" ]]; then
	# Android has curl
	ls /bin/curl
	local e="$?"
	if [[ "$e" -gt 0 ]]; then
		exit "$e"
	fi

	local tmp=""

	for ((i=0; i<10; i++)); do
		tmp+="${LETTERS:RANDOM%26:1}"
	done

	touch "${P}/tmp/$tmp.tar.tar"
	/bin/curl -o "${P}/tmp/$tmp.tar.tar" "$2"
	local e="$?"
	trap rm -rf "${P}/tmp/$tmp.tar.tar"

	if [[ "$e" -gt 0 ]]; then
		exit 1;
	fi

	if [[ "$#" -lt 3 ]]; then
		local url="${2%%\?*}"
		/bin/bash "${P}/chroot.sh" -i "${P}/tmp/$tmp.tar.tar" -n "$url"
		if [[ "$?" -gt 0 ]]; then
			exit 1
		fi
	fi

	if [[ "$3" == "-n" ]]; then
		echo "Invalid argument \"$3\". If this is in the app please reinstall." >&2
		exit 126
	fi

	/bin/bash "${P}/chroot.sh" -i "${P}/tmp/$tmp.tar.tar" -n "$4"
	if [[ "$?" -gt 0 ]]; then
		exit 1
	fi
	exit 0
fi

if [[ "$1" == "-t" ]]; then
	local ptype="$(uname -m)"
	local tarball="nothing"
	if [[ $2 == "ubuntu" ]]; then
		if [[ ptype == "arm64" ]]; then
			tarball="https://images.linuxcontainers.org/images/ubuntu/stonking/arm64/default/20261118_07%3A42/rootfs.tar.xz"
		fi
		if [[ ptype == "amd64" || ptype == "x86_64" ]]; then
			tarball="https://images.linuxcontainers.org/images/ubuntu/stonking/amd64/default/20261118_07%3A42/rootfs.tar.xz"
		fi
	fi
	if [[ $2 == "debian" ]]; then
		if [[ ptype == "arm64" ]]; then
			tarball="https://images.linuxcontainers.org/images/debian/trixie/arm64/default/20261118_05%3A24/rootfs.tar.xz"
		fi
		if [[ ptype == "amd64" || ptype == "x86_64" ]]; then
			tarball="https://images.linuxcontainers.org/images/debian/trixie/amd64/default/20261118_05%3A24/rootfs.tar.xz"
		fi
	fi
	if [[ $2 == "alpine" ]]; then
		if [[ ptype == "arm64" ]]; then
			tarball="https://images.linuxcontainers.org/images/alpine/3.24/arm64/default/20261117_13%3A01/rootfs.tar.xz"
		fi
		if [[ ptype == "amd64" || ptype == "x86_64" ]]; then
			tarball="https://images.linuxcontainers.org/images/alpine/3.24/amd64/default/20261117_13%3A00/rootfs.tar.xz"
		fi
	fi
	if [[ $2 == "centos" ]]; then
		if [[ ptype == "arm64" ]]; then
			tarball="https://images.linuxcontainers.org/images/centos/10-Stream/arm64/default/20261117_07%3A36/rootfs.tar.xz"
		fi
		if [[ ptype == "amd64" || ptype == "x86_64" ]]; then
			tarball="https://images.linuxcontainers.org/images/centos/10-Stream/amd64/default/20261117_07%3A36/rootfs.tar.xz"
		fi
	fi
	if [[ $2 == "archlinux" ]]; then
		if [[ ptype == "arm64" ]]; then
			tarball="https://images.linuxcontainers.org/images/archlinux/current/arm64/default/20261118_04%3A18/rootfs.tar.xz"
		fi
		if [[ ptype == "amd64" || ptype == "x86_64" ]]; then
			tarball="https://images.linuxcontainers.org/images/archlinux/current/amd64/default/20261118_04%3A18/rootfs.tar.xz"
		fi
	fi

	/bin/bash "${P}/chroot.sh" -I "$tarball" -n $4
	if [[ "$?" -gt 0 ]]; then
		exit 1;
	fi
	exit 0;
fi
exit 126;