#!/bin/bash
# Removes extra plugins and Barron Minecraft specific branding in preperation for a release

# Check for possible errors before they happen
[ -f server.properties ] || { echo >&2 "Please run this script from the root of the server directory (with server.properties)"; exit 1; }
command -v git >/dev/null 2>&1 || { echo >&2 "This script requires git, but it is not installed."; exit 1; }
command -v zip >/dev/null 2>&1 || { echo >&2 "This script requires zip, but it is not installed."; exit 1; }
git rev-parse >/dev/null 2>&1 || { echo >&2 "The current directory is not a git repository."; exit 1; }

# Set up our variables
CURR_DIR=`pwd`
TEMP_DIR=`mktemp -d`
VERSION=`git describe --abbrev=0`
NAME="Barron_Minecraft_Dota_$VERSION"
TARGET="$TEMP_DIR/$NAME"
trap "rm -rf $TEMP_DIR" EXIT

# Copy files
mkdir -p $TARGET
cp -r * $TARGET

# Clean up files
cd $TARGET
sed -i 's/Barron Minecraft DOTA/Minecraft DOTA/' server.properties
sed -i 's/Barron Minecraft/Minecraft Dota/' plugins/CommandBook/config.yml
rm plugins/ColorMe/players.yml
sed -i '/^users:$/q' plugins/PermissionsEx/permissions.yml
mv worlds/dota .
rm -r worlds/
rm -r bin/
rm Bukfile Bukfile.lock Rakefile

# Add server start scripts
echo "java -jar spigot.jar" > server.sh
echo "java -jar spigot.jar" > server.bat

# Compress files
cd $TEMP_DIR
zip -r $NAME.zip $NAME >/dev/null
mv $NAME.zip $CURR_DIR
echo "Release created in $NAME.zip"
