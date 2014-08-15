#!/bin/bash

steamdir=$(locate "steam.pipe" | head -1 | sed "s/\/steam\.pipe/\/steam/")
steamlibs=$(locate steam-runtime/i386 | head -1)
dundeflibs="$steamdir/SteamApps/common/DunDefEternity/DunDefEternity/Binaries/Linux"

check()
{
    ldd "$dundeflibs/DunDefGame" | grep "not found" | \
        tr -d "\t" | cut -d"=" -f1 | sort -u
}

symfix()
{
    while [[ -n $(check) ]]; do
        for i in $(check); do
            steamlib=$(find "$steamlibs" -name "$i")
            if [[ -n $steamlib ]]; then
                ln -s $steamlib $dundeflibs/$i
                echo "$i was linked"
            else
                echo "$i was not found"
                break 2
            fi 
        done
    done
}

pkgfix()
{
    echo "Installing the required packages"

    if [[ -x "$(which aptitude)" ]]; then
        sudo dpkg --add-architecture i386
        sudo aptitude Install ibgconf-2-4:i386 libvorbisfile3:i386 \
            libsfml-dev:i386 libcrypto++-dev:i386 libcurl4-nss-dev:i386 \
            libcurl4-openssl-dev:i386 libfreetype6:i386 libxrandr2:i386 \
            libgtk2.0-0:i386 libpango-1.0-0:i386 libpangocairo-1.0-0:i386 \
            libasound2-dev:i386 libgdk-pixbuf2.0-0:i386
    fi

    if [[ -x "$(which yum)" ]]; then
        sudo yum install GConf2.i686 GConf2-devel.i686 libvorbis.i686 \
            SFML.i686 SFML-devel.i686 cryptopp.i686 libcurl.i686 libcurl-devel.i686 \
            freetype.i686 freetype-devel.i686 libXrandr.i686 libXrandr-devel.i686 \
            gtk2.i686 gtk2-devel.i686 pango.i686 pango-devel.i686 cairo.i686 \
            cairo-devel.i686 gfk-pixbuf2-devel.i686 gtk-pixbuf2.i686
    fi

    if [[ -x "$(which pacman)" ]]; then
        echo "Only Apt and Yum based systems are currently supported"
    fi
}

while true; do
    echo "Choose one of the following potential fixes"
    echo "1 - Symbolic Link Fix"
    echo "2 - Package Install Fix"
    echo "Q or q to quit"
    read answer

    echo ""

    case $answer in
        1)
            symfix
            break
            ;;
        2)
            pkgfix
            break
            ;;
        Q|q)
            exit
            ;;
        *)
            echo ""
            echo "\"$answer\" is not an option "
    esac

    echo ""
done

echo ""

if [[ -n $(check) ]]; then
    echo "You are still missing required libraries"
    echo "Make sure these are all valid directories"
    echo "$steamdir"
    echo "$steamlibs"
    echo "$dundeflibs"
else
    echo "You have all the required libraries"
fi
