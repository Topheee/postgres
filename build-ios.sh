#!/bin/sh


# references:
# - https://gcc.gnu.org/onlinedocs/gcc/ARM-Options.html
# - https://clang.llvm.org/docs/CrossCompilation.html
# - https://www.postgresql.org/docs/current/install-procedure.html


# exit on first error
set -e

# iOS 64-bit
ARCH=arm64
build_ios() {
	make clean

	FOLDER="out/ios"
	rm -r "$FOLDER"
	mkdir -p "$FOLDER"

	./configure --prefix="`pwd`/$FOLDER" --host=x86_64-apple-darwin --build=$ARCH-apple-ios --with-template=ios --without-readline CPP="gcc -E" CFLAGS="--target=arm64-apple-ios" CPPFLAGS="--target=$ARCH-apple-ios" LDFLAGS="--target=$ARCH-apple-ios -Wl,-dead_strip_dylibs"  > ./configure-ios.log
	make -j `sysctl -n hw.ncpu` | tee build-ios.log
	
	# only build client tools, not whole db
	make -C src/bin install
	make -C src/include install
	make -C src/interfaces install
	make -C src/port install
	make -C src/common install
}

build_ios


# iOS 32-bit - does not build anymore on macOS 11 Big Sur (and probably also not on 10 since 32-bit was discontinued there)
#ARCH=armv7
#buildit

# iOS Simulator on old macOS
#ARCH=i386
#buildit

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

# iOS 64-bit and 32-bit combined in fat library
./create_fat_libs.sh

