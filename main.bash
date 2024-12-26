#!/bin/bash

#
#Skapad av Casper Hjorth och Eric Pettersson, grupp 32
#
# Licens: MIT License
#
# Motivering: vi valde MIT license för att den 'r enkel och till[ter fri anv'ndning, modifiering och distribution av koden.
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
	printf "%-20s: %s\n" Computer name:" 	 $(hostname)"
	printf "%-20s: %s\n" OS Description:"	 $(lsb_release -d | cut -f2)"
	if ! command -v lsb_release &> /dev/null; then
	 echo "OS Description information is unavailable."
	fi
	printf "%-20s: %s\n" Linux Kernal:" 	 $(uname -r)"
	printf "%-20s: %s\n" CPU:" $(lscpu | grep 'Model name' | awk -F':' '{print $2}' | xargs)"
	printf "%-20s: %s\n" Total memory:"		$(free -h | grep 'Mem:' | awk '{print $2}' | sed 's/Gi/GB/')"
	printf "%-20s: %s\n" Free disk space:"	 $(df -h --output=avail,pcent / | awk 'NR==2 {printf "%s (%s)", $1, $2}')"

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
