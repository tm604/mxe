# This file is part of MXE.
# See index.html for further information.

PKG             := protobuf
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 2.6.1
$(PKG)_CHECKSUM := 6421ee86d8fb4e39f21f56991daa892a3e8d314b
$(PKG)_SUBDIR   := $(PKG)-$($(PKG)_VERSION)
$(PKG)_FILE     := $(PKG)-$($(PKG)_VERSION).tar.bz2
$(PKG)_URL      := https://github.com/google/protobuf/releases/download/v$($(PKG)_VERSION)/$($(PKG)_FILE)
$(PKG)_DEPS     := gcc zlib

define $(PKG)_UPDATE
    $(WGET) -q -O- 'http://code.google.com/p/protobuf/downloads/list?sort=-uploaded' | \
    $(SED) -n 's,.*protobuf-\([0-9][^<]*\)\.tar.*,\1,p' | \
    grep -v 'rc' | \
    head -1
endef

define $(PKG)_BUILD
# First step: Build for host system in order to create "protoc" binary.
    cd '$(1)' && ./configure \
        --disable-shared
    $(MAKE) -C '$(1)' -j '$(JOBS)'
    cp '$(1)/src/protoc' '$(1)/src/protoc_host'
    $(MAKE) -C '$(1)' -j 1 distclean
# Second step: Build for target system.
    cd '$(1)' && ./configure \
        $(MXE_CONFIGURE_OPTS) \
        --with-zlib \
        --with-protoc=src/protoc_host
    $(MAKE) -C '$(1)' -j '$(JOBS)'
    $(MAKE) -C '$(1)' -j 1 install

    '$(TARGET)-g++' \
        -W -Wall -Werror -ansi -pedantic \
        '$(2).cpp' -o '$(PREFIX)/$(TARGET)/bin/test-protobuf.exe' \
        `'$(TARGET)-pkg-config' protobuf --cflags --libs`
endef
