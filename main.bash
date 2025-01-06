#!/bin/bash

#
#Skapad av Casper Hjorth och Eric Pettersson, grupp 32
#
# Licens: MIT License
#
# Motivering: vi valde MIT license för att den är enkelt och till[ter fri användning, modifiering och distribution av koden.
#

# controlls that the script is running with root acces if not it explains it and exits
if [[ $EUID -ne 0 ]]; then
	echo "Detta skript måste köras som  root (sudo). Avslutar."
	exit 1
fi

# Funktion that shows the main menu
show_Main_Menu() {
	clear
	echo "=========================================================="
	echo "	SYSTEM MANAGER (version 1.0.0) "
	echo "----------------------------------------------------------"
	echo
	echo "ci - Computer Info	(Computer information)"
 	echo 
  	echo "ua - User Add		(Create a new user)"
   	echo "ul - User List 		(List all login users)"
    	echo "uv - User View		(View user properties)"
     	echo "um - User Modify		(Modify user properties)"
      	echo "ud - User Delete		(Delete a login user)"
       	echo
	echo
 	echo "ga - Group Add		(Create a new group)"
  	echo "gl - Group List		(List all groups, not system groups)"
   	echo "gv - Group View		(List all users in a group)"
    	echo "gm - Group Modify		(Add/remove user to/from a group)"
     	echo "gd - Group Delete		(Delete a group, not system groups)"
	echo
 	echo
  	echo "fa - Folder Add		(create a new folder)"
   	echo "fl - Folder list		(view content in a folder)"
    	echo "fv - Folder View		(View folder properteis)"
     	echo "fm - Folder Modify	(modify folder properties)"
      	echo "fd - Folder Delete	(Delete a folder)"
	echo
	echo "X - Exit the system manager"
	echo "----------------------------------------------------------"
	echo
	read -p "Choice: " choice
	case $choice in
		ci) computer_Info ;; 	# Call the funtion to display computer info
  		ua) user_Add ;; 	# Call the funktion for creating a user
    		ul) user_List;;		# Calls the funktion to list all users that can log in byt not system
		uv) user_View;;         # kallar på funktionen som vissar all information som finns med i /etc/passwd och vilka grupper en användare tillhör
  		um) user_Modify;;			# Placeholder for modifying user properties
    		ud) user_Delete;;	# Kallar en funktion som tar bort en användare
      		ga) group_Add;;			# Placeholder for adding a group
		gl) group_List ;;			# Placeholder for listing groups
  		gv) group_View ;;			# Placeholder for viewing users in a group
    		gm) group_Modify;;			# Placeholder for modifying group membership
      		gd) group_Delete;; 			# Placeholder for deleting a group
      		fa) folder_Add ;;			# Placeholder for adding a folder
		fl) folder_List ;;			# Placeholder for listing folder contents
  		fv) folder_View ;;			# Placeholder for viewing folder properties
    		fm) folder_Modify ;;			# Placeholder for modifying folder properties
      		fd) folder_Delete ;;			# Placeholder for deleting a folder
		X) exit_Script ;;
		*) echo "Invalid choice, try again."; sleep 2 ;;
	esac
}
#Shows general computer information
computer_Info() {
	clear
	echo "=========================================================="
	echo " 		 SYSTEM MANAGER (version 1.0.0)"
	echo "			Computer information "
	echo "----------------------------------------------------------"
	echo 
	printf "%-18s: %s\n" "Computer name" "$(hostname)"
	printf "%-18s: %s\n" "OS Description" "$(lsb_release -d | cut -f2)"
	printf "%-18s: %s\n" "Linux Kernel" "$(uname -r)"
	printf "%-18s: %s\n" "CPU" "$(lscpu | grep 'Model name' | awk -F':' '{print $2}' | xargs)"
	printf "%-18s: %s\n" "Total memory" "$(free -h | grep 'Mem:' | awk '{print $2}' | sed 's/Gi/GB/')"
	printf "%-18s: %s\n" "Free disk space" "$(df -h --output=avail,pcent / | awk 'NR==2 {printf "%s (%s)", $1, $2}')" #shows the avalible disk space and its usage percentage for the root partition.
 	printf "%-18s: %s\n" "IP-address" "$(hostname -I | xargs)"
	
	echo
	echo "----------------------------------------------------------"
	echo
	read -p "Press enter to continue... " enter
}
#Funktion för att lägga till en ny användare
user_Add(){
	clear
	echo "=========================================================="
	echo " 		 SYSTEM MANAGER (version 1.0.0)"
	echo "			Add a New User "
	echo "----------------------------------------------------------"
	echo 

	 # Prompt for the username
 	read -p "Enter the username for the new user: " username

  	# Cheack if the user already exists
   	if id "$username" &>/dev/null; then
    		echo "Error: The user '$username' already exists."
      		read -p "Press enter to return to the menu..." enter
		return
  	fi

   	read -p "Enter a comment (e.g., full name) for the user [optional]: " comment 

    	# Create the user
     	if [[ -z $comment ]]; then
      		useradd -m "$username" # Creates a user with a home directory
	else
 		useradd -m -c "$comment" "$username" # Creates a user with a comment
   	fi

	# Check if the user was created successfully
   	if [[ $? -eq 0 ]]; then # $? håller exit statusen på det senaste kommandot om == 0 så fungerade det som det ska -eq = ==
		echo "The user '$username' has been created successfully."
        
  		# Prompt to set a password for the new user
    	   	passwd "$username"
    		if [[ $? -eq 0 ]]; then 
      			echo "Password has been set for user '$username'."
     		else
      			echo "Error: Failed to set password for user '$username'."
     		fi
	else
     		echo "Error: Failed to create the user '$username'."
   	fi

  	read -p "Press enter to return to the menu... " enter
}

