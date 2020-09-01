#!/bin/bash

# Define configuatation pathes
readonly APACHE_CONF_PATH=/etc/httpd/conf/httpd.conf
readonly VIRTUALHOST_CONF_PATH=/etc/httpd/conf.d
readonly VSFTP_CONF_PATH=/etc/vsftpd/vsftpd.conf

# Define some regular expressions
readonly REGEX_NNUMBER='^[0-9]+$'
readonly REGEX_YES='^[Yy]$'

# Define default reply for prompts as "yes"
readonly DEFAULT_REPLY='y'

# Define a function that asks for confirmation before executing a given command
function command_yes_no_prmp {
	reply=DEFAULT_REPLY
	read -p $'The next command will be executed:\n	'"$1"$'\ncontinue [Y/n]: ' reply
	echo
	
	if [[ -z $reply ]] || [[ $reply =~ $REGEX_YES ]]
	then
		eval $1
	fi
}


echo "


    ______    ___    _______  __          ______   ____     _   __    ______    ____   ______
   / ____/   /   |  / ___/\ \/ /         / ____/  / __ \   / | / /   / ____/   /  _/  / ____/
  / __/     / /| |  \__ \  \  /  ______ / /      / / / /  /  |/ /   / /_       / /   / / __
 / /___    / ___ | ___/ /  / /  /_____// /___   / /_/ /  / /|  /   / __/     _/ /   / /_/ /
/_____/   /_/  |_|/____/  /_/          \____/   \____/  /_/ |_/   /_/       /___/   \____/

                                                                        BY: Waleed Mortaja
"

echo "
Welcome to EASY-CONFIG.
This script provide easy access to some of the most important commands for CentOS.

" 

category=-1
while ! ( [[ $category =~ $REGEX_NNUMBER ]] && [ 1 -le $category ] && [ $category -le 2 ] )
do
        echo What category would you like to choose?
        echo "1) apache"
	echo "2) vsftp"
	echo	

        read category
done

