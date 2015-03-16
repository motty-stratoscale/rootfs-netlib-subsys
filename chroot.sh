#!/bin/bash
CHROOT=$1
echo $CHROOT
shift
if [ "$CHROOT" == "" ]; then
    echo "invalid usage"
    exit 1
fi

function cleanup() {
    sudo umount $CHROOT/proc
}

trap cleanup SIGINT

mount -o bind /proc $CHROOT/proc
cp -a /dev/* $CHROOT/dev
chroot $CHROOT "$@"
RESULT=$?
umount $CHROOT/proc
exit $RESULT
