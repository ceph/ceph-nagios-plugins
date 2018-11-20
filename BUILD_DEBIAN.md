# Build Debian Package

You can build a Debian package (source and binary) 

## Requirments

To build the package first install the required package building dependencies:

    sudo apt-get install build-essential fakeroot devscripts

## Build package

Use the included `Makefile` to build the binary package:

    make deb

And to build the source package:

    make deb-src

And to clean the project:

    make clean