#Funktion för att lista användare
user_List(){
	clear
	echo "=========================================================="
	echo " 		 SYSTEM MANAGER (version 1.0.0)"
	echo "			List of Login Users"
	echo "----------------------------------------------------------"
	echo 
	echo -e "USERNAME	FULL NAME	HOME DIRECTORY"
 	# Lista alla användare med UID >= 1000 och giltiga sakl
  	awk -F: '$3 >= 1000 && $7 !~ /nologin|false/ {printf "%-15s %-20s %-20s\n", $1, $5, $6}' /etc/passwd # $1:användarnamn $5:kommentar $6:hemkatalog
   	
	echo
	echo "----------------------------------------------------------"
 	echo
  	read -p "Press Enter to return to the menu... " enter
}

# Funktionen som vissar all information som finns med i /etc/passwd och vilka grupper en användare tillhör
user_View(){
	clear
	echo "=========================================================="
	echo " 		 SYSTEM MANAGER (version 1.0.0)"
	echo "			User view"
	echo "----------------------------------------------------------"
	echo 

 	# Be användaren om en user
  	read -p "Properties for user: " username

 	# Kollar om användaren finns
  	if ! id "$username" &>/dev/null; then
		echo "The user '$username' does not exist."
  		echo "----------------------------------------------------------"
  		read -p "Press enter to return to the menu..." enter
    		return
        fi

 	# Hämta användarens information från /etc/passwd
  	user_info=$(getent passwd "$username")
   	IFS=':' read -r uname passwd uid gid comment home shell <<< "$user_info"

	groups=$(id -nG "$username" | tr ' ' ',  ') #listar grupper användaren tillhör och omvandlar till , separerad lista.

 	echo "Properties for user: $username"
	echo 
 	printf "%-18s: %s\n" "User" "$uname"
  	printf "%-18s: %s\n" "Password" "$passwd"
   	printf "%-18s: %s\n" "User ID" "$uid"
    	printf "%-18s: %s\n" "Group ID" "$gid"
      	printf "%-18s: %s\n" "Comment" "$comment"
        printf "%-18s: %s\n" "Directory" "$home"
	printf "%-18s: %s\n" "Shell" "$shell"
	echo

 	printf "%-18s: %s\n" "Groups" "$groups"
      	
  	echo "----------------------------------------------------------"
   	echo
    	read -p "Press Enter to return to the menu... " enter
}

