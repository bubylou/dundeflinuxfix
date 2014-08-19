#!/bin/bash

steamdir=$(locate "steam.pipe" | head -1 | sed "s/\/steam\.pipe/\//")
steamlibs=$(locate steam-runtime/i386 | head -1)
dundeflibs=$(locate DunDefEternity | grep "DunDefEternity/DunDefEternity/Binaries/Linux" | head -1)

check()
{
    ldd "$dundeflibs/DunDefGame" | grep "not found" | \
        tr -d "\t" | cut -d"=" -f1 | sort -u
}

clean()
{
    echo "Removed all symbolic links"
    find "$dundeflibs" -maxdepth 1 -type l -exec rm -f {} \;
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

while true; do
    echo "Updating Database"
    sudo updatedb

    echo "Choose one of the following potential fixes"
    echo "1 - Symbolic Link Fix"
    echo "2 - Remove Symbolic Links"
    echo "Q or q to quit"
    read answer

    echo ""

    case $answer in
        1)
            symfix
            break
            ;;
        2)
            clean
            exit
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
