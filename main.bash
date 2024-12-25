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
show_mainmenu() {
	clear
	echo "================================="
	echo "	SYSTEM MANAGER (version 1.0.0) "
	echo "---------------------------------"
