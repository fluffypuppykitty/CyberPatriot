#!/bin/bash
CONT="1"
FIRST="1"
                                                          
while [ "$CONT" = "1" ] 
do
	clear
	echo " ##############"
	echo "| USER MANAGER |"
	echo " ##############"
	echo " "
	if [ "$FIRST" != "1" ]; then
		echo ""
		echo "Check another user? (y/n): "
		read TMP
		if [ "$TMP" = "n" ]; then
			CONT="0"
			break;
		fi
	fi
	FIRST="0"	
		echo ""
		echo "Enter the name of the user: "
		read USR
		getent passwd $USR > /dev/null
		if [ $? = 0 ]; then
			echo ""
			echo "The user exists, these are the groups they belong to:"
			groups $USR
			echo ""
			echo "Keep or delete this user?(k/d):"
			read TMP
			if [ "$TMP" = "d" ]; then
				sudo deluser $USR
			else
				RAC=" "
				while [ "$RAC" != "c" ]
				do
					echo ""
					echo "Remove/Add from/to a group or Continue (r/a/c): "
					read TMP
					if [ "$TMP" = "r" ]; then
						echo ""
						echo "Enter the group you would like to remove them from (c to cancel): "
						read GRP
						if [ "$GRP" != "c" ]; then
							sudo deluser $USR $GRP
						fi
						
					elif [ "$TMP" = "a" ]; then
						echo ""
						echo "Enter the group you would like to add the user to (c to cancel): "
						read GRP
						if [ "$GRP" != "c" ]; then
							sudo adduser $USR $GRP
						fi
					else
						RAC="c"
					fi
				done
			fi
		else
			echo ""
			echo "This user does not exist. Would you like to add this user? (y/n): "
			read TMP
			if [ "$TMP" = "y" ]; then
				sudo adduser $USR
			
				AC=" "
				while [ "$AC" != "c" ]
				do
					echo ""
					echo "Would you like to add this user to any groups? (y/n): "
					read TMP
					if [ "$TMP" = "y" ]; then
						groups
						echo ""
						echo "Enter the group you would like to add the user to: "
						read GRP
						sudo adduser $USR $GRP
					else
						AC="c"
					fi
				done
			fi	
	fi
done