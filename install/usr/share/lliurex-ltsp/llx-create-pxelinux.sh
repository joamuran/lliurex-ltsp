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
        menulabel="LliureX 13.06 Musica"
        ;;
    "llx-pime")
        menulabel="LliureX 13.06 Pime"
        ;;
    "llx-lite")
        menulabel="LliureX 13.06 Escriptori Lleuger (XFCE)"
        ;;
    esac
    echo $menulabel;    
}


tftpboot="/var/lib/tftpboot/ltsp"

# Check if pxelinux exists
if [ -f "$tftpboot/pxelinux.cfg/default" ]; then
	# Check if netinstall is available
	NETINST=`cat $tftpboot/pxelinux.cfg/default | grep "# Netinst: Install Menu" | wc -l`    
else 
	# if not exists pxelinux.cfg/default, let's allow netinstall
	NETINST=1
fi


echo "#LliureX LTSP Boot Menu - Created automatically by llx-create-pxelinux
DEFAULT pxelinux.cfg/vesamenu.c32
PROMPT 0
MENU TITLE Arrencada per xarxa de LliureX
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
TIMEOUT 50

LABEL localboot
      menu label ^Arranca des del disc dur
      localboot 0
" > $tftpboot/pxelinux.cfg/default 

for dir in `ls $tftpboot`
do
    if [ -d $tftpboot/$dir ] && [ -e "$tftpboot/$dir/pxelinux.cfg/default" ] && [ $dir != "netinstall" ]; then

        #echo "$dir/pxelinux.cfg/default"
	# This logic is here to prevent the mistake
	# that LABEL is the GOTO name
	
	label_of_label=$(echo $dir | cut -d "/" -f1)
	
	# The label value is the Human readable
	# value for this PXE entry.
        
	label=$(getlabel ${dir})

	# This is the dir of pxe linux (submenus)
	
        dirpxe=$(echo $dir | cut -d "/" -f1)
	
	# Creating the pxe entry at menu
        echo "llx-create-pxelinux: Adding menu for $label"
	echo "LABEL $label_of_label
    MENU LABEL Arranca $label" >> $tftpboot/pxelinux.cfg/default
	
	# This is the DEFAULT PXE entry
	# is important to be setted to llx-client
	if [ "$label_of_label" = "llx-client" ]; then
		echo "    MENU default" >> $tftpboot/pxelinux.cfg/default
	fi
	
	# Continue with the rest of entry
 	echo "KERNEL pxelinux.cfg/vesamenu.c32
    CONFIG $dir/pxelinux.cfg/default $dirpxe/">> $tftpboot/pxelinux.cfg/default


	#### BEGIN ENABLE LAPTOPS MENU
	rc=0
	#cat $tftpboot/$dir/pxelinux.cfg/default | grep -q 'video=LVDS-1:d' || rc=1
	#if [ ${rc} -eq 1 ]; then 

	if [ `cat $tftpboot/$dir/pxelinux.cfg/default | grep 'video=LVDS-1:d' | wc -l` -eq 1 ]; then
		cat $tftpboot/$dir/pxelinux.cfg/default | sed 's/video=LVDS-1:d//' > $tftpboot/$dir/pxelinux.cfg/default-laptop
		# Creating the pxe entry at menu
        	echo "llx-create-pxelinux: Adding menu for $label (laptop)"
		echo "LABEL $label_of_label-laptop
	MENU LABEL Arranca $label (Ordinador Portatil)" >> $tftpboot/pxelinux.cfg/default
		
		# Continue with the rest of entry
	 	echo "KERNEL pxelinux.cfg/vesamenu.c32
	CONFIG $dir/pxelinux.cfg/default-laptop $dirpxe/">> $tftpboot/pxelinux.cfg/default
	
	fi
	#### END ENABLE LAPTOPS MENU

    fi
done


if [ $NETINST -eq 1 ]; then
        echo "llx-create-pxelinux: Adding menu Netinstall"
	cat << EOF >> $tftpboot/pxelinux.cfg/default

# Netinst: Install Menu 
LABEL Instal.la LliureX en aquest ordinador
   MENU LABEL Instal.la LliureX en aquest ordinador
   KERNEL netinstall/ubuntu-installer/i386/boot-screens/vesamenu.c32
   CONFIG netinstall/pxelinux.cfg/default netinstall/
EOF

fi
