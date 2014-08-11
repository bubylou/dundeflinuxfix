#!/bin/bash

steamdir=$(locate "steam.pipe" | head -1 | sed "s/\/steam\.pipe/\/steam/")
libs="$steamdir/SteamApps/common/DunDefEternity/DunDefEternity/Binaries/Linux"
find "$libs" -maxdepth 1 -type l -exec rm -f {} \;
