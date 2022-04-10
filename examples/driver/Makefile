XCODE ?= /Applications/Xcode.app/Contents/Developer
SDKROOT ?= ${XCODE}/Platforms/MacOSX.platform/Developer/SDKs/MacOSX12.3.sdk
TOOLCHAIN ?= ${XCODE}/Toolchains/XcodeDefault.xctoolchain

METAL = ${TOOLCHAIN}/usr/bin/metal

METAL_FLAGS = -target air64-apple-macos12.1 -MO
METAL_CFLAGS = ${METAL_FLAGS} -gline-tables-only -MO -isysroot ${SDKROOT} -ffast-math
METAL_LDFLAGS = ${METAL_FLAGS}
.PHONY: all
all: vadd.metallib

vadd.air: vadd.metal
	${METAL} ${METAL_CFLAGS} -c -o $@ $<

vadd.metallib: vadd.air
	${METAL} ${METAL_LDFLAGS} -o $@ $<

.PHONY: clean
clean:
	${RM} vadd.air vadd.metallib
