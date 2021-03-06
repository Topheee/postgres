#!/bin/sh


# references:
# - https://gcc.gnu.org/onlinedocs/gcc/ARM-Options.html
# - https://clang.llvm.org/docs/CrossCompilation.html
# - https://www.postgresql.org/docs/current/install-procedure.html


# exit on first error
set -e

build_ios() {
	make clean

	FOLDER="out/ios-$ARCH"
	rm -r "$FOLDER"
	mkdir -p "$FOLDER"

	./configure --prefix="`pwd`/$FOLDER" --host=x86_64-apple-darwin --build=$ARCH-apple-ios --with-template=ios --without-readline CPP="gcc -E" CFLAGS="--target=$ARCH-apple-ios" CPPFLAGS="--target=$ARCH-apple-ios" LDFLAGS="--target=$ARCH-apple-ios -Wl,-dead_strip_dylibs"  > ./configure-ios-$ARCH.log
	make -j `sysctl -n hw.ncpu` | tee build-ios-$ARCH.log

	# only build client tools, not whole db
	make -C src/bin install
	make -C src/include install
	make -C src/interfaces install
	make -C src/port install
	make -C src/common install
}

# iOS 64-bit
ARCH=arm64
build_ios


# iOS 32-bit - needs CFLAGS explicitly specified
build_ios_armv7() {
	make clean

	FOLDER="out/ios-$ARCH"
	rm -r "$FOLDER"
	mkdir -p "$FOLDER"

	./configure --prefix="`pwd`/$FOLDER" --host=x86_64-apple-darwin --build=$ARCH-apple-ios --with-template=ios --without-readline CPP="gcc -E" CFLAGS="--target=$ARCH-apple-ios -Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Wendif-labels -Wmissing-format-attribute -Wformat-security -fno-strict-aliasing -fwrapv -Wno-unused-command-line-argument -O2 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS14.3.sdk" CPPFLAGS="--target=$ARCH-apple-ios" LDFLAGS="--target=$ARCH-apple-ios -Wl,-dead_strip_dylibs" > ./configure-ios-$ARCH.log
	make -j `sysctl -n hw.ncpu` | tee build-ios-$ARCH.log

	# only build client tools, not whole db
	make -C src/bin install
	make -C src/include install
	make -C src/interfaces install
	make -C src/port install
	make -C src/common install
}


ARCH=armv7
build_ios_armv7

# iOS Simulator on macOS 11 and above
ARCH=x86_64
build_simulator() {
	make clean

	FOLDER="out/ios-simulator"
	rm -r "$FOLDER"
	mkdir -p "$FOLDER"

	./configure --prefix="`pwd`/$FOLDER" --host=x86_64-apple-darwin --build=$ARCH-apple-ios-simulator --with-template=ios-simulator --without-readline CFLAGS="-arch $ARCH" CXXFLAGS="-arch $ARCH" > ./configure-ios-simulator.log
	make -j `sysctl -n hw.ncpu` | tee build-ios-simulator.log

	# only build client tools, not whole db
	make -C src/bin install
	make -C src/include install
	make -C src/interfaces install
	make -C src/port install
	make -C src/common install
}

build_simulator

# iOS Simulator on old macOS
#ARCH=i386
#build_simulator


# iOS and iOS Simulator 64-bit and 32-bit libraries combined in one 'fat' library
./create_fat_libs.sh

