# syntax=docker/dockerfile:1

# Runtime Stage
FROM ghcr.io/linuxserver/baseimage-selkies:arch

# set version label
ARG BUILD_DATE
ARG VERSION
ARG CITRON_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

ENV TITLE=Citron

RUN \
  echo "**** add icon ****" && \
  curl -o \
    /usr/share/selkies/www/icon.png \
    https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/citron-logo.png && \
  echo "**** install packages ****" && \
  pacman -Sy --noconfirm --needed \
    git && \
  cd /tmp && \
  git clone https://aur.archlinux.org/citron.git && \
  chown -R abc:abc citron && \
  cd citron && \
  sed -i \
    '/^build() {/s//&\\\n  export CFLAGS="-march=x86-64-v3 ${CFLAGS}"\\\n  export CXXFLAGS="-march=x86-64-v3 ${CXXFLAGS}"/' \
    PKGBUILD && \
  sudo -u abc makepkg -sAci --skipinteg --noconfirm --needed && \
  echo "**** cleanup ****" && \
  printf \
    "Linuxserver.io version: ${VERSION}\nBuild-date: ${BUILD_DATE}" \
    > /build_version && \
  pacman -Scc --noconfirm && \
  rm -rf \
    /tmp/* \
    /var/cache/pacman/pkg/* \
    /var/lib/pacman/sync/*

# add local files and files from buildstage
COPY root/ /

# ports and volumes
VOLUME /config
EXPOSE 3001
