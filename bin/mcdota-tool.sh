#!/bin/bash
# Helpful commands for managing the dota server

### Settings ###

# Commands to start and stop the server
minecraft_start() { minecraft.sh start; }
minecraft_stop() { minecraft.sh stop; }

# Change this to your server's root directory
SERVER_DIR=`pwd` 

# Path to store the dota world backup at.  Will be automaticly be created if it doesn't exist.
BACKUP_PATH="backups/dota/original"

# File to check when reseting the server (don't change this)
RESET_FILE="reset-required"

# Name of the folder containing the dota world (don't change this)
WORLD_PATH="dota"

### End Settings ###

backup_dota() {
    [ -e $WORLD_PATH/level.dat ] || error "The world '$WORLD_PATH' wasn't found"
    [ ! -e $BACKUP_PATH ] || error "Backup already exists at $BACKUP_PATH"
    mkdir -p $BACKUP_PATH
    cp -r $WORLD_PATH/* $BACKUP_PATH
}

restore_dota() {
    [ -e $BACKUP_PATH ] || error "No backup found at $BACKUP_PATH.  You will need to make one before the world map can be restored"
    minecraft_stop
    rm -rf dota
    cp -rf $BACKUP_PATH dota
    rm -f plugins/SimpleClans/SimpleClans.db
    minecraft_start
}

check_dota() {
    if [ -e $RESET_FILE ]; then 
        reset_dota
        rm -rf $RESET_FILE
    fi
}

print_help() {
    echo "Usage: mcdota-tool.sh [command]"
    echo
    echo "backup - Create an inital backup of the world file to restore from later."
    echo "restore - Reset the teams and restore the world to its original state."
    echo "check - Checks for if a reset is needed.  If it is, 'restore' is run."
    echo "help - This message"
}

error() {
    echo >&2 $1
    exit 1
}

cd $SERVER_DIR
[ -f server.properties ] || error "Please run this script from the root of the server directory (with server.properties)"

case "$1" in
    backup) backup_dota ;;
    restore) restore_dota ;;
    check) check_dota ;;
    help) print_help ;;
    *) error "No such command, try 'dota-tool.sh help'" ;;
esac

exit 0