#Funktion för att modifiera en användare
user_Modify() {
    clear
    echo "=========================================================="
    echo " 		 SYSTEM MANAGER (version 1.0.0)"
    echo "			Modify User"
    echo "----------------------------------------------------------"
    echo 

    # Be om användarnamn
    read -p "Enter the username to modify: " username

    # Kontrollera om användaren finns
    if ! id "$username" &>/dev/null; then
        echo "The user '$username' does not exist."
        echo "----------------------------------------------------------"
        read -p "Press enter to return to the menu..." enter
        return
    fi

    # Visa nuvarande attribut för användaren från /etc/passwd
    user_info=$(getent passwd "$username")
    IFS=':' read -r uname passwd uid gid comment home shell <<< "$user_info"

    echo "Current attributes for user '$username':"
    printf "%-18s: %s\n" "Username" "$uname"
    printf "%-18s: %s\n" "User ID" "$uid"
    printf "%-18s: %s\n" "Group ID" "$gid"
    printf "%-18s: %s\n" "Comment" "$comment"
    printf "%-18s: %s\n" "Home Directory" "$home"
    printf "%-18s: %s\n" "Shell" "$shell"
    echo "----------------------------------------------------------"

    # Alternativ för att ändra attribut
    echo "What do you want to modify?"
    echo "1. Comment (Full Name/Description)"
    echo "2. Home Directory"
    echo "3. Shell"
    echo "4. Password"
    echo "5. Cancel"
    read -p "Choice [1-5]: " choice

    case $choice in
        1)
            read -p "Enter new comment: " new_comment
            sudo usermod -c "$new_comment" "$username"
            if [[ $? -eq 0 ]]; then
                echo "Comment updated successfully for user '$username'."
            else
                echo "Failed to update comment for user '$username'."
            fi
            ;;
        2)
            read -p "Enter new home directory (full path): " new_home
            sudo usermod -d "$new_home" -m "$username"  # -m flyttar filer till den nya katalogen
            if [[ $? -eq 0 ]]; then
                echo "Home directory updated successfully for user '$username'."
            else
                echo "Failed to update home directory for user '$username'."
            fi
            ;;
        3)
            read -p "Enter new shell (e.g., /bin/bash): " new_shell
            sudo usermod -s "$new_shell" "$username"
            if [[ $? -eq 0 ]]; then
                echo "Shell updated successfully for user '$username'."
            else
                echo "Failed to update shell for user '$username'."
            fi
            ;;
        4)
            echo "Changing password for user '$username'..."
            sudo passwd "$username"
            if [[ $? -eq 0 ]]; then
                echo "Password updated successfully for user '$username'."
            else
                echo "Failed to update password for user '$username'."
            fi
            ;;
        5)
            echo "Modification canceled."
            ;;
        *)
            echo "Invalid choice. Returning to the menu."
            ;;
    esac
    echo "----------------------------------------------------------"
    read -p "Press enter to return to the menu..." enter
}
}

# Function to remove a user and their home directory
user_Delete() {
    clear
    echo "=========================================================="
    echo " 		 SYSTEM MANAGER (version 1.0.0)"
    echo "			Delete user"
    echo "----------------------------------------------------------"
    echo 
	 
    # Ask for the username
    read -p "Enter the username to remove: " username

    # Check if the user exists
    if ! id "$username" &>/dev/null; then
        echo "The user '$username' does not exist."
        echo "----------------------------------------------------------"
        read -p "Press enter to return to the menu..." enter
        return
    fi

    # Confirm the removal
    read -p "Are you sure you want to remove $username (Y/n): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        # Remove the user and their home directory
        sudo userdel -r "$username"
        if [[ $? -eq 0 ]]; then 
            echo "The user '$username' and their home directory have been removed successfully."
        else
            echo "An error occurred during the removal of the user."
        fi
    else
        echo "The removal was canceled."
    fi
    echo "----------------------------------------------------------"
    read -p "Press enter to return to the menu..." enter
}

#Funktion för att Skapa nya grupper
group_Add() {

}

#Funktion för att Lista grupper
group_List(){

}

#Funktion för att lista användare i en grupp
group_View(){

}

#Funktion för att ta bort eller lägga till en användare i en grupp
group_Modify(){

}

#Funktion för att ta bort en grupp
group_Delete(){

}

#Funktion för att skapa en ny mapp
folder_Add() {
    clear  
    echo "=========================================================="
    echo "          SYSTEM MANAGER (version 1.0.0)"
    echo "             Add a New Folder"
    echo "----------------------------------------------------------"
    echo

    read -p "Enter Folder Name: " folder_name

    #Kollar om mappen redan finns
    if [ -d "$folder_name" ]; then
        echo "Folder $folder_name already exists. Please enter another folder name."
        read -p "Press enter to continue" enter
    else
        mkdir "$folder_name"  
        echo "The folder $folder_name has been created."
    fi
}
# Funktion för att lista mappinnehåll
folder_List() {
    clear
    echo "=========================================================="
    echo "          SYSTEM MANAGER (version 1.0.0)"
    echo "             List Folder Contents"
    echo "----------------------------------------------------------"
    echo

    read -p "Enter the folder path to list: " folder_path

    # Kollar att mappen existerar
    if [ -d "$folder_path" ]; then
        echo "Contents of folder '$folder_path':"
        ls "$folder_path"
    else
        echo "The folder does not exist."
    fi

    read -p "Press enter to continue..." enter
}

folder_View() {
    clear
    echo""
}

folder_Modify() {
    clear
    echo""
    
}

folder_Delete() {
    clear
    echo""

}


# Exits the script
exit_Script() {
	clear
	echo "Exiting script. Bye"
	exit 0
}
while true; do
	show_Main_Menu
done