echo
case $category in
	1) # apache
		while ! ( [[ $apache_option =~ $REGEX_NNUMBER ]] && [ 1 -le $apache_option ] && [ $apache_option -le 13 ] )
		do
			echo "What would you like to do with apache?"
			echo "1) install apache httpd"
			echo "2) list configuration files"
			echo "3) print main configuration ($APACHE_CONF_PATH)"
			echo "4) test config"
			echo
			echo "5) view apache status"
			echo "6) start apache"
			echo "7) stop apache"
			echo "8) restart apache"
			echo
			echo "9) disable directory listing and follow sysmbolic links"
			echo
			echo "10) run apache on boot"
			echo
			echo "11) Add new virtual server"
			echo
			echo "12) enable ssl"
			echo
			echo "13) install php"
			echo

			read apache_option			
		done		

		case $apache_option in
			1) # install apache httpd
				command_yes_no_prmp "yum install httpd -y"
				;;
			2) # list configuration files
                                command_yes_no_prmp "rpm -qc httpd"
				;;
			3) # print main configuration ($APACHE_CONF_PATH)
				command_yes_no_prmp "cat $APACHE_CONF_PATH | grep -v -e \"^\s*#\" -e \"^\s*$\""
                                ;;
			4) # test config
				command_yes_no_prmp "apachectl configtest"
				;;

							
			5) # view apache status
                                command_yes_no_prmp "systemctl status httpd"
				;;
                        6) # start apache
				command_yes_no_prmp "systemctl start httpd"
                                ;;				
                        7) # stop apache
                                command_yes_no_prmp "systemctl stop httpd"
                                ;;
                        8) # restart apache
				command_yes_no_prmp "systemctl restart httpd"
                                ;;


			9) # disable directory listing and follow sysmbolic links"
				echo "It it recommend to make a backup of the config file"
				command_yes_no_prmp "cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.bak"
				command_yes_no_prmp "sed -i.sed.bak -r -e 's/(Options.*)(Indexes)/\1/g' -e 's/(Options.*)FollowSymLinks/\1/g' $APACHE_CONF_PATH && systemctl reload httpd"
				;;
			10) # run apache on boot
				command_yes_no_prmp "systemctl enable httpd"
				;;

			11) # Add new virtual server
				echo Please Enter the next details for the new virtual host
				echo

				while [[ -z $server_admin ]]
				do
					read -p "Enter server admin email (example: myeamil@site1.com) : " server_admin
		
				done

				while [[ -z $document_root ]]
				do
					read -p "Enter Document root directory (example: /var/www/html/site1) : " document_root
				done

				while  [[ -z $server_name ]]
				do
					read -p "Enter server name (exmple: site1.com) : " server_name
				done

				while [[ -z $server_alias ]]
				do
					read -p "Enter alternative server name (example: www.site1.com) : " server_alias
				done

				while  [[ -z $error_log ]]
				do
					read -p "Enter a path for error logs (example: logs/site1_error_log) : " error_log
				done

				while  [[ -z $custom_log ]]
				do
					read -p "Enter a path for custom logs (example: logs/site1_access_log) : " custom_log
				done
				
				new_virtual_host_conf_file=$VIRTUALHOST_CONF_PATH/$server_name.conf
				
				if [ -f $new_virtual_host_conf_file ]
				then
					echo
					echo A conf file with the same name already exist
					echo "Either choose another server name or remove/edit the file manullay (Which is not part of easy config :P )"
				else
					echo
					reply=DEFAULT_REPLY
					read -p $'Are you sure you want to create a virtual server?\nThe file will be saved on '"$new_virtual_host_conf_file [Y/n]: " reply
					if [[ -z $reply ]] || [[ $reply =~ $REGEX_YES ]]
					then
						mkdir -p $document_root						
						echo "<VirtualHost *:80>" >> $new_virtual_host_conf_file
						echo "	ServerAdmin	$server_admin" >> $new_virtual_host_conf_file		
						echo "	DocumentRoot	\"$document_root\"" >> $new_virtual_host_conf_file
						echo "	Servername	$server_name" >> $new_virtual_host_conf_file
						echo "	ServerAlias	$server_alias" >> $new_virtual_host_conf_file
						echo "	ErrorLog	\"$error_log\"" >> $new_virtual_host_conf_file
						echo "	CustomLog	\"$custom_log\" common" >> $new_virtual_host_conf_file
						echo "</VirtualHost>" >> $new_virtual_host_conf_file
						echo "This is \"$server_name\"" >> $document_root/index.html
						systemctl reload httpd
					fi
				fi
				;;

			12) # enable ssl
				echo 
				read -p "Are you sure you want to enable SSL [Y/n]: " reply
				if [[ -z $reply ]] || [[ $reply =~ $REGEX_YES ]]
				then
					if [ -f /etc/httpd/conf.d/ssl.conf ]
					then
						echo SSL is Already configured.
						echo Congratulations !!
					else
						yum install mod_ssl openssl -y
						systemctl restart httpd
					fi
				fi
				;;
			13) # install php
				command_yes_no_prmp "yum install php -y"
				if [[ -z $reply ]] || [[ $reply =~ $REGEX_YES ]]
				then
					systemctl restart httpd
				fi
				;;
		
		esac
		;;
		
	2) # vsftp
		vsftp_option=-1
		while ! ( [[ $vsftp_option =~ $REGEX_NNUMBER ]] && [ 1 -le $vsftp_option ] && [ $vsftp_option -le 6 ] )
                do
			echo "What would you like to do with vsftp?"
			echo "1) install vsftpd"
			echo
			echo "2) view vsftpd status"
                        echo "3) start vsftpd"
                        echo "4) stop vsftpd"
                        echo "5) restart vsftpd"
			echo
			echo "6) jail users to their home directories"

			echo
			read vsftp_option

		done

		 case $vsftp_option in
                        1) # install vsftpd
                                command_yes_no_prmp "yum install vsftpd -y"
                                ;;

			2) # view vsftpd status
				command_yes_no_prmp "systemctl status vsftpd"
				;;

			3) # start vsftpd
                                command_yes_no_prmp "systemctl start vsftpd"
                                ;;

                        4) # stop vsftpd
                                command_yes_no_prmp "systemctl stop vsftpd"
                                ;;

                        5) # restart vsftpd
                                command_yes_no_prmp "systemctl restart vsftpd"
                                ;;

			6) # jail users to their home directories
				read -p "Are you sure you want to jail users to their home directories [Y/n]: " reply
				echo
				if [[ -z $reply ]] || [[ $reply =~ $REGEX_YES ]]
                                then
					echo >> $VSFTP_CONF_PATH 
					echo >> $VSFTP_CONF_PATH 
					echo >> $VSFTP_CONF_PATH

					echo chroot_local_user=YES >> $VSFTP_CONF_PATH
					echo allow_writeable_chroot=YES >> $VSFTP_CONF_PATH
					systemctl restart vsftpd
                                fi
				;;
		esac
		;;
esac
