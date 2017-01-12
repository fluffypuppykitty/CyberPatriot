#!/bin/bash

#Script for user management and other features. Likely to be scrapped. -Conner

##################
#	User Manager

edit_user() {
	echo "Enter the name of the user to edit: "
	read USR
	
	echo "Keep, Remove, or View Groups for this user? (k/r/g)"
	read TMP
	if [ $TMP = "k" ]; then
		keep_user
	
	elif [ $TMP = "r" ]; then
		remove_user

	elif [ $TMP = "g" ]; then
		view_groups
	fi

}

keep_user() {
	echo "Change user password? (y/n)"
	read TMP
	if [ $TMP = "y" ]; then
		sudo passwd $USR
	fi

}

add_user() {
	echo "Enter the name of the user you want to add: "
	read $USR
	sudo adduser $USR
}

remove_user() {
	echo "Are you sure you want to remove the user $USR? (y/n)"
	read TMP
	if [ $TMP = "y" ]; then
		sudo deluser $USR
	fi
}

view_groups() {
	groups $USR
	echo "Remove/add to groups or continue? (r/a/c)"
	read TMP
	if [ $TMP = "r" ]; then
		echo "Enter the group you wish to remove the user from: "
		read TMP
		sudo deluser $USR $TMP
		echo "View groups again? (y/n)"
		read TMP
		if [ $TMP = "y" ]; then
			view_groups
		fi
	elif [ $TMP = "a" ]; then
		echo "Enter the group you wish to add the user to: "
		read TMP
		sudo adduser $USR $TMP
		echo "View groups again? (y/n)"
		read TMP
		if [ $TMP = "y" ]; then
			view_groups
		fi
	elif [ $TMP = "c" ]; then
		break
	fi
}

user_manager() {
	echo "This is a list of all the users: "
	sudo cut -d: -f 1 /etc/passwd

	UM="1"
	while [ $UM = "1" ]
	do
		echo "Edit/Add a user or go back to the menu? (e/a/m)"
		read TMP
		if [ $TMP = "m" ]; then
			UM="2"
		elif [ $TMP = "e" ]; then
			edit_user
		elif [ $TMP = "a" ] ; then
			add_user
		fi
	done
	menu
}

#####################################################

########
# MP3 Search 
find_mp3() {
	sudo find /home -type f -name '*.mp3' >> ~/Desktop/mp3_results.txt
	cat ~/Desktop/mp3_results.txt
	menu
}

########

########
# Services

menu() {
	clear
	echo "#    MENU     #"
	echo " "
	echo "1. User Manager"
	echo "2. Search for MP3"
	echo "3. View Services"

	read TMP
	if [ $TMP = "1" ]; then
		user_manager
	elif [ $TMP = "2" ]; then
		find_mp3
	elif [ $TMP = "3" ]; then
		sudo ps -U root -u root -N
		menu
	fi
}

menu
