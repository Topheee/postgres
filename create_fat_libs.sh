#!/bin/sh

# iOS 64-bit and 32-bit combined in fat library
mkdir -p out/fat

for lib in $(ls out/ios-simulator/lib/*.a); do
	filename=$(basename $lib)
	lipo -create $lib "out/ios-arm64/lib/$filename" "out/ios-armv7/lib/$filename" -output out/fat/$filename
done

for lib in $(ls out/ios-simulator/lib/*.dylib); do
	if [ ! -h "$lib" ]; then
		filename=$(basename $lib)
		lipo -create $lib "out/ios-arm64/lib/$filename" "out/ios-armv7/lib/$filename" -output out/fat/$filename
	fi
done

