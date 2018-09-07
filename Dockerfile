FROM debian:8

RUN set -x &&\
	cd /etc/apt &&\
	awk '($1 == "deb"){$1 = "deb-src";print;}' sources.list >sources.list.d/src.list &&\
	mkdir -p /root/work &&\
	cd /root/work &&\
	apt-get update &&\
	apt-get -y build-dep qemu dash &&\
	apt-get source qemu dash

COPY qemu_support_shebang.patch qemu_execmyself.patch /root/work/qemu-2.1+dfsg/linux-user/

RUN set -x &&\
	cd /root/work/qemu-*/linux-user/ &&\
	patch main.c qemu_support_shebang.patch &&\
	patch syscall.c qemu_execmyself.patch &&\
	cd /root/work/qemu-* &&\
	./configure --target-list=arm-linux-user --static &&\
	make &&\
	! ldd arm-linux-user/qemu-arm

RUN set -x &&\
	cd /root/work &&\
	apt-get -y build-dep dash &&\
	apt-get source dash &&\
	cd dash-* &&\
	./configure --enable-static &&\
	make &&\
	! ldd src/dash

RUN set -x &&\
	apt-get -y install debootstrap wget &&\
	mkdir -p /armroot/bin /armroot/usr/local/bin /armroot/usr/local/sbin &&\
	cd /armroot/usr/local/bin &&\
	cp /root/work/qemu-*/arm-linux-user/qemu-arm ./qemu-user-static-execmyself &&\
	cd /armroot/bin &&\
	cp /root/work/dash-*/src/dash ./dash-x86 &&\
	cd /armroot/usr/local/sbin &&\
	ln -s /usr/bin/dpkg-deb &&\
	ln -s /usr/bin/dpkg-split &&\
	ln -s /bin/tar &&\
	ln -s /bin/rm &&\
	ln -s /sbin/insserv


#COPY debootstrap_nomount.patch /armroot/debootstrap/
#	debootstrap --arch=armhf --foreign jessie .
#	patch functions debootstrap_nomount.patch

