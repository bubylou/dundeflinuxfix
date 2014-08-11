#!/bin/bash

steamdir=$(locate "steam.pipe" | head -1 | sed "s/\/steam\.pipe/\/steam/")
steamlibs=$(locate steam-runtime/i386 | head -1)
dundeflibs="$steamdir/SteamApps/common/DunDefEternity/DunDefEternity/Binaries/Linux"

check()
{
    ldd "$dundeflibs/DunDefGame" | grep "not found" | \
        tr -d "\t" | cut -d"=" -f1
}

symfix()
{
    while [[ -n $(check) ]]; do
        for i in $(check); do
            steamlib=$(find "$steamlibs" -name "$i")
            if [[ -n $steamlib ]]; then
                ln -sf $steamlib $dundeflibs/$i
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
        echo "Only Apt based systems are currently supported"
    fi

    if [[ -x "$(which pacman)" ]]; then
        echo "Only Apt based systems are currently supported"
    fi

}

while true; do
    printf "\n"
    echo "Choose one of the following potential fixes"
    echo "1 - Symbolic Link Fix"
    echo "2 - Package Install Fix"
    echo "Q or q to quit"
    read answer

    case $answer in
        1)
            symfix
            ;;
        2)
            pkgfix
            ;;
        Q|q)
            exit
            ;;
        *)
            echo "\"$answer\" is not an option "
    esac

    printf "\n"

    if [[ -n $(check) ]]; then
        echo "You are still missing required libraries"
        echo "make sure these are all valid directories"
        echo "$steamdir"
        echo "$steamlibs"
        echo "$dundeflibs"
    else
        echo "You now have all the required libraries"
    fi
done
