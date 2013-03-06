#!/bin/bash
# This command makes a copy of pxelinux.cfg/default files to be booted on a multiple LliureX LTSP images system

init() {
    default=$1
    destination=$2

    # Initial conditions, usage, etc.
if [ $# -eq 4 ];then
    option="interactive"
else
    option=$3
fi

if [ $1 = $2 ] && [ $option != "force" ]; then
        read -p "Warning! Destination and Original file are the same! Are you sure? " -n 1
    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
        exit 1
    fi    
fi
}

# Initial conditions, usage, etc.
if [ $# -ne 5 ] && [ $# -ne 4 ]; then
    echo "Usage: llx-cp-pxe filename-to-magic-copy destination-to-copy-the-llx-pxe-magic [interactive|force] ip-server chroot-name"
    exit -1
fi

# getting parameters
default=$1
destination=$2
option=$3
server=$4
chroot=$5

init ${default} ${destination} ${option};


# Let's go!

echo "# File created by LliureX LTSP command llx-cp-pxe" > "/tmp/llx-cp-pxe.tmp"

echo "default ltsp-NBD" >> "/tmp/llx-cp-pxe.tmp"
echo "ontimeout ltsp-NBD" >> "/tmp/llx-cp-pxe.tmp"
echo "" >> "/tmp/llx-cp-pxe.tmp"

adding_ltsp=0
while read line
  do
      
   if [ "$line" = 'label ltsp' ]; then
        line='label ltsp-NBD'
   fi

   if [ "$line" = 'label ltsp-NBD' ]; then
      adding_ltsp=1
   fi

    # Transform menu lines
    header=$(echo $line | cut -d " " -f1)
    #
    #if [ "$header" = 'ipappend' ] && [ $adding_ltsp -eq 1 ]; then
    #    adding_ltsp=0
    #    echo "ipappend 3" >> /tmp/llx-cp-pxe.tmp
    #fi
    
    if [ "$header" = 'append' ] && [ $adding_ltsp -eq 1 ]; then
        line="$line nbdroot=$server:$chroot"
    fi
        
    if [ $adding_ltsp -eq 1 ]; then
        echo $line >> /tmp/llx-cp-pxe.tmp
    fi
    if [ -z "$line" ]; then
        adding_ltsp=0
    fi

done < $default

echo "ipappend 3" >> /tmp/llx-cp-pxe.tmp

mv /tmp/llx-cp-pxe.tmp $destination
