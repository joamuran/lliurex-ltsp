#!/bin/bash
mk_users_passwd() {
    user=$1
    pass=$2
    # ¡Magia, no toques aqui!
    /usr/sbin/chpasswd <<END
$user:$pass
END
}

mk_net_structure(){
	username=$1
	group=$2

 	mkdir -p /net/home/${group}/${username}/UserFiles

       	for folder in Documents Groups Music Videos Pictures Share; do
       		mkdir -p /net/home/${group}/${username}/UserFiles/${folder}
       	done

       chown -R ${username}:${group} /net/home/${group}/${username}



}
 
# USAGE: q3llum.sh group_name group_prefix initusernumber endusernumber
 
group=$1
prefix=$2

for  (( i = $3 ; i <= $4; i++ )); do
        if [ $i -lt 10 ]; then
                username=${prefix}0${i}
        else
                username=${prefix}${i}
        fi

	echo "Creating user=${username} password=${username} group=${group}"
        /usr/sbin/useradd --home /home/$username --create-home --gid $group $username || exit 1

        #Create password
	mk_users_passwd ${username} ${username} || exit 1

	#Create structure in /net
	mk_net_structure ${username} ${group}

	# modify user shell
	chsh -s /bin/bash ${username}

	# Add user to fuse group
	adduser ${username} fuse
done
