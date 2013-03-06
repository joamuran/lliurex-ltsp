#!/bin/bash
# This command regenerates PXELinux Menus

getlabel(){
    dir=$1
    name=$(echo $dir | cut -d "/" -f1)
    menulabel=$name

    case "$name" in
    "llx-desktop")
        menulabel="LliureX 13.06 Escriptori"
        ;;
    "llx-client")
        menulabel="LliureX 13.06 Client d'aula"
        ;;
    "llx-infantil")
        menulabel="LliureX 13.06 Infantil"
        ;;
    "llx-musica") 
        menulabel="LliureX 13.06 Música"
        ;;
    "llx-pime")
        menulabel="LliureX 13.06 Pime"
        ;;
    esac
    echo $menulabel;    
}


tftpboot="/var/lib/tftpboot/ltsp"

cat << EOF > $tftpboot/pxelinux.cfg/default
#LliureX LTSP Boot Menu - Created automatically by llx-create-pxelinux

DEFAULT pxelinux.cfg/vesamenu.c32
PROMPT 0
MENU TITLE LliureX LTSP
MENU BACKGROUND lliurex-pxe.png

MENU WIDTH 80
MENU MARGIN 10
MENU ROWS 12
MENU TABMSGROW 18
MENU CMDLINEROW 12
MENU ENDROW 24
MENU TIMEOUTROW 20
menu color title 2 #ff000000 #00999999 std
menu color unsel 0 #ff000000 #00999999 std
menu color sel 30,47 #00990099 #889900cc std
menu color border 0 #00ffffff #00ffffff none
ONTIMEOUT localboot
TIMEOUT 200

EOF


for dir in `ls $tftpboot`
do
    if [ -d $tftpboot/$dir ] && [ -e "$tftpboot/$dir/pxelinux.cfg/default" ]; then
        #echo "$dir/pxelinux.cfg/default"
        label=$(getlabel ${dir})
        dirpxe=$(echo $dir | cut -d "/" -f1)
        echo "llx-create-pxelinux: Adding menu for $label"
	cat << EOF >> $tftpboot/pxelinux.cfg/default

# $label NBD Boot
LABEL $label
    MENU LABEL $label
    KERNEL pxelinux.cfg/vesamenu.c32
    CONFIG $dir/pxelinux.cfg/default $dirpxe/
EOF

    fi
done

