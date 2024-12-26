#!/bin/bash

#
#Skapad av Casper Hjorth och Eric Pettersson, grupp 32
#
# Licens: MIT License
#
# Motivering: vi valde MIT license för att (skriv motivering här)
#

# Kontrollera om skriptet körs som root
if [[ $EUID -ne 0 ]]; then
	echo "Detta skript måste köras som  root (sudo). Avslutar."
	exit 1
fi

# Funktion för att visa huvudmenyn
show_Main_Menu() {
	clear
	echo "=========================================================="
	echo "	SYSTEM MANAGER (version 1.0.0) "
	echo "----------------------------------------------------------"
	echo
	echo "ci - Computer Info	(Computer information"
	echo "X - Exit the system manager"
	echo "----------------------------------------------------------"
	echo
	read -p "Choice: " choice
	case $choice in
		ci) computer_Info ;;
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
	echo " Computer name: 	 $(hostname)"
	echo " OS Description: 	 $(lsb_release -d | cut -f2)"
	echo " Linux Kernal: 		 $(uname -r)"
	echo " CPU: $(lscpu | grep 'Model name' | awk -F':' '{print $2}' | tr -d '\n')" #Clean up output
	echo " Total memory:	 	$(free -h | grep 'Mem:' | awk '{print $2}' | sed 's/Gi/GB/')"
	read -p "Press enter to continue... " enter

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
