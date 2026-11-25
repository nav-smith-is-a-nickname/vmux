import { SplashScreen } from '@capacitor/splash-screen';
import { Filesystem, Directory } from "@capacitor/filesystem";
window.onload = SplashScreen.hide;

const templates = {
    "Alpine": ["https://images.linuxcontainers.org/images/alpine/3.24/arm64/default/20261117_13%3A01/rootfs.tar.xz", "https://images.linuxcontainers.org/images/alpine/3.24/amd64/default/20261117_13%3A00/rootfs.tar.xz"],
    "Arch Linux": ["https://images.linuxcontainers.org/images/archlinux/current/arm64/default/20261118_04%3A18/rootfs.tar.xz", "https://images.linuxcontainers.org/images/archlinux/current/amd64/default/20261118_04%3A18/rootfs.tar.xz"],
    "CentOS": ["https://images.linuxcontainers.org/images/centos/10-Stream/arm64/default/20261117_07%3A36/rootfs.tar.xz", "https://images.linuxcontainers.org/images/centos/10-Stream/amd64/default/20261117_07%3A36/rootfs.tar.xz"],
    "Debian": ["https://images.linuxcontainers.org/images/debian/trixie/arm64/default/20261118_05%3A24/rootfs.tar.xz", "https://images.linuxcontainers.org/images/debian/trixie/amd64/default/20261118_05%3A24/rootfs.tar.xz"],
    "Ubuntu": ["https://images.linuxcontainers.org/images/ubuntu/stonking/arm64/default/20261118_07%3A42/rootfs.tar.xz", "https://images.linuxcontainers.org/images/ubuntu/stonking/amd64/default/20261118_07%3A42/rootfs.tar.xz"],
};

function install(input, name)
{
    
};