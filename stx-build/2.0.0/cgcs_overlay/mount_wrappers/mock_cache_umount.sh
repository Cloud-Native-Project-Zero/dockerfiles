#!/bin/bash

MOUNT_POINT=$1

id $USER | grep '(cgts)\|751(mock)' > /dev/null
if [ $? -ne 0 ]
then
    echo "Only members of group cgts may use this tool."
    exit 1
fi

MY_UID=`id -u $USER`
if [ $? -ne 0 ]
then
    echo "failed to determine UID."
    exit 1
fi

MY_GID=`getent group cgts | cut -d: -f3`
if [ $? -ne 0 ]
then
    echo "failed to determine GID."
    exit 1
fi

# echo "USER=$USER"
# echo "UID=$UID"
# echo "MY_UID=$MY_UID"
# echo "MY_GID=$MY_GID"

if [ ! -d $MOUNT_POINT ]
then
    echo "'$MOUNT_POINT' is not a directory"
    exit 1
fi

echo "$MOUNT_POINT" | grep -e '/mock/.*root/' > /dev/null
if [ $? -ne 0 ]
then
    echo "'$MOUNT_POINT' does not match pattern 'mock*root'"
    exit 1
fi

mount | grep "$USER" > /dev/null
if [ $? -ne 0 ]
then
    echo "'$MOUNT_POINT' is not mounted by $USER"
    exit 1
fi

# echo "umount $MOUNT_POINT"
umount $MOUNT_POINT
if [ $? -ne 0 ]
then
    echo "failed to unmount '$MOUNT_POINT'"
    exit 1
fi

echo "'$MOUNT_POINT' unmounted"
exit 0
