FROM linuxkit/kernel:4.9.125 AS kernelsrc

FROM alpine:latest AS modulesrc
MAINTAINER Thomas Labarussias <issif+falco@gadz.org>
ARG SYSDIGVER=0.25
ARG FALCOVER=0.15.0
ARG KERNELVER=4.9.125
COPY --from=kernelsrc /kernel-dev.tar /
RUN apk add --no-cache --update wget ca-certificates \
   build-base gcc abuild binutils \
   bc \
   cmake \
   git \
   autoconf && \
   export KERNELDIR=/usr/src/linux-headers-$KERNELVER-linuxkit/ && \
   tar xf /kernel-dev.tar && \
   cd $KERNELDIR && \
   find /proc -type f -name "config.gz" -exec cp {} . \; && \
 #  zcat /proc/config.gz > .config && \
 #  zcat /proc/1/root/proc/config.gz > .config && \
   make olddefconfig && \
   mkdir -p /falco/build && \
   mkdir /src && \
   cd /src && \
   wget https://github.com/falcosecurity/falco/archive/$FALCOVER.tar.gz && \
   tar zxf $FALCOVER.tar.gz && \
   wget https://github.com/draios/sysdig/archive/$SYSDIGVER.tar.gz && \
   tar zxf $SYSDIGVER.tar.gz && \
   mv sysdig-$SYSDIGVER sysdig && \ 
   cd /falco/build && \
   cmake /src/falco-$FALCOVER && \
   make driver && \
   apk del wget ca-certificates \
   build-base gcc abuild binutils \
   bc \
   cmake \
   git \
   autoconf

FROM sysdig/falco:0.12.1

COPY --from=modulesrc /falco/build/driver/falco-probe.ko /

COPY ./docker-entrypoint.sh / 

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["/usr/bin/falco"]
