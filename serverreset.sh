#!/bin/bash
service minecraft stop
rm -r /srv/minecraft/worlds/*
mkdir /srv/minecraft/worlds/dota
cp -r /srv/minecraft/backups/dota/* /srv/minecraft/worlds/dota
rm /srv/minecraft/plugins/SimpleClans/SimpleClans.db
rm /srv/minecraft/plugins/ChestBank/chests.yml
cp /srv/minecraft/plugins/ChestBank/chests.yml.backup /srv/minecraft/plugins/ChestBank/chests.yml
rm /srv/minecraft/dota
service minecraft start
