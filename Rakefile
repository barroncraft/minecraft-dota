#!/usr/bin/ruby
require 'fileutils'
include FileUtils

# Change these to match your setup
WORLD_PATH="worlds/dota"
BACKUP_PATH="backups/dota/original"
RESET_FILE="reset-required"
MINECRAFT_START="minecraft.sh start"
MINECRAFT_STOP="minecraft.sh stop"

desc "Create an inital backup of the world file to restore from later"
task :backup do
    backup
end

desc "Reset the teams and restore the world to its original state."
task :restore do
    restore
end

desc "Checks for if a reset is needed.  If it is, 'restore' is run."
task :check do
    if File.exist? RESET_FILE
        restore
        rm_f RESET_FILE
    end
end

desc "Removes extra plugins and Barron Minecraft specific branding in preperation for a release"
task :package do
    package
end

def backup
    # Check if the world exists or if we've already taken a backup
    File.exist?("#{WORLD_PATH}/level.dat") or abort("The world '$WORLD_PATH' wasn't found")
    File.exist?(BACKUP_PATH)              and abort("Backup already exists at #{BACKUP_PATH}")

    # Create the backup folder and copy the world to it
    mkdir_p BACKUP_PATH
    cp_r Dir.glob("#{WORLD_PATH}/*"), BACKUP_PATH
end

def restore
    # Check to make sure a backup exists
    File.exist?(BACKUP_PATH) or abort("No backup found at #{BACKUP_PATH}.  You will need to make one before the world map can be restored")

    # Stop Minecraft
    system MINECRAFT_STOP

    # Copy over the world from backup and remove the teams database
    rm_rf WORLD_PATH
    cp_r BACKUP_PATH, WORLD_PATH
    rm_f "plugins/SimpleClans/SimpleClans.db"

    # Start Minecraft
    system MINECRAFT_START
end

def package
    # Check for possible errors before they happen
    File.exist?("server.properties") or abort("Please run this script from the root of the server directory (with server.properties)")
    which("git")                     or abort("This script requires git, but it is not installed.")
    which("zip")                     or abort("This script requires zip, but it is not installed.")
    system("git rev-parse")          or abort("The current directory is not a git repository.")

    # Create a temporary directory to do all our work in
    Dir.mktmpdir do |tempdir|

        version=`git describe --abbrev=0`
        name="Barron_Minecraft_Dota_#{version}"
        target="#{tempdir}/$name"

        # Copy files over
        mkdir target
        cp_r Dir.glob("*"), target

        # Clean up files
        Dir.chdir(target) do
            `sed -i 's/Barron Minecraft DOTA/Minecraft DOTA/' server.properties`
            `sed -i 's/Barron Minecraft/Minecraft Dota/' plugins/CommandBook/config.yml`
            rm_r "plugins/MessageChangerLite"
            `sed -i '/^users:$/q' plugins/PermissionsEx/permissions.yml`
        end

        # Compress files
        Dir.chdir(tempdir) do
            `zip -r #{name}.zip #{name}`
        end
        mv "#{tempdir}/#{name}.zip" "."
        puts "Release created in #{name}.zip"
    end
end

def which(cmd)
    exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
    ENV['PATH'].split(FILE::PATH_SEPARATOR).each do |path|
        exts.each do |ext|
            exe = File.join(path, "#{cmd}#{ext}")
            return exe if File.executable? exe
        end
    end
    return nil
end
