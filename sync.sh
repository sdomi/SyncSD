#!/usr/bin/env bash
wipe=1

if [[ $1 == "--help" ]]; then
    echo "$0 - warp-speed SD card syncing utility"
    echo "Options:"
    echo "--no-wipe - only copies files"
    echo
    echo "This script must be run with root privileges"
    exit
elif [[ $1 == "--no-wipe" ]]; then
    wipe=0
elif [[ $1 != "" ]]; then
    echo "Unrecognized option '$1'"
    echo "Use --help for usage info"
    exit
fi

rm /tmp/sdcard.devices
touch /tmp/sdcard.devices

while true; do
    labels=$(ls /dev/disk/by-label/ | grep -vif /tmp/sdcard.devices -vf blacklist.txt)
    for i in $labels; do
        if ls cards | grep $i > /dev/null; then
            mkdir /media/$i
            mount /dev/disk/by-label/$i /media/$i
            if [[ $wipe == 1 ]]; then
                find /media/$i/* | grep -vi "arch" | xargs rm
            fi
            cp -Rn cards/$i/* /media/$i
            sleep 1
            umount /media/$i
            udisksctl power-off -b /dev/disk/by-label/$i
            rm -R /media/$i
            notify-send --icon=$(pwd)/icon.png -t 3000 "You can safely eject the device"
        else
            echo "Unknown device appeared, doing nothing!";
        fi
    done
    ls /dev/disk/by-label/ > /tmp/sdcard.devices
    sleep 1
done